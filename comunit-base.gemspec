$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "comunit/base/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comunit-base"
  s.version     = Comunit::Base::VERSION
  s.authors     = ["Maxim Khan-Magomedov"]
  s.email       = ["maxim.km@gmail.com"]
  s.homepage    = "https://github.com/Biovision/comunit-base"
  s.summary     = "Base for comunit network site"
  s.description = "Users, posts, news, regions, sites and blogs"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency 'rails-i18n', '~> 5.0.0'
  s.add_dependency 'bcrypt', '~> 3.1.7'
  s.add_dependency 'redis-namespace'
  s.add_dependency 'elasticsearch-persistence'
  s.add_dependency 'elasticsearch-model'
  s.add_dependency 'mini_magick'
  s.add_dependency 'carrierwave'
  s.add_dependency 'carrierwave-bombshelter'
  s.add_dependency 'sidekiq'
  s.add_dependency 'rest-client'

  s.add_development_dependency "pg"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
end
