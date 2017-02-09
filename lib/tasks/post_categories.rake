namespace :post_categories do
  desc 'Load post_categories from YAML with deleting old data'
  task load: :environment do
    file_path = "#{Rails.root}/tmp/import/post_categories.yml"
    if File.exists? file_path
      puts 'Deleting old post_categories...'
      PostCategory.destroy_all
      puts 'Done. Loading...'
      File.open file_path, 'r' do |file|
        YAML.load(file).each do |id, data|
          post_category = PostCategory.new id: id
          post_category.assign_attributes data
          post_category.save!
          print "\r#{id}    "
        end
        puts
      end
      PostCategory.connection.execute "select setval('post_categories_id_seq', (select max(id) from post_categories));"
      puts "Done. We have #{PostCategory.count} post_categories now"
    else
      puts "Cannot find file #{file_path}"
    end
  end

  desc 'Dump post_categories to YAML'
  task dump: :environment do
    file_path = "#{Rails.root}/tmp/export/post_categories.yml"
    ignored   = %w(id items_count)
    File.open file_path, 'w' do |file|
      PostCategory.order('id asc').each do |entity|
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
