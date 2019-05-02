User.class_eval do
  belongs_to :region, optional: true, counter_cache: true
end
