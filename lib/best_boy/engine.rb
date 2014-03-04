require "best_boy"
require "rails"
require "google_visualr"

module BestBoy
  class Engine < ::Rails::Engine

    initializer 'best_boy.assets', group: :all do |app|
      initializer_path = "#{Rails.root}/config/initializers/best_boy.rb"
      require initializer_path if File.exist? initializer_path

      if BestBoy.precompile_assets == true
        Rails.application.config.assets.precompile += ['best_boy/best_boy.css', 'best_boy/best_boy.js']
      end
    end

    initializer 'best_boy.model' do |app|
      if BestBoy.orm == :active_record
        require "best_boy/models/active_record/best_boy_event.rb"
        require "best_boy/models/active_record/best_boy/eventable.rb"
        require "best_boy/models/active_record/best_boy/day_report.rb"
        require "best_boy/models/active_record/best_boy/month_report.rb"
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
