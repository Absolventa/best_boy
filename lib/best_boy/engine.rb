require "best_boy"
require "rails"
require "google_visualr"

module BestBoy
  class Engine < Rails::Engine
    isolate_namespace BestBoy
    engine_name 'best_boy'

    initializer 'best_boy.assets' do |app|
      #if BestBoy.precompile_assets?
      Rails.application.config.assets.precompile += ['best_boy/best_boy.css', 'best_boy/best_boy.js']
      #end
      raise Rails.application.config.assets.precompile.inspect
    end

    initializer 'best_boy.model' do |app|
      if BestBoy.orm == :active_record
        require "best_boy/models/active_record/best_boy_event.rb"
        require "best_boy/models/active_record/best_boy/eventable.rb"
        ActiveRecord::Base.send(:include, BestBoy::Eventable)
      else
        raise "Sorry, best_boy actually only supports ActiveRecord ORM."
      end
      
    end

    initializer 'best_boy.controller' do
      require "best_boy/controllers/best_boy_controller.rb"
      ActiveSupport.on_load(:action_controller) do
        include BestBoyController::InstanceMethods
      end
    end
  end
end
