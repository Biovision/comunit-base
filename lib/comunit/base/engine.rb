module Comunit
  module Base
    class Engine < ::Rails::Engine
      config.before_initialize do
        config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
      end
    end

    require 'redis-namespace'
    require 'sidekiq'
    require 'carrierwave'
    require 'kaminari'
    require 'elasticsearch/persistence'
    require 'elasticsearch/model'
    require 'mini_magick'
    require 'carrierwave-bombshelter'
    require 'rest-client'
  end
end
