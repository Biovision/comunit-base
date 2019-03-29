Region.class_eval do
  def self.synchronization_parameters
    ignored = %w[header_image users_count]

    column_names.reject { |c| ignored.include?(c) }
  end
end
