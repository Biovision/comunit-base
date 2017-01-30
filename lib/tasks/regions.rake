namespace :regions do
  desc 'Load regions from YAML with deleting old data'
  task load: :environment do
    file_path = "#{Rails.root}/tmp/import/regions.yml"
    image_fir = "#{Rails.root}/tmp/import/regions"
    if File.exists? file_path
      puts 'Deleting old regions...'
      Region.destroy_all
      puts 'Done. Importing...'
      File.open file_path, 'r' do |file|
        YAML.load(file).each do |id, data|
          region = Region.new id: id
          region.assign_attributes data
          if data.has_key? 'image'
            image_file   = "#{image_dir}/#{id}/#{data['image']}"
            region.image = Pathname.new(image_file).open if File.exists?(image_file)
          end
          region.save!
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
    image_dir = "#{Rails.root}/tmp/export/regions"
    ignored   = %w(id users_count news_count image)
    File.open file_path, 'w' do |file|
      Region.order('id asc').each do |entity|
        print "\r#{entity.id}    "
        file.puts "#{entity.id}:"
        entity.attributes.reject { |a, v| ignored.include?(a) || v.nil? }.each do |attribute, value|
          file.puts "  #{attribute}: #{value.inspect}"
        end
        unless entity.image.blank?
          image_name = File.basename(entity.image.path)
          Dir.mkdir "#{image_dir}/#{entity.id}" unless Dir.exists? "#{image_dir}/#{entity.id}"
          FileUtils.copy entity.image.path, "#{image_dir}/#{entity.id}/#{image_name}"
          file.puts "  image: #{image_name.inspect}"
        end
      end
      puts
    end
  end
end
