# frozen_string_literal: true
require 'haml'
require 'kaminari'
require "best_boy/engine"
require "best_boy/eventable"
require "best_boy/obeys_test_mode"
require "best_boy/reporting"

module BestBoy
  mattr_accessor :base_controller, :before_filter, :custom_redirect, :skip_after_filter, :skip_before_filter, :test_mode

  @@base_controller    = "ApplicationController"
  @@before_filter      = nil
  @@custom_redirect    = nil
  @@skip_after_filter  = nil
  @@skip_before_filter = nil
  @@test_mode          = false

  # Load configuration from initializer
  def self.setup
    yield self
  end

  def self.in_test_mode(&block)
    execute_with_test_mode_set_to(true, &block)
  end

  def self.in_real_mode(&block)
    execute_with_test_mode_set_to(false, &block)
  end

  private

  def self.execute_with_test_mode_set_to(test_mode, &block)
    Mutex.new.synchronize do
      test_mode_before = self.test_mode
      self.test_mode = test_mode
      block.call if block.present?
      self.test_mode = test_mode_before
    end
  end

end
