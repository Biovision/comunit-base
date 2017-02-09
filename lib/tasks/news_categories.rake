namespace :news_categories do
  desc 'Load news_categories from YAML with deleting old data'
  task load: :environment do
    file_path = "#{Rails.root}/tmp/import/news_categories.yml"
    if File.exists? file_path
      puts 'Deleting old news_categories...'
      NewsCategory.destroy_all
      puts 'Done. Loading...'
      File.open file_path, 'r' do |file|
        YAML.load(file).each do |id, data|
          news_category = NewsCategory.new id: id
          news_category.assign_attributes data
          news_category.save!
          print "\r#{id}    "
        end
        puts
      end
      NewsCategory.connection.execute "select setval('news_categories_id_seq', (select max(id) from news_categories));"
      puts "Done. We have #{NewsCategory.count} news_categories now"
    else
      puts "Cannot find file #{file_path}"
    end
  end

  desc 'Dump news_categories to YAML'
  task dump: :environment do
    file_path = "#{Rails.root}/tmp/export/news_categories.yml"
    ignored   = %w(id items_count)
    File.open file_path, 'w' do |file|
      NewsCategory.order('id asc').each do |entity|
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
