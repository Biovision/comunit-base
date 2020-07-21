# frozen_string_literal: true

module Comunit
  module Network
    # Pulling data from other site
    module Pulling
      # Entity is original for site
      def original?
        return true unless self.class.central_site?

        raise Errors::UnknownSiteError if site.nil?
        raise Errors::EmptyEntityError if entity.nil?

        entity.data.dig(ROOT_KEY, SITE_KEY).to_s == site.uuid
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

        self.entity = entity_class.find_by(id: id)
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

      def ensure_site_presence
        entity.data[ROOT_KEY] ||= {}
        return if entity.data[ROOT_KEY].key?(SITE_KEY)

        entity.data[ROOT_KEY][SITE_KEY] = site&.uuid
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

      def after_pull
        if self.class.central_site?
          NetworkEntitySyncJob.perform_later(entity.class.to_s, entity.id)
        end

        true
      end

      def pull_data
        apply_attributes
      end

      def apply_attributes
        permitted = self.class.permitted_attributes
        input = data.dig(:attributes).to_h

        attributes = input.select { |a, _| permitted.include?(a.to_sym) }
        entity.assign_attributes(attributes)
        apply_comunit unless self.class.central_site?
      end
    end
  end
end