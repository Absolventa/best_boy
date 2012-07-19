module BestBoy
  module Generators
    class BestBoyGenerator < Rails::Generators::Base
      hook_for :orm
      source_root File.expand_path('../templates', __FILE__)

      class_option :asset_pipeline, :type => :string, :aliases => "-a", :desc => "skip template creation due asset pipeline use", :default => "asset"
      class_option :asset, :type => :boolean, :default => false

      def copy_config_file
        template 'best_boy.rb', 'config/initializers/best_boy.rb'
        if not options[:asset_pipeline] == "asset" or not options[:asset]
          template 'bootstrap/glyphicons-halflings-white.png', 'public/images/bootstrap/glyphicons-halflings-white.png'
          template 'bootstrap/glyphicons-halflings.png', 'public/images/bootstrap/glyphicons-halflings.png'
          template 'bootstrap/bootstrap.css', 'public/stylesheets/bootstrap.css'
          #datepicker by Stefan Petre (http://www.eyecon.ro/bootstrap-datepicker)
          template 'bootstrap/bootstrap_datepicker.css', 'public/stylesheets/bootstrap_datepicker.css' 
          template 'bootstrap/bootstrap_datepicker.js', 'public/javascripts/bootstrap_datepicker.js'
        end
      end
    end
  end
end
