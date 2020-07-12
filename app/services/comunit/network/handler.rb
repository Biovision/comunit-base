# frozen_string_literal: true

module Comunit
  module Network
    # Base entity handler for synchronization
    class Handler
      include Logging
      include Sending
      include ApplyingParts

      MAIN_HOST = 'https://comunit.online'
      ROOT_KEY = 'comunit'
      SITE_KEY = 'site_id'
      SYNC_KEY = 'sync_state'

      attr_accessor :site, :entity, :data

      # @param [Site] site
      def initialize(site = nil)
        self.site = site
      end

      def self.central_site?
        site_id.blank?
      end

      def self.site_id
        ENV['SITE_ID'].to_s
      end

      # Sets current site by signature
      #
      # Signature format is <site_id>:<token>
      # For example, 1:AaaBbb
      #
      # @param [String] signature
      def self.[](signature)
        if central_site?
          parts = signature.split(':')
          site = Site.find_by(id: parts[0])
          raise Errors::UnknownSiteError if site.nil?
          raise Errors::InvalidSignatureError unless site.token == parts[1].to_s
        else
          site = nil
          token = Rails.application.credentials.signature_token
          raise Errors::InvalidSignatureError unless signature == token
        end
        new(site)
      end

      # API version when it was implemented on remote site
      def self.since
        7
      end

      def self.permitted_attributes
        %i[created_at uuid]
      end

      def self.ignored_attributes
        %w[data id image updated_at]
      end

      # @param [ApplicationRecord] entity
      # @param [TrueClass|FalseClass] wrap
      def self.relationship_data(entity, wrap = true)
        return nil if entity.nil?

        data = { id: entity.uuid, type: entity.class.table_name }
        wrap ? { data: data } : data
      end

      # Entity needs to be pushed to site
      def sync?
        return false if site&.version.to_i < self.class.since
        return false if entity.nil?

        sync_state == -1 || sync_state.positive?
      end

      # Entity is original for site
      def original?
        return true unless self.class.central_site?

        raise Errors::UnknownSiteError if site.nil?
        raise Errors::EmptyEntityError if entity.nil?

        entity.data.dig(ROOT_KEY, SITE_KEY).to_s == site.uuid
      end

      def sync_state
        raise Errors::UnknownSiteError if site.nil?
        raise Errors::EmptyEntityError if entity.nil?

        new_id = entity.data.dig(ROOT_KEY, SYNC_KEY, site.uuid)
        legacy_id = entity.data.dig(ROOT_KEY, SYNC_KEY, site.id)
        new_id || legacy_id || -1
      end

      # @param [TrueClass|FalseClass] amend
      def push(amend = false)
        log_info("Pushing #{entity.class} #{entity.uuid}")
        ensure_site_is_pushed
        code = rest(:put, path(amend), data: prepare_model_data)

        if code.to_i / 100 == 2
          apply_sync_state
        else
          log_error "Unexpected response code: #{code}"
        end
      end

      # @param [String] uuid
      def pull(uuid)
        self.entity = entity_class.find_or_initialize_by(uuid: uuid)
        check_site_and_pull(entity.id.nil?)
        if entity.valid?
          ensure_site_presence if self.class.central_site?
          entity.save && after_pull
        else
          log_error entity.errors.messages
        end
      end

      # @param [Integer] id
      def amend(id)
        return if self.class.central_site?

        entity = entity_class.find_by(id: id)
        if entity.nil?
          log_info "Could not find #{entity_class} #{id}"
        else
          log_info "Amending #{entity.class} #{id}"
          pull_data
          if entity.valid?
            entity.save && after_pull
          else
            log_error entity.errors.messages
          end
        end
      end

      # @param [TrueClass|FalseClass] amend
      def path(amend = false)
        prefix = "comunit/#{entity.class.table_name}"
        amend ? "#{prefix}/#{entity.id}/amend" : "#{prefix}/#{entity.uuid}"
      end

      def ensure_site_is_pushed
        return unless self.class.central_site?
        return unless entity.data.dig(ROOT_KEY, SITE_KEY).nil?

        entity.data[ROOT_KEY] ||= {}
        entity.data[ROOT_KEY][SITE_KEY] = ''
        entity.save
      end

      def prepare_model_data
        {
          id: entity.uuid,
          type: entity.class.table_name,
          attributes: attributes_for_remote,
          relationships: relationships_for_remote,
          meta: meta_for_remote
        }
      end

      def entity_class
        self.class.to_s.demodulize.gsub(/Handler$/, '').safe_constantize
      end

      protected

      # @param [Integer] state
      def ensure_sync_state(state = nil)
        entity.data[ROOT_KEY] ||= {}
        entity.data[ROOT_KEY][SYNC_KEY] ||= {}
        entity.data[ROOT_KEY][SYNC_KEY][site&.uuid] = state unless state.nil?
      end

      def ensure_site_presence
        entity.data[ROOT_KEY] ||= {}
        return if entity.data[ROOT_KEY].key?(SITE_KEY)

        entity.data[ROOT_KEY][SITE_KEY] = site&.uuid
      end

      # @param [Integer] state
      def apply_sync_state(state = Time.now.to_i)
        return unless self.class.central_site?

        raise Errors::UnknownSiteError if site.nil?

        ensure_sync_state(state)

        entity.save
        log_info 'Updated sync state'
      end

      # @param [TrueClass|FalseClass] skip_site_check
      def check_site_and_pull(skip_site_check)
        log_info "Pulling #{entity.class} #{entity.uuid}"
        if skip_site_check || original?
          pull_data
          log_info "Validation status after pull: #{entity.valid?}"
        else
          log_warn "#{entity.class} is not original"
        end
      end

      def meta_for_remote
        { ROOT_KEY.to_sym => entity.data[ROOT_KEY] }
      end

      def after_pull
        if self.class.central_site?
          NetworkEntitySyncJob.perform_later(entity.class.to_s, entity.id)
        end

        true
      end

      # Attributes for remote post create/update
      #
      # @return [Hash]
      def attributes_for_remote
        ignored = self.class.ignored_attributes

        @entity.attributes.reject do |a, _|
          ignored.include?(a) || a.end_with?('_count', '_id', '_cache')
        end
      end

      def relationships_for_remote
        nil
      end

      def pull_data
        apply_attributes
      end

      def apply_attributes
        permitted = self.class.permitted_attributes
        input = @data.dig(:attributes).to_h

        attributes = input.select { |a, _| permitted.include?(a.to_sym) }
        entity.assign_attributes(attributes)
        apply_comunit unless self.class.central_site?
      end
    end
  end
end
