require "best_boy/engine.rb"

module BestBoy
  # Define ORM
  mattr_accessor :orm
  @@orm = :active_record

  # Load configuration from initializer
  def self.setup
    yield self
  end
end
