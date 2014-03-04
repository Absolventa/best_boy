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
end
