module Comunit
  module Base
    require 'biovision/base'
    require 'biovision/regions'
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

    class Engine < ::Rails::Engine
      initializer 'comunit_base.load_base_methods' do
        require_dependency 'biovision/regions/privilege_methods'
        require_dependency 'comunit/base/decorators/models/region_decorator'

        ActiveSupport.on_load(:action_controller) do
          include Biovision::Regions::PrivilegeMethods
        end
      end

      config.assets.precompile << %w(admin.scss)
      config.assets.precompile << %w(comunit/base/**/*)
      config.assets.precompile << %w(biovision/base/**/*)
      config.assets.precompile << %w(biovision/regions/placeholders/*)
      config.assets.precompile << %w(biovision/vote/icons/*)

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end
    end
  end
end
