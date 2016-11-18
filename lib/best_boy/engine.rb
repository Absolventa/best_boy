# frozen_string_literal: true
module BestBoy
  class Engine < ::Rails::Engine
    isolate_namespace BestBoy

    initializer 'best_boy.assets.precompile', group: :all do |app|
      Rails.application.config.assets.precompile += ['best_boy/best_boy.css', 'best_boy/best_boy.js']
    end

    initializer 'best_boy.model' do |app|
      require "best_boy/obeys_test_mode.rb"
      require "best_boy/reporting.rb"
      require "best_boy/eventable.rb"
    end

    initializer 'best_boy.controller' do
      require "best_boy/controller.rb"
    end
  end
end
