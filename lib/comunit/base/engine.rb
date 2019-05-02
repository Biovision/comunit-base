module Comunit
  module Base
    require 'biovision/base'
    require 'biovision/vote'
    # require 'biovision/poll'
    require 'biovision/comment'
    require 'redis-namespace'
    require 'carrierwave'
    require 'elasticsearch/persistence'
    require 'elasticsearch/model'
    require 'mini_magick'
    require 'carrierwave-bombshelter'
    require 'rest-client'

    class Engine < ::Rails::Engine
      initializer 'comunit_base.load_base_methods' do
        require_dependency 'comunit/base/privilege_methods'
        require_dependency 'comunit/base/decorators/controllers/admin/privileges_controller_decorator'
        require_dependency 'comunit/base/decorators/models/user_decorator'
        require_dependency 'comunit/base/decorators/models/user_privilege_decorator'

        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::PrivilegeMethods
        end
      end

      config.assets.precompile << %w[admin.scss]
      config.assets.precompile << %w[biovision/base/**/*]
      config.assets.precompile << %w[biovision/vote/icons/*]
      config.assets.precompile << %w[comunit/base/**/*]

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end
    end
  end
end
