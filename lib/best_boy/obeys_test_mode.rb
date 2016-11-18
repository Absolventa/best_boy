# frozen_string_literal: true
module BestBoy
  module ObeysTestMode
    def save(*args)
      BestBoy.test_mode || super
    end

    def save!(*args)
      BestBoy.test_mode || super
    end
  end
end
