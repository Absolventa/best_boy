module BestBoy
  module Generators
    class BestBoyGenerator < Rails::Generators::Base
      hook_for :orm
      source_root File.expand_path('../templates', __FILE__)

      def copy_config_file
        template 'best_boy.rb', 'config/initializers/best_boy.rb'
      end
    end
  end
end
