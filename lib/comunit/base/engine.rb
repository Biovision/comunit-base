module Comunit
  module Base
    class Engine < ::Rails::Engine
      initializer  "comunit_base.load_base_methods" do
        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::BaseMethods
        end
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
