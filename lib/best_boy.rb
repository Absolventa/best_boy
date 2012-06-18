require "best_boy/engine.rb"

module BestBoy
  # Define ORM
  mattr_accessor :orm, :base_controller, :before_filter, :skip_before_filter, :custom_redirect
  @@orm = :active_record
  @@base_controller = "ApplicationController"
  @@before_filter = nil
  @@skip_before_filter = nil
  @@custom_redirect = nil

  # Load configuration from initializer
  def self.setup
    yield self
  end
end
