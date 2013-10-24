require 'spec_helper'

describe BestBoy::MonthReport do

  let(:eventable) { Example.create }
  let(:month_report) do
    BestBoy::MonthReport.create({
      eventable_id:   eventable.id,
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
      should validate_presence_of(:eventable_id)
      should validate_presence_of(:event_type)
    end
  end

  context "with scopes" do
    it "aggregates MonthReports of specific month" do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.month(Time.zone.now.month, Time.zone.now.year)).to include(month_report)
      expect(collection.month(2.month.ago.month, 2.month.ago.year )).to_not include(month_report)
    end
    it "aggregates MonthReports of specific day" do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.created_on(Time.zone.now)).to include(month_report)
      expect(collection.created_on(1.day.ago)).to_not include(month_report)
    end
  end

  context "with instance methods" do
    context "with delegations" do
      its(:month) { should == subject.created_at.month }
      its(:year) { should == subject.created_at.year }
    end

    describe "#closed?" do
      it "is not closed if no younger MonthReport for the eventable_id exists" do
        expect(month_report.closed?).to be_false
      end

      it "is closed if it is not the youngest MonthReport" do
        newer_month_report = BestBoy::MonthReport.new(eventable_type: month_report.eventable_type, eventable_id: month_report.eventable_id, event_type: month_report.event_type)
        newer_month_report.save
        expect(month_report.closed?).to be_true
      end
    end
  end

  context "with class methods" do
    describe "#create_for" do
      eventable = Example.create
      report = BestBoy::MonthReport.create_for(eventable, "create")

      it { expect(report).to be_valid }
      it { expect(report.eventable_id).to be_eql(eventable.id) }
      it { expect(report.eventable_type).to be_eql(eventable.class.to_s) }
      it { expect(report.event_type).to be_eql("create") }
    end

    describe "#current_for" do
      context "when month_report exists" do
        eventable = Example.create
        existing_report = BestBoy::MonthReport.create_for(eventable, "create")
        demanded = BestBoy::MonthReport.current_for(eventable, "create")
        it { expect(demanded).to be_eql existing_report }
      end

      context "when no today's day_report is present" do
        eventable = Example.create # important to be placed right her # important to be placed right heree
        scope = BestBoy::MonthReport.where(eventable_id: eventable.id, eventable_type: eventable.class.to_s, event_type: "create")
        mth = Time.now.month
        yr = Time.now.year

        it { expect(scope.month(mth, yr)).to be_empty }
        it { expect{ BestBoy::MonthReport.current_for(viewable) }.to change(scope.month(mth, yr), :count).by(1) }
      end
    end
  end
end
