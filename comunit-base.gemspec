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

  s.add_dependency 'biovision-base'
  s.add_dependency 'biovision-vote'
  s.add_dependency 'biovision-comment'
  s.add_dependency 'dotenv-rails'

  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
end
