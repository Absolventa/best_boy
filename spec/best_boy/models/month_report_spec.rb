require 'spec_helper'

describe BestBoy::MonthReport do

  let(:eventable) { Example.create }
  let(:month_report) do
    BestBoy::MonthReport.create({
      eventable_type: eventable.class.to_param,
      event_type:     "create"
    })
  end

  subject { month_report }

  describe "with associations" do
    it { should have_many(:day_reports) }
  end

  describe "with validations" do
    it "should validate presence of attributes" do
      should validate_presence_of(:eventable_type)
      should validate_presence_of(:event_type)
    end
  end

  context "with scopes" do
    it "aggregates MonthReports of specific month" do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.month(Time.now.month, Time.now.year)).to include(month_report)
      expect(collection.month(2.month.ago.month, 2.month.ago.year )).to_not include(month_report)
    end

    it "aggregates MonthReports of specific month period" do
      report_from_first_month = BestBoy::MonthReport.create({eventable_type: "Example", event_type: "create"}).tap { |e| e.created_at = 2.month.ago; e.save }
      report_from_last_month = BestBoy::MonthReport.create({eventable_type: "Example", event_type: "create"}).tap { |e| e.created_at = 1.month.ago }

      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.months(3.month.ago.month, Time.now.month, 3.month.ago.year, Time.now.year)).to include(report_from_first_month)
      expect(collection.months(3.month.ago.month, Time.now.month, 3.month.ago.year, Time.now.year)).to include(report_from_last_month)
      expect(collection.months(1.month.ago.month, Time.now.month, 1.month.ago.year, Time.now.year)).to_not include(report_from_first_month)
      expect(collection.months(3.month.ago.month, 2.month.ago.month, 3.month.ago.year, 2.month.ago.year )).to_not include(report_from_last_month)
      expect(collection.months(6.month.ago.month, 4.month.ago.month, 6.month.ago.year, 4.month.ago.year )).to_not include(report_from_last_month)
    end


    it "aggregates MonthReports of specific day" do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(month_report)
      expect(collection.created_on(1.day.ago)).to_not include(month_report)
    end
  end

  context "with instance methods" do
    describe "#closed?" do
      it "is not closed if no younger MonthReport for the eventable_id exists" do
        expect(month_report.closed?).to be_false
      end

      it "is closed if it is not the youngest MonthReport" do
        newer_month_report = BestBoy::MonthReport.new(eventable_type: month_report.eventable_type, event_type: month_report.event_type)
        newer_month_report.save
        expect(month_report.closed?).to be_true
      end
    end
  end

  context "with class methods" do
    describe "#create_for" do
      eventable = Example.create
      report = BestBoy::MonthReport.create_for(eventable.class, "create")

      it { expect(report).to be_valid }
      it { expect(report.eventable_type).to be_eql(eventable.class.to_s) }
      it { expect(report.event_type).to be_eql("create") }
    end

    describe "#current_for" do
      context "when month_report exists" do
        eventable = Example.create
        existing_report = BestBoy::MonthReport.create_for(eventable.class, "create")
        demanded = BestBoy::MonthReport.current_for(eventable.class, "create")
        it { expect(demanded).to be_eql existing_report }
      end

      context "when no month_report is present" do
        it "creates a new month_report" do
          BestBoy::MonthReport.destroy_all

          scope = BestBoy::MonthReport.where(
            eventable_type: Example.to_s,
            event_type: "create")
          mth = Time.now.month
          yr = Time.now.year

          expect(scope.month(mth, yr)).to be_empty
          expect{ BestBoy::MonthReport.current_for(eventable.class, "create") }.to change(scope.month(mth, yr), :count).by(1)
        end
      end
    end
  end
end
