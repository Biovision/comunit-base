UserProfile.class_eval do
  NAME_LIMIT   = 100

  enum marital_status: [:single, :dating, :engaged, :married, :in_love, :complicated, :in_active_search]

  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :patronymic, maximum: NAME_LIMIT
  validates_length_of :surname, maximum: NAME_LIMIT
end