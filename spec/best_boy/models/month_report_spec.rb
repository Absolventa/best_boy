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
    it { expect(subject).to have_many(:day_reports) }
  end

  describe "with validations" do
    it "validates presence of attributes" do
      expect(subject).to validate_presence_of(:eventable_type)
      expect(subject).to validate_presence_of(:event_type)
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
      expect(collection.between(3.month.ago, Time.now)).to include(report_from_first_month)
      expect(collection.between(3.month.ago, Time.now)).to include(report_from_last_month)
      expect(collection.between(1.month.ago, Time.now)).to_not include(report_from_first_month)
      expect(collection.between(3.month.ago, 2.month.ago)).to_not include(report_from_last_month)
      expect(collection.between(6.month.ago, 4.month.ago)).to_not include(report_from_last_month)
    end

    it "aggregates MonthReports of specific day" do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(month_report)
      expect(collection.created_on(1.day.ago)).to_not include(month_report)
    end
  end

  context "with class methods" do
    describe "#current_for" do
      context "when day_report exists" do
        existing_report      = BestBoy::MonthReport.create_for("ExampleClass", "create")
        existing_with_source = BestBoy::MonthReport.create_for("ExampleClass", "create", "api")

        demanded             = BestBoy::MonthReport.current_for(Time.now, "ExampleClass", "create").last
        demanded_with_source = BestBoy::MonthReport.current_for(Time.now, "ExampleClass", "create", "api").last

        it { expect(demanded).to be_eql existing_report }
        it { expect(demanded_with_source).to be_eql existing_with_source }
      end

      context "when no today's day_report is present" do
        it "delivers empty ActiceRecord::Relation" do
          expect(BestBoy::MonthReport.current_for(Time.now, "GibberishClass", "create")).to be_empty
        end
      end
    end

    describe "#current_or_create_for" do
      context "when month_report exists" do
        eventable            = Example.create
        existing_report      = BestBoy::MonthReport.create_for(eventable.class, "create")
        existing_with_source = BestBoy::MonthReport.create_for(eventable.class, "create", "api")

        demanded              = BestBoy::MonthReport.current_or_create_for(eventable.class, "create")
        demanded_with_source  = BestBoy::MonthReport.current_or_create_for(eventable.class, "create", "api")

        it { expect(demanded).to eql existing_report }
        it { expect(demanded_with_source).to eql existing_with_source }
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
          expect{ BestBoy::MonthReport.current_or_create_for(eventable.class, "create") }.to change(scope.month(mth, yr), :count).by(1)
        end
      end
    end

    describe "#create_for" do
      eventable          = Example.create
      report             = BestBoy::MonthReport.create_for(eventable.class, "create")
      report_with_source = BestBoy::MonthReport.create_for(eventable.class, "create", "api")

      it { expect(report).to be_valid }
      it { expect(report_with_source).to be_valid }

      it { expect(report.eventable_type).to be_eql(eventable.class.to_s) }
      it { expect(report_with_source.eventable_type).to be_eql(eventable.class.to_s) }

      it { expect(report.event_type).to be_eql("create") }
      it { expect(report_with_source.event_type).to be_eql("create") }

      it { expect(report.event_source).to be_nil }
      it { expect(report_with_source.event_source).to eql "api" }
    end
  end
end
