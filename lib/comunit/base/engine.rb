# frozen_string_literal: true

module Comunit
  module Base
    require 'dotenv-rails'
    require 'biovision/base'
    require 'biovision/vote'
    require 'biovision/comment'
    require 'rest-client'

    class Engine < ::Rails::Engine
      initializer 'comunit_base.load_overrides' do
        require_dependency 'comunit/base/privilege_methods'
        ActiveSupport.on_load(:action_controller) do
          include Comunit::Base::PrivilegeMethods
        end

        engine_root = File.expand_path('../../../..', __FILE__)
        overrides_path = "#{engine_root}/app/overrides"

        Rails.autoloaders.main.ignore(overrides_path)
        Dir.glob("#{overrides_path}/**/*_override*.rb").each do |c|
          require_dependency(c)
        end
      end

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end
    end
  end
end
