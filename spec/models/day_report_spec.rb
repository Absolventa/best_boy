require 'spec_helper'

describe BestBoy::DayReport do

  let(:owner) { TestEvent.create }

  let(:month_report) do
    BestBoy::MonthReport.create({
      owner_type: owner.class.to_param,
      event:     'create'
    })
  end

  let(:day_report) do
    BestBoy::DayReport.create({
      owner_type:  owner.class.to_param,
      event:      'create',
      month_report_id: month_report.to_param
    })
  end

  subject { day_report }

  context 'with associations' do
    it { expect(subject).to belong_to(:month_report) }
  end

  context 'with validations' do
    it { expect(subject).to validate_presence_of(:month_report_id) }
    it { expect(subject).to validate_presence_of(:owner_type) }
    it { expect(subject).to validate_presence_of(:event) }
  end

  it_behaves_like 'Short-circuits saving in test mode'

  context 'with scopes' do
    it 'aggregates DayReports of specific day' do
      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include subject
      expect(collection.created_on(1.day.ago)).to_not include subject
    end

    it 'aggregates DayReports of last week' do
      Time.zone = "Berlin"

      report_from_last_week = BestBoy::DayReport.create({owner_type: 'TestEvent', event: 'create'}).tap { |e| e.created_at = 8.days.ago; e.save }
      report_from_this_week = BestBoy::DayReport.create({owner_type: 'TestEvent', event: 'create', month_report_id: month_report.id })

      collection = BestBoy::DayReport.order('created_at DESC')
      expect(collection.week).to include report_from_this_week
      expect(collection.week).not_to include report_from_last_week
    end

  end

  describe '.current_for' do
    context 'when day_report exists' do
      Time.zone = 'Berlin'

      existing_report      = BestBoy::DayReport.create_for('ExampleClass', 'create')
      existing_with_source = BestBoy::DayReport.create_for('ExampleClass', 'create', 'api')

      demanded             = BestBoy::DayReport.current_for(Time.now, 'ExampleClass', 'create').last
      demanded_with_source = BestBoy::DayReport.current_for(Time.now, "ExampleClass", 'create', 'api').last

      it { expect(demanded).to be_eql existing_report }
      it { expect(demanded_with_source).to be_eql existing_with_source }
    end

    context "when no today's day_report is present" do
      it 'delivers empty ActiceRecord::Relation' do
        expect(BestBoy::DayReport.current_for(Time.now, 'GibberishClass', 'create')).to be_empty
      end
    end
  end

  describe '.current_or_create_for' do
    context 'when day_report exists' do

      it 'returns existing day report without source' do
        existing_report = BestBoy::DayReport.create_for(owner.class.to_s, 'create')
        demanded        = BestBoy::DayReport.current_or_create_for(owner.class.to_s, 'create')
        expect(demanded).to eql existing_report
      end

      it 'returns existing day report with source' do
        existing_report = BestBoy::DayReport.create_for(owner.class.to_s, 'create', 'api')
        demanded        = BestBoy::DayReport.current_or_create_for(owner.class.to_s, 'create', 'api')
        expect(demanded).to eql existing_report
      end
    end

    context "when no today's day report is present" do
      it 'creates a new day report' do
        BestBoy::DayReport.destroy_all
        scope = BestBoy::DayReport.where(owner_type: TestEvent.to_s, event: 'create')
        expect { BestBoy::DayReport.current_or_create_for(owner.class.to_s, 'create') }.
          to change { scope.created_on(Time.now).count }.by(1)
      end
    end
  end

  describe '.create_for' do
    it 'creates a report without source' do
      report = BestBoy::DayReport.create_for(owner.class.to_s, 'create')
      expect(report).to be_valid
      expect(report.owner_type).to eql owner.class.name
      expect(report.event_source).to be_nil
    end

    it 'creates a report with source' do
      report = BestBoy::DayReport.create_for(owner.class.to_s, 'create', 'api')
      expect(report).to be_valid
      expect(report.owner_type).to eql owner.class.name
      expect(report.event_source).to eql 'api'
    end
  end

end
