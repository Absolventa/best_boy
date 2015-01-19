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

        def create_for(owner, type, source = nil, date = Time.zone.now)
          month_report = BestBoy::MonthReport.current_or_create_for(owner, type, source, date)
          day_report   = BestBoy::DayReport.new

          day_report.owner_type      = owner
          day_report.event           = type
          day_report.month_report_id = month_report.id
          day_report.event_source    = source
          day_report.created_at      = date

          day_report.save ? day_report : nil
        end

        def for(owner, type, source = nil)
          where(owner_type: owner, event: type, event_source: source)
        end

      end
    end

  end
end
