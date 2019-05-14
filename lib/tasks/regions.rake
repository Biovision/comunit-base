# frozen_string_literal: true

namespace :regions do
  desc 'Import regions from YAML without deleting old data'
  task import: :environment do
    file_path = "#{Rails.root}/tmp/import/regions.yml"
    media_dir = "#{Rails.root}/tmp/import/regions"
    ignored   = %w[header_image]
    if File.exist? file_path
      File.open file_path, 'r' do |file|
        YAML.safe_load(file).each do |id, data|
          attributes = data.reject { |key| ignored.include?(key) }
          entity     = Region.find_by(id: id) || Region.new(id: id)
          entity.assign_attributes(attributes)

          if data.key?('header_image') && entity.header_image.blank?
            image_file = "#{media_dir}/header_image/#{id}/#{data['header_image']}"
            if File.exist?(image_file)
              entity.header_image = Pathname.new(image_file).open
            end
          end
          entity.save!
          print "\r#{id}    "
        end
        puts
      end
      Region.connection.execute "select setval('regions_id_seq', (select max(id) from regions));"
      puts "Done. We have #{Region.count} regions now"
    else
      puts "Cannot find file #{file_path}"
    end
  end

  desc 'Dump regions to YAML'
  task dump: :environment do
    file_path = "#{Rails.root}/tmp/export/regions.yml"
    media_dir = "#{Rails.root}/tmp/export/regions"
    ignored   = %w[id header_image]
    File.open file_path, 'w' do |file|
      Region.order('id asc').each do |e|
        print "\r#{e.id}    "
        file.puts "#{e.id}:"
        e.attributes.reject { |a, v| ignored.include?(a) || v.nil? }.each do |a, v|
          file.puts "  #{a}: #{v.inspect}"
        end
        next if e.header_image.blank?

        image_name = "#{e.long_slug}#{File.extname(File.basename(e.header_image.path))}"
        image_dir  = "#{media_dir}/header_image/#{e.id}"
        FileUtils.mkdir_p(image_dir) unless Dir.exist?(image_dir)
        FileUtils.copy(e.header_image.path, "#{image_dir}/#{image_name}")
        file.puts "  header_image: #{image_name.inspect}"
      end
      puts
    end
  end
end
