namespace :themes do
  desc 'Load themes from YAML with deleting old data'
  task load: :environment do
    file_path = "#{Rails.root}/tmp/import/themes.yml"
    if File.exists? file_path
      puts 'Deleting old themes...'
      Theme.destroy_all
      puts 'Done. Importing...'
      File.open file_path, 'r' do |file|
        YAML.load(file).each do |id, data|
          theme = Theme.new id: id
          theme.assign_attributes data
          theme.save!
          print "\r#{id}    "
        end
        puts
      end
      Theme.connection.execute "select setval('themes_id_seq', (select max(id) from themes));"
      puts "Done. We have #{Theme.count} themes now"
    else
      puts "Cannot find file #{file_path}"
    end
  end

  desc 'Dump themes to YAML'
  task dump: :environment do
    file_path = "#{Rails.root}/tmp/export/themes.yml"
    ignored   = %w(id post_categories_count news_categories_count)
    File.open file_path, 'w' do |file|
      Theme.order('id asc').each do |entity|
        print "\r#{entity.id}    "
        file.puts "#{entity.id}:"
        entity.attributes.reject { |a, v| ignored.include?(a) || v.nil? }.each do |attribute, value|
          file.puts "  #{attribute}: #{value.inspect}"
        end
      end
      puts
    end
  end
end
