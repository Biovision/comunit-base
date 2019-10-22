# frozen_string_literal: true

module Comunit
  module Base
    require 'biovision/base'
    require 'biovision/post'
    require 'biovision/vote'
    # require 'biovision/poll'
    require 'biovision/comment'
    require 'redis-namespace'
    require 'carrierwave'
    # require 'elasticsearch/persistence'
    # require 'elasticsearch/model'
    require 'mini_magick'
    require 'carrierwave-bombshelter'
    require 'rest-client'

    class Engine < ::Rails::Engine
      initializer 'comunit_base.load_base_methods' do
        require_dependency 'comunit/base/privilege_methods'
        require_dependency 'comunit/base/decorators/controllers/admin/privileges_controller_decorator'
        require_dependency 'comunit/base/decorators/controllers/posts_controller_decorator'
        require_dependency 'comunit/base/decorators/models/user_decorator'
        require_dependency 'comunit/base/decorators/models/user_privilege_decorator'
        require_dependency 'comunit/base/decorators/models/post_decorator'

        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::PrivilegeMethods
        end
      end

      components = %w[
        admin.scss biovision/base/**/* biovision/post/**/*
        biovision/vote/icons/* comunit/base/**/*
        comunit_base_manifest.js
      ]
      config.assets.precompile << components

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end
    end
  end
end
