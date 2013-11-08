require 'spec_helper'

describe BestBoy::DayReport do

  let(:owner) { TestEvent.create }
  let(:month_report) do
    BestBoy::MonthReport.create({
      owner_type: owner.class.to_param,
      event:     "create"
    })
  end
  let(:day_report) do
     BestBoy::DayReport.create({
      owner_type:  owner.class.to_param,
      event:      "create",
      month_report_id: month_report.to_param
    })
  end

  subject { day_report }

  context "with associations" do
    it { expect(subject).to belong_to(:month_report) }
  end

  context "with validations" do
    it "validates presence of attributes" do
      expect(subject).to validate_presence_of(:month_report_id)
      expect(subject).to validate_presence_of(:owner_type)
      expect(subject).to validate_presence_of(:event)
    end
  end

  context "with scopes" do
    it "aggregates DayReports of specific day" do
      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(day_report)
      expect(collection.created_on(1.day.ago)).to_not include(day_report)
    end

    it "aggregates DayReports of last week" do
      Time.zone = "Berlin"

      report_from_last_week = BestBoy::DayReport.create({owner_type: "TestEvent", event: "create"}).tap { |e| e.created_at = 8.days.ago; e.save }
      report_from_this_week = BestBoy::DayReport.create({owner_type: "TestEvent", event: "create", month_report_id: month_report.id })

      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.week).to include(report_from_this_week)
      expect(collection.week).not_to include(report_from_last_week)
    end

  end

  context "with class methods" do
    describe "#current_for" do
      context "when day_report exists" do
        Time.zone = "Berlin"

        existing_report      = BestBoy::DayReport.create_for("ExampleClass", "create")
        existing_with_source = BestBoy::DayReport.create_for("ExampleClass", "create", "api")

        demanded             = BestBoy::DayReport.current_for(Time.now, "ExampleClass", "create").last
        demanded_with_source = BestBoy::DayReport.current_for(Time.now, "ExampleClass", "create", "api").last

        it { expect(demanded).to be_eql existing_report }
        it { expect(demanded_with_source).to be_eql existing_with_source }
      end

      context "when no today's day_report is present" do
        it "delivers empty ActiceRecord::Relation" do
          expect(BestBoy::DayReport.current_for(Time.now, "GibberishClass", "create")).to be_empty
        end
      end

    end

    describe "#current_or_create_for" do
      context "when day_report exists" do
        Time.zone = "Berlin"

        owner               = TestEvent.create
        existing_report      = BestBoy::DayReport.create_for(owner.class.to_s, "create")
        existing_with_source = BestBoy::DayReport.create_for(owner.class.to_s, "create", "api")

        demanded             = BestBoy::DayReport.current_or_create_for(owner.class.to_s, "create")
        demanded_with_source = BestBoy::DayReport.current_or_create_for(owner.class.to_s, "create", "api")

        it { expect(demanded).to be_eql existing_report }
        it { expect(demanded_with_source).to be_eql existing_with_source }
      end

      context "when no today's day_report is present" do
        it "creates a new month_report" do
          BestBoy::DayReport.destroy_all
          scope = BestBoy::DayReport.where(owner_type: TestEvent.to_s, event: "create")
          expect{ BestBoy::DayReport.current_or_create_for(owner.class.to_s, "create") }.to change(scope.created_on(Time.now), :count).by(1)
        end
      end
    end

    describe "#create_for" do
      owner          = TestEvent.create
      report             = BestBoy::DayReport.create_for(owner.class.to_s, "create")
      report_with_source = BestBoy::DayReport.create_for(owner.class.to_s, "create", "api")

      it { expect(report).to be_valid }
      it { expect(report.owner_type).to be_eql(owner.class.to_s) }
      it { expect(report.event_source).to be_nil }

      it { expect(report_with_source).to be_valid }
      it { expect(report_with_source.owner_type).to be_eql(owner.class.to_s) }
      it { expect(report_with_source.event_source).to be_eql("api") }
    end
  end
end
