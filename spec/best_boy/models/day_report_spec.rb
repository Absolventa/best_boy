require 'spec_helper'

describe BestBoy::DayReport do

  let(:eventable) { Example.create }
  let(:month_report) do
    BestBoy::MonthReport.create({
      eventable_type: eventable.class.to_param,
      event_type:     "create"
    })
  end
  let(:day_report) do
     BestBoy::DayReport.create({
      eventable_type:  eventable.class.to_param,
      event_type:      "create",
      month_report_id: month_report.to_param
    })
  end

  subject { day_report }

  context "with associations" do
    it { should belong_to(:month_report) }
  end

  context "with validations" do
    it "validates presence of attributes" do
      should validate_presence_of(:month_report_id)
      should validate_presence_of(:eventable_type)
      should validate_presence_of(:event_type)
    end
  end

  context "with scopes" do
    it "aggregates DayReports of specific day" do
      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(day_report)
      expect(collection.created_on(1.day.ago)).to_not include(day_report)
    end
  end

  context "with instance methods" do
    describe "#closed?" do
      it "is not closed if it is the youngest DayReport for the eventable" do
        day_report
        expect(day_report.closed?).to be_false
      end

      it "is closed if it is not the youngest DayReport" do
        newer_day_report = BestBoy::DayReport.new(
          eventable_type: day_report.eventable_type,
          month_report_id: month_report.to_param,
          event_type: day_report.event_type)
        newer_day_report.save
        expect(day_report.closed?).to be_true
      end
    end
  end

  context "with class methods" do
    describe "#create_for" do
      eventable = Example.create
      report = BestBoy::DayReport.create_for(eventable, "create")

      it { expect(report).to be_valid }
      it { expect(report.eventable_type).to be_eql(eventable.class.to_s) }
    end

    describe "#current_for" do
      context "when day_report exists" do
        eventable = Example.create
        existing_report = BestBoy::DayReport.create_for(eventable, "create")
        demanded = BestBoy::DayReport.current_for(eventable, "create")
        it { expect(demanded).to be_eql existing_report }
      end

      context "when no today's day_report is present" do
        it "creates a new month_report" do
          BestBoy::DayReport.destroy_all
          scope = BestBoy::DayReport.where(eventable_type: Example.to_s, event_type: "create")

          expect(scope.today).to be_empty
          expect{ BestBoy::DayReport.current_for(eventable, "create") }.to change(scope.today, :count).by(1)
        end
      end
    end
  end
end
