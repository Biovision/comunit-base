UserProfile.class_eval do
  enum marital_status: [:single, :dating, :engaged, :married, :in_love, :complicated, :in_active_search]
end