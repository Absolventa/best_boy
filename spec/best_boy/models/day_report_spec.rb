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
    it { expect(subject).to belong_to(:month_report) }
  end

  context "with validations" do
    it "validates presence of attributes" do
      expect(subject).to validate_presence_of(:month_report_id)
      expect(subject).to validate_presence_of(:eventable_type)
      expect(subject).to validate_presence_of(:event_type)
    end
  end

  context "with scopes" do
    it "aggregates DayReports of specific day" do
      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(day_report)
      expect(collection.created_on(1.day.ago)).to_not include(day_report)
    end

    it "aggregates DayReports of last week" do
      report_from_last_week = BestBoy::DayReport.create({eventable_type: "Example", event_type: "create"}).tap { |e| e.created_at = 8.days.ago; e.save }
      report_from_this_week = BestBoy::DayReport.create({eventable_type: "Example", event_type: "create", month_report_id: month_report.id })

      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.week).to include(report_from_this_week)
      expect(collection.week).not_to include(report_from_last_week)
    end

  end

  context "with class methods" do
    describe "#current_for" do
      context "when day_report exists" do
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
        eventable            = Example.create
        existing_report      = BestBoy::DayReport.create_for(eventable.class.to_s, "create")
        existing_with_source = BestBoy::DayReport.create_for(eventable.class.to_s, "create", "api")

        demanded             = BestBoy::DayReport.current_or_create_for(eventable.class.to_s, "create")
        demanded_with_source = BestBoy::DayReport.current_or_create_for(eventable.class.to_s, "create", "api")

        it { expect(demanded).to be_eql existing_report }
        it { expect(demanded_with_source).to be_eql existing_with_source }
      end

      context "when no today's day_report is present" do
        it "creates a new month_report" do
          BestBoy::DayReport.destroy_all
          scope = BestBoy::DayReport.where(eventable_type: Example.to_s, event_type: "create")
          expect{ BestBoy::DayReport.current_or_create_for(eventable.class.to_s, "create") }.to change(scope.created_on(Time.now), :count).by(1)
        end
      end
    end

    describe "#create_for" do
      eventable          = Example.create
      report             = BestBoy::DayReport.create_for(eventable.class.to_s, "create")
      report_with_source = BestBoy::DayReport.create_for(eventable.class.to_s, "create", "api")

      it { expect(report).to be_valid }
      it { expect(report.eventable_type).to be_eql(eventable.class.to_s) }
      it { expect(report.event_source).to be_nil }

      it { expect(report_with_source).to be_valid }
      it { expect(report_with_source.eventable_type).to be_eql(eventable.class.to_s) }
      it { expect(report_with_source.event_source).to be_eql("api") }
    end
  end
end
