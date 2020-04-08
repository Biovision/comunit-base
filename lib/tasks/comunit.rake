# frozen_string_literal: true

namespace :comunit do
  desc 'Update site id to uuid in users'
  task update_user_sites: :environment do
    puts "Total user count: #{User.count}"
    updates = 0
    User.order('id asc').each do |user|
      site_id = user.data.dig('comunit', 'site_id')
      print "\r#{user.id}: #{user.slug} #{site_id.inspect} "
      next if site_id.blank?

      site = Site.find_by(id: site_id)
      next if site.nil?

      user.data['comunit']['site_id'] = site.uuid
      user.save!
      updates += 1
    end

    puts "\nDone. Updated #{updates} users"
  end
end
