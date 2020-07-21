# frozen_string_literal: true

module Comunit
  module Network
    # Pushing data to other site
    module Pushing
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

      # @param [TrueClass|FalseClass] amend
      def path(amend = false)
        prefix = "comunit/#{entity.class.table_name}"
        amend ? "#{prefix}/#{entity.id}/amend" : "#{prefix}/#{entity.uuid}"
      end

      def ensure_site_is_pushed
        return unless self.class.central_site?
        return unless entity.data.dig(Handler::ROOT_KEY, Handler::SITE_KEY).nil?

        entity.data[Handler::ROOT_KEY] ||= {}
        entity.data[Handler::ROOT_KEY][Handler::SITE_KEY] = ''
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

      # Attributes for remote entity create/update
      #
      # @return [Hash]
      def attributes_for_remote
        ignored = self.class.ignored_attributes

        entity.attributes.reject do |a, _|
          ignored.include?(a) || a.end_with?('_count', '_id', '_cache')
        end
      end

      def relationships_for_remote
        nil
      end

      def meta_for_remote
        { Handler::ROOT_KEY.to_sym => entity.data[Handler::ROOT_KEY] }
      end

      # @param [Integer] state
      def ensure_sync_state(state = nil)
        entity.data[Handler::ROOT_KEY] ||= {}
        entity.data[Handler::ROOT_KEY][Handler::SYNC_KEY] ||= {}
        return if state.nil?

        entity.data[Handler::ROOT_KEY][Handler::SYNC_KEY][site&.uuid] = state
      end

      # @param [Integer] state
      def apply_sync_state(state = Time.now.to_i)
        return unless self.class.central_site?

        raise Errors::UnknownSiteError if site.nil?

        ensure_sync_state(state)

        entity.save
        log_info 'Updated sync state'
      end
    end
  end
end