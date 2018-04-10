Comunit::Base
=============

Основной функционал для сайтов сети `comunit`.

Действия для создания нового сайта сети
---------------------------------------

Нужно заменить `config/locales/en.yml` на `ru.yml` и добавить туда ключи
`shared.meta_texts.site_name` и `copyright` для вывода названия сайта 
в метаданных и копирайта соответственно.

Также нужно добавить в локаль ключ `index.index.title` с заголовком для главной
страницы.

### Добавления в `.gitignore`

Стоит убрать строки `!log/.keep` и `!tmp/.keep`, так как `log` и `tmp` создаются
на сервере как ссылки в любом случае.

```
/public/uploads
/public/ckeditor

/spec/examples.txt
/spec/support/uploads/*

.env
```

### Дополнения в `Gemfile`

```ruby
gem 'dotenv-rails'
gem 'jquery-rails'

gem 'autoprefixer-rails', group: :production

gem 'biovision-base', git: 'https://github.com/Biovision/biovision-base'
# gem 'biovision-base', path: '/Users/maxim/Projects/Biovision/gems/biovision-base'
gem 'biovision-poll', git: 'https://github.com/Biovision/biovision-poll'
# gem 'biovision-poll', path: '/Users/maxim/Projects/Biovision/gems/biovision-poll'
gem 'biovision-comment', git: 'https://github.com/Biovision/biovision-comment'
# gem 'biovision-comment', path: '/Users/maxim/Projects/Biovision/gems/biovision-comment'
gem 'comunit-base', git: 'https://github.com/Biovision/comunit-base'
# gem 'comunit-base', path: '/Users/maxim/Projects/Biovision/Comunit/comunit-base'

group :development, :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'mina'
end
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
//= require jquery3
//= require biovision/base/biovision
//= require biovision/vote/biovision-vote
//= require comunit/base/socialization
```

Заменить `app/assets/stylesheets/application.css` на `application.scss` из
`sample/app/assets/stylesheets/`.

Примеры для `shared` и `layout` можно найти там же (просто скопировать
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

### Изменения в `config/initializers/comunit_base.rb`

_Нужно поменять `example` на соответствующее название проекта!_

### Изменения в `config/initializers/sidekiq.rb`

_Нужно поменять `example` на соответствующее название проекта!_

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
  config.include FactoryBot::Syntax::Methods
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

### Дополнения в `config/environments/production.rb`

Нужно закомментировать строку про `uglifier`, пока не заработает нормальный сбор
JS на сервере. Это в районе 27 строки (`config.assets.js_compressor`).

Нужно заменить уровень журналирования ошибок с `:debug` на `:warn`. Это в районе
52 строки (`config.log_level`). 

Для настройки почты нужно поменять `example.com` на актуальный домен ниже.

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

### Дополнения в `config/environments/test.rb`

Нужно поменять `example.com` на актуальный домен

```ruby
  config.action_mailer.default_options = {
      from: 'example.com <webmaster@example.com>',
      reply_to: 'support@example.com'
  }
  config.action_mailer.default_url_options = { :host => '0.0.0.0:3000' }
```
  
### Дополнения в `config/environments/development.rb`

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
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp', 'public/uploads', 'public/ckeditor')
set :shared_files, fetch(:shared_files, []).push('.env')

# В том месте, где task :environment, сразу после
task :environment do
  invoke :'rbenv:load'
end
```

На сервере в рабочей папке (`var/www/example.com`):

```bash
mkdir -p shared/tmp/puma
mkdir -p shared/public/uploads
mkdir -p shared/tmp/import
cd shared/public
ln -s /var/www/ckeditor
```

После этого локлаьно можно запустить `mina setup` и настроить остальное 
на стороне сервера.

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

Занесение сайта в сеть
----------------------

В консоли `comunit.online`.

```ruby
site = Site.find(site_id)
Site.where(active: true).each { |s| NetworkManager.new(s).push_site(site) }

m = NetworkManager.new(site)
Site.order('id asc').each { |s| m.push_site(s) }

m = NetworkManager::UserHandler.new(Site.last)
User.order('id asc').each { |u| puts "#{u.id}\t#{u.screen_name}";m.push_user(u) }
```


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
