require "best_boy/engine.rb"

module BestBoy
  # Define ORM
  mattr_accessor :precompile_assets, :orm, :base_controller, :before_filter,
                 :skip_before_filter, :skip_after_filter, :custom_redirect

  @@base_controller    = "ApplicationController"
  @@before_filter      = nil
  @@custom_redirect    = nil
  @@orm                = :active_record
  @@precompile_assets  = false
  @@skip_after_filter  = nil
  @@skip_before_filter = nil

  # Load configuration from initializer
  def self.setup
    yield self
  end
end
