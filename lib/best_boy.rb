require "best_boy/engine.rb"

module BestBoy
  mattr_accessor :base_controller, :before_filter, :custom_redirect, :orm,
    :precompile_assets, :skip_after_filter, :skip_before_filter, :test_mode

  @@base_controller    = "ApplicationController"
  @@before_filter      = nil
  @@custom_redirect    = nil
  @@orm                = :active_record
  @@precompile_assets  = false
  @@skip_after_filter  = nil
  @@skip_before_filter = nil
  @@test_mode          = false

  # Load configuration from initializer
  def self.setup
    yield self
  end

  def self.in_test_mode(&block)
    executute_with_test_mode_set_to(true, &block)
  end

  def self.in_real_mode(&block)
    executute_with_test_mode_set_to(false, &block)
  end

  private

  def self.executute_with_test_mode_set_to(test_mode, &block)
    Mutex.new.synchronize do
      test_mode_before = self.test_mode
      self.test_mode = test_mode
      block.call if block.present?
      self.test_mode = test_mode_before
    end
  end

end
