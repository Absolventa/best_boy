module BestBoy
  module Generators
    class BestBoyGenerator < Rails::Generators::Base
      hook_for :orm
      source_root File.expand_path('../templates', __FILE__)

      def copy_config_file
        template 'best_boy.rb', 'config/initializers/best_boy.rb'
        template 'bootstrap/glyphicons-halflings-white.png', 'public/images/bootstrap/glyphicons-halflings-white.png'
        template 'bootstrap/glyphicons-halflings.png', 'public/images/bootstrap/glyphicons-halflings.png'
        template 'bootstrap/bootstrap.css', 'public/stylesheets/bootstrap.css'  
      end
    end
  end
end
