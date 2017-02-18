module Toggleable
  extend ActiveSupport::Concern

  included do
    class_attribute :toggleable_attributes, instance_predicate: false, instance_accessor: false

    # @param [String] attribute
    def toggle_parameter(attribute)
      if self::toggleable_attributes.include? attribute.to_sym
        toggle! attribute
        { attribute => self[attribute] }
      end
    end
  end

  module ClassMethods

    private

    def toggleable(*attributes)
      cattr_accessor :toggleable_attributes
      self.toggleable_attributes = attributes.flatten
    end
  end
end
