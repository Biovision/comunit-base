# frozen_string_literal: true

module Comunit
  module Base
    require 'dotenv-rails'
    require 'biovision/base'
    require 'biovision/vote'
    require 'biovision/comment'
    require 'rest-client'

    class Engine < ::Rails::Engine
      initializer 'comunit_base.load_base_methods' do
        require_dependency 'comunit/base/privilege_methods'
        load 'comunit/base/overrides/controllers/admin/privileges_controller_override'
        load 'comunit/base/overrides/models/user_override'

        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::PrivilegeMethods
        end
      end

      # components = %w[
      #   admin.scss biovision/base/**/* biovision/vote/icons/* comunit/base/**/*
      # ]
      # config.assets.precompile << components

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end
    end
  end
end
