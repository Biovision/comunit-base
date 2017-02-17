module Comunit
  module Base
    class Engine < ::Rails::Engine
      initializer  "comunit_base.load_base_methods" do
        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::BaseMethods
        end
      end

      config.assets.precompile << %w(biovision/base/icons/*)
      config.assets.precompile << %w(biovision/base/placeholders/*)
    end

    require 'biovision/base'
    require 'redis-namespace'
    require 'sidekiq'
    require 'carrierwave'
    require 'elasticsearch/persistence'
    require 'elasticsearch/model'
    require 'mini_magick'
    require 'carrierwave-bombshelter'
    require 'rest-client'
  end
end
