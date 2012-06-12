module BestBoy
  module Eventable
    extend ActiveSupport::Concern

    module ClassMethods
      
    end

    def eventable?
      true
    end

  end
end
