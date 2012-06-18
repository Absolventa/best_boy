require "best_boy"
require "rails"

module BestBoy
  class Engine < Rails::Engine

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
