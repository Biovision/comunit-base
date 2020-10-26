# frozen_string_literal: true

module Comunit
  module Network
    # Base entity handler for synchronization
    class Handler
      MAIN_HOST = 'https://comunit.online'
      ROOT_KEY = 'comunit'
      SITE_KEY = 'site_id'
      SYNC_KEY = 'sync_state'

      include Logging
      include Sending
      include ApplyingParts
      include Pushing
      include Pulling

      attr_accessor :site, :entity, :data

      # @param [Site|nil] site
      def initialize(site = nil)
        self.site = site
      end

      def self.central_site?
        site_id.blank?
      end

      def self.site_id
        ENV['SITE_ID'].to_s
      end

      def self.host
        Site[site_id]&.host || MAIN_HOST
      end

      # Sets current site by signature
      #
      # Signature format is <site_id>:<token>
      # For example, 1:AaaBbb
      #
      # @param [String] signature
      def self.[](signature)
        if central_site?
          instance_for_center(signature)
        else
          instance_for_remote(signature)
        end
      end

      # @param [String] signature
      def self.instance_for_center(signature)
        parts = signature.split(':')
        site = Site.find_by(id: parts[0])
        raise Errors::UnknownSiteError if site.nil?
        raise Errors::InvalidSignatureError unless site.token == parts[1].to_s

        new(site)
      end

      # @param [String] signature
      def self.instance_for_remote(signature)
        token = Rails.application.credentials.signature_token
        raise Errors::InvalidSignatureError unless signature == token

        new(nil)
      end

      # @param [ApplicationRecord] entity
      def self.sync(entity)
        NetworkEntitySyncJob.perform_later(entity.class.to_s, entity.id)
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
        return false if site_id == site&.uuid

        sync_state == -1 || sync_state.positive?
      end

      def host
        site&.host || MAIN_HOST
      end

      def site_id
        entity.data.dig(ROOT_KEY, SITE_KEY).to_s
      end

      def sync_state
        raise Errors::UnknownSiteError if site.nil?
        raise Errors::EmptyEntityError if entity.nil?

        new_id = entity.data.dig(ROOT_KEY, SYNC_KEY, site.uuid)
        legacy_id = entity.data.dig(ROOT_KEY, SYNC_KEY, site.id)
        new_id || legacy_id || -1
      end

      def entity_class
        self.class.to_s.demodulize.gsub(/Handler$/, '').safe_constantize
      end

      # @param [String] uuid
      def show(uuid)
        model = entity_class
        self.entity = model.nil? ? nil : model.find_by(uuid: uuid)
        if entity.nil?
          { errors: [{ code: 404, text: 'Cannot find entity' }] }
        else
          { data: prepare_model_data }
        end
      end

      def rpc
        method_name = "rpc_#{data.dig(:meta, :rpc)}".to_sym
        send(method_name) if respond_to? method_name
      end
    end
  end
end
