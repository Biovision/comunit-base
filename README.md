Comunit::Base
=============

Основной функционал для сайтов сети `comunit`.

Действия для создания нового сайта сети
---------------------------------------

Нужно заменить `config/locales/en.yml` на `ru.yml` и добавить туда ключи
`site_name` и `copyright` для вывода названия сайта в метаданных и копирайта
соответственно.

Также нужно добавить в локаль ключ `index.index.title` с заголовком для главной
страницы.

### Дополнения в `Gemfile`

```ruby
gem 'dotenv-rails'

gem 'autoprefixer-rails', group: :production

gem 'biovision-base', git: 'https://github.com/Biovision/biovision-base'
# gem 'biovision-base', path: '/Users/maxim/Projects/Biovision/biovision-base'
gem 'biovision-vote', git: 'https://github.com/Biovision/biovision-vote'
# gem 'biovision-vote', path: '/Users/maxim/Projects/Biovision/biovision-base'
gem 'comunit-base', git: 'https://github.com/Biovision/comunit-vote'
# gem 'comunit-base', path: '/Users/maxim/Projects/Biovision/Comunit/comunit-base'

group :development, :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'mina'
end
```

### Добавления в `.gitignore`

Стоит убрать строки `!log/.keep` и `!tmp/.keep`, так как `log` и `tmp` создаются
на сервере как ссылки в любом случае.

```
/public/uploads
/public/ckeditor

/spec/examples.txt
/spec/support/uploads/*

/vendor/assets/javascripts/jquery.min.js

.env
```

### Добавления в `config/routes.rb`

```ruby
  mount Biovision::Base::Engine, at: '/'
  mount Biovision::Vote::Engine, at: '/'
  mount Comunit::Base::Engine, at: '/'

  root 'index#index'

  scope 'about' do
    get '/' => 'about#index', as: :about
  end
```

### Если сайт региональный, добавить в `app/controllers/application_controller.rb`

```ruby
  before_action :set_current_region
```

### Пример `.env`

```
RAILS_MAX_THREADS=5
SECRET_KEY_BASE=
DATABASE_PASSWORD=
MAIL_PASSWORD=
SIGNATURE_TOKEN=
SITE_ID=
```

Параметр `SECRET_KEY_BASE` создаётся через `rails secret` в консоли.
`DATABASE_PASSWORD` — через random.org, `MAIL_PASSWORD` — или через интерфейс
внешнего почтовика, или через тот же random.org.
`SIGNATURE_TOKEN` и `SITE_ID` берутся из админки comunit.

### Добавления в `app/assets/`

В `app/assets/javascripts/application.js` перед `//= require_tree .`

```
//= require jquery.min
//= require biovision/base/biovision
//= require biovision/vote/biovision-vote
//= require comunit/base/socialization
```

Локально нужно положить актуальную версию `jquery.min.js` 
в `vendor/assets/javascripts`.

Заменить `app/assets/stylesheets/application.css` на `application.scss` из
`sample/app/assets/stylesheets/`.

Примеры для `colors`, `shared` и `layout` можно найти там же (просто скопировать
поверх текущих файлов). 

### Дополнения в `config/*.yml`

Для начала нужно убедиться в правильности содержимого `database.yml`

 * Названия баз
 * Наличие `host: localhost` в разделе `production`
 * Правильный ключ в `ENV` в `production.password` (`DATABASE_PASSWORD`), 
   такой же, как в `.env`

В `secrets.yml` нужно добавить параметр:

```yaml
  signature_token: <%= ENV["SIGNATURE_TOKEN"] %>
```

### Дополнения в `config/application.rb`

_Нужно поменять `example` на соответствующее название проекта!_

```ruby
  class Application < Rails::Application
    config.time_zone = 'Moscow'

    config.i18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :ru

    %w(app/services lib).each do |path|
      config.autoload_paths << config.root.join(path).to_s
    end

    config.active_job.queue_adapter = :sidekiq

    config.news_index_name  = 'example_news'
    config.post_index_name  = 'example_posts'
    config.entry_index_name = 'example_entries'
  end
```

### Добавить файл `config/initializers/sidekiq.rb`

_Нужно поменять `example` на соответствующее название проекта!_

```ruby
redis_uri = 'redis://localhost:6379/0'
app_name  = 'example'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_uri, namespace: app_name }
end
```

### Дополнения в `config/puma.rb`

Нужно закомментировать строку с портом (`port ENV.fetch('PORT') { 3000 }`), 
это 12 строка на момент написания инструкций.

Нужно поменять `example.com` на актуальный домен.

```ruby
if ENV['RAILS_ENV'] == 'production'
  shared_path = '/var/www/example.com/shared'
  logs_dir    = "#{shared_path}/log"

  pidfile "#{shared_path}/tmp/puma/pid"
  state_path "#{shared_path}/tmp/puma/state"
  bind "unix://#{shared_path}/tmp/puma.sock"
  stdout_redirect "#{logs_dir}/stdout.log", "#{logs_dir}/stderr.log", true

  activate_control_app
end
```

### Дополнения в `spec/rails_helper.rb` (`$ rails generate rspec:install`)

Раскомментировать строку 23 (включение содержимого spec/support)

```ruby
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
```

### Дополнения в `spec/spec_helper.rb`

```ruby
RSpec.configure do |config|
  config.after(:all) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
  end
end
```

### Дополнения в config/environments/production.rb

Нужно поменять `example.com` на актуальный домен

Вариант для `mail.ru`

```ruby
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: 'smtp.mail.ru',
      port: 465,
      tls: true,
      domain: 'example.com',
      user_name: 'webmaster@example.com',
      password: ENV['MAIL_PASSWORD'],
      authentication: :login,
      enable_starttls_auto: true
  }
  config.action_mailer.default_options = {
      from: 'example.com <webmaster@example.com>',
      reply_to: 'support@example.com'
  }
  config.action_mailer.default_url_options = { host: 'example.com' }
```

### Дополнения в config/environments/test.rb

Нужно поменять `example.com` на актуальный домен

```ruby
  config.action_mailer.default_options = {
      from: 'example.com <webmaster@example.com>',
      reply_to: 'support@example.com'
  }
  config.action_mailer.default_url_options = { :host => '0.0.0.0:3000' }
```
  
### Дополнения в config/environments/development.rb

Нужно поменять `example.com` на актуальный домен

```ruby
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_options = {
      from: 'example.com <webmaster@example.com>',
      reply_to: 'support@example.com'
  }
  config.action_mailer.default_url_options = { :host => '0.0.0.0:3000' }
```

После настройки
---------------

```bash
bundle binstub puma
bundle binstub sidekiq
rails db:create
rails railties:install:migrations
```

Дальше в консоли:

```bash
rails db:migrate
mina init
```

После этого нужно отредактировать `config/deploy.rb`.

```ruby
# В самом начале, 3 строка
require 'mina/rbenv'

#...
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp', 'public/uploads', 'public/ckeditor', 'vendor/assets/javascripts/jquery.min.js')
set :shared_files, fetch(:shared_files, []).push('.env')

# В том месте, где task :environment, сразу после
task :environment do
  invoke :'rbenv:load'
end
```

После этого можно запустить `mina setup` и настроить остальное на стороне
сервера.

В бою
-----

Нужно импортировать регионы

В папке `tmp/import`:

```bash
ln -s /var/www/shared/import/regions
ln -s /var/www/shared/import/regions.yml
```

В папке проекта (`current`):

```bash
bin/rake regions:load
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
