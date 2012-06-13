module BestBoy
  module Eventable
    extend ActiveSupport::Concern

    def eventable?
      true
    end

  end
end
