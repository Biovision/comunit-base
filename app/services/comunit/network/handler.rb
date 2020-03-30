# frozen_string_literal: true

module Comunit
  module Network
    # Base entity handler for synchronization
    class Handler
      include Logging
      include Sending

      MAIN_HOST = 'https://comunit.online'

      attr_accessor :entity, :data

      # @param [ApplicationRecord] entity
      def initialize(entity)
        @entity = entity
      end

      # @param [Hash] data
      def self.[](data)
        instance = new(nil)
        instance.data = data
        instance
      end

      # @param [ApplicationRecord] entity
      # @param [TrueClass|FalseClass] wrap
      def self.relationship_data(entity, wrap = true)
        return nil if entity.nil?

        data = { id: entity.uuid, type: entity.class.table_name }
        wrap ? { data: data } : data
      end

      def self.ignored_attributes
        %w[data id image]
      end

      def self.permitted_attributes
        %i[created_at]
      end

      def push
        return if entity.nil?

        log_info("Pushing #{entity.class} #{entity.uuid}")
        path = "#{MAIN_HOST}/comunit/#{entity.class.table_name}/#{entity.uuid}"
        rest(:put, path, data: prepare_model_data)
      end

      # @param [String] uuid
      def pull(uuid)
        @entity = entity_class.find_or_initialize_by(uuid: uuid)
        log_info "Pulling #{@entity.class} #{uuid}"
        pull_data
        log_info "Validation status after pull: #{@entity.valid?}"
        if @entity.valid?
          @entity.save
        else
          log_error @entity.errors.messages
        end
      end

      def prepare_model_data
        self.class.relationship_data(entity)
      end

      def entity_class
        self.class.to_s.demodulize.gsub(/Handler$/, '').safe_constantize
      end

      protected

      # Attributes for remote post create/update
      #
      # @return [Hash]
      def attributes_for_remote
        ignored = self.class.ignored_attributes

        @entity.attributes.reject do |a, _|
          ignored.include?(a) || a.end_with?('_count', '_id')
        end
      end

      def relationships_for_remote
        {}
      end

      def meta_for_remote
        {}
      end

      def pull_data
        apply_attributes
      end

      def apply_attributes
        permitted = self.class.permitted_attributes
        input = @data.dig(:attributes).to_h

        attributes = input.select { |a, _| permitted.include?(a.to_sym) }
        @entity.assign_attributes(attributes)
      end

      # @param [Symbol] key
      def dig_related_id(key)
        data.dig(:relationships, key, :data, :id)
      end

      def apply_user
        @entity.user = User.find_by(uuid: dig_related_id(:user))
      end

      def apply_agent
        @entity.agent = Agent[data.dig(:meta, :agent)]
      end
    end
  end
end
