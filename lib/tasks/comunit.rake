# frozen_string_literal: true

namespace :comunit do
  desc 'Update site id to uuid in users'
  task update_user_sites: :environment do
    puts "Total user count: #{User.count}"
    updates = 0
    User.order('id asc').each do |user|
      site_id = user.data.dig('comunit', 'site_id')

      if site_id.nil? && user.respond_to?(:site_id)
        site_id = user.site_id
      end

      print "\r#{user.id}: #{user.slug} #{site_id.inspect} "
      next if site_id.blank?

      site = Site.find_by(id: site_id)
      next if site.nil?

      user.data['comunit'] ||= {}
      user.data['comunit']['site_id'] = site.uuid
      user.save!
      updates += 1
    end

    puts "\nDone. Updated #{updates} users"
  end

  desc 'Dump user uuids'
  task dump_user_ids: :environment do
    file_name = "#{Rails.root}/tmp/export/user_ids.yml"
    File.open(file_name, 'wb') do |f|
      User.order('id asc').each do |entity|
        f.puts %(#{entity.slug.inspect}: "#{entity.uuid}")
      end
    end
  end

  desc 'Load user uuids'
  task load_user_ids: :environment do
    file_path = "#{Rails.root}/tmp/import/user_ids.yml"
    if File.exist?(file_path)
      File.open(file_path, 'r') do |file|
        YAML.load(file).each do |id, uuid|
          print "\r#{id}\t#{uuid} "
          entity = User.find_by(slug: id)
          if entity.nil?
            puts 'was not found'
          else
            entity.uuid = uuid
            puts 'cannot be saved' unless entity.save
          end
        end
      end
    end

    puts "\nDone."
  end

  desc 'Dump region uuids'
  task dump_region_ids: :environment do
    file_name = "#{Rails.root}/tmp/export/region_ids.yml"
    File.open(file_name, 'wb') do |f|
      Region.order('id asc').each do |entity|
        f.puts %(#{entity.id}: "#{entity.uuid}")
      end
    end
  end

  desc 'Load region uuids'
  task load_region_ids: :environment do
    file_path = "#{Rails.root}/tmp/import/region_ids.yml"
    if File.exist?(file_path)
      File.open(file_path, 'r') do |file|
        YAML.load(file).each do |id, uuid|
          print "\r#{id}\t#{uuid} "
          entity = Region.find_by(id: id)
          if entity.nil?
            puts 'was not found'
          else
            entity.uuid = uuid
            puts 'cannot be saved' unless entity.save
          end
        end
      end
    end

    puts "\nDone."
  end

  desc 'Dump site uuids'
  task dump_site_ids: :environment do
    file_name = "#{Rails.root}/tmp/export/site_ids.yml"
    File.open(file_name, 'wb') do |f|
      Site.order('id asc').each do |entity|
        f.puts %(#{entity.id}: "#{entity.uuid}")
      end
    end
  end

  desc 'Load site uuids'
  task load_site_ids: :environment do
    file_path = "#{Rails.root}/tmp/import/site_ids.yml"
    if File.exist?(file_path)
      File.open(file_path, 'r') do |file|
        YAML.load(file).each do |id, uuid|
          print "\r#{id}\t#{uuid} "
          entity = Site.find_by(id: id)
          if entity.nil?
            puts 'was not found'
          else
            entity.uuid = uuid
            puts 'cannot be saved' unless entity.save
          end
        end
      end
    end

    puts "\nDone."
  end
end
