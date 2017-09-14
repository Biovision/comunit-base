module Comunit
  module Base
    class Engine < ::Rails::Engine
      initializer  "comunit_base.load_base_methods" do
        ActiveSupport.on_load(:action_controller) do
          include Biovision::Base::PrivilegeMethods
        end

        require_dependency 'comunit/base/decorators/models/region_decorator'
        require_dependency 'comunit/base/decorators/models/user_profile_decorator'
      end

      config.assets.precompile << %w(admin.scss)
      config.assets.precompile << %w(biovision/base/icons/*)
      config.assets.precompile << %w(biovision/base/placeholders/*)
      config.assets.precompile << %w(biovision/vote/icons/*)
    end

    require 'biovision/base'
    require 'biovision/vote'
    require 'biovision/poll'
    require 'biovision/comment'
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
