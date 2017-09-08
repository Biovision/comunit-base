class LinkProfilesToUsers < ActiveRecord::Migration[5.1]
  def up
    User.order('id asc').each do |user|
      profile = user.user_profile
      if profile.nil?
        profile = UserProfile.new(user: user)
        fields  = UserProfile.entity_parameters
        data    = user.attributes.select { |a| fields.include?(a) }
        profile.assign_attributes(data)
        profile.save!
      end

      search_string = "#{user.slug} #{user.email} #{user.surname} #{user.name}"
      user.update(search_string: search_string.downcase)
    end
  end

  def down
    #   Привязанные ссылки удалять не нужно
  end
end
