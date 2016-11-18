# frozen_string_literal: true
module BestBoy
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template "config/initializers/best_boy.rb"
      end
    end
  end
end
