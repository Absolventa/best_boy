require "best_boy/engine.rb"

module BestBoy
  def self.setup
    yield self
  end
end