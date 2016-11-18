# frozen_string_literal: true
module BestBoy
  module Reporting
    extend ActiveSupport::Concern

    included do
      class << self

        def current_for(date, owner, type, source = nil)
          self.for(owner, type, source).created_on(date)
        end

        def current_or_create_for(owner, type, source = nil, date = Time.zone.now)
          report = current_for(date, owner, type, source).last
          report.present? ? report : create_for(owner, type, source, date)
        end

        def for(owner, type, source = nil)
          where(owner_type: owner, event: type, event_source: source)
        end

      end
    end

  end
end
