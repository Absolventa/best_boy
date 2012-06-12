require "best_boy"
require "rails"

module BestBoy
  class Engine < Rails::Engine
    initializer 'best_boy.model' do |app|
      require "#{root}/app/models/best_boy/best_boy_events.rb"
      require "best_boy/models/best_boy.rb"
      ActiveRecord::Base.send(:include, BestBoy)
    end

    initializer 'best_boy.controller' do
      ActiveSupport.on_load(:action_controller) do
        include BestBoyController::InstanceMethods
        extend BestBoyController::ClassMethods
      end
    end
  end
end