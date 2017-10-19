require 'spec_helper'

describe BestBoy::MonthReport do

  let(:owner) { TestEvent.create }
  let(:month_report) do
    BestBoy::MonthReport.create(
      owner_type: owner.class.to_s,
      event:     'create'
    )
  end

  subject { month_report }

  context 'with associations' do
    it { expect(subject).to have_many(:day_reports) }
  end

  context 'with validations' do
    it { expect(subject).to validate_presence_of(:owner_type) }
    it { expect(subject).to validate_presence_of(:event) }
  end

  it_behaves_like 'Short-circuits saving in test mode'

  context 'with scopes' do
    it 'aggregates MonthReports of specific month' do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.between(Time.now.beginning_of_month, Time.now)).to include(month_report)
      expect(collection.between(2.month.ago.beginning_of_month, 2.month.ago)).to_not include(month_report)
    end

    it 'aggregates MonthReports of specific month period' do
      report_from_first_month = BestBoy::MonthReport.create(owner_type: 'TestEvent', event: 'create').tap { |e| e.created_at = 2.month.ago; e.save }
      report_from_last_month  = BestBoy::MonthReport.create(owner_type: 'TestEvent', event: 'create').tap { |e| e.created_at = 1.month.ago }

      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.between(3.month.ago, Time.now)).to include(report_from_first_month)
      expect(collection.between(3.month.ago, Time.now)).to include(report_from_last_month)
      expect(collection.between(1.month.ago, Time.now)).to_not include(report_from_first_month)
      expect(collection.between(3.month.ago, 2.month.ago)).to_not include(report_from_last_month)
      expect(collection.between(6.month.ago, 4.month.ago)).to_not include(report_from_last_month)
    end

    it 'aggregates MonthReports of specific day' do
      collection = BestBoy::MonthReport.order('created_at DESC')
      expect(collection.created_on(Time.now)).to include(month_report)
      expect(collection.created_on(1.day.ago)).to_not include(month_report)
    end
  end

  context 'with class methods' do
    describe '.current_for' do
      context 'when day_report exists' do
        it 'returns existing day report without source' do
          existing_report = BestBoy::MonthReport.create_for('TestEventClass', 'create')
          demanded        = BestBoy::MonthReport.current_for(Time.now, 'TestEventClass', 'create').last
          expect(demanded).to eql existing_report
        end

        it 'returns existing day report with source' do
          existing_report = BestBoy::MonthReport.create_for('TestEventClass', 'create', 'api')
          demanded        = BestBoy::MonthReport.current_for(Time.now, 'TestEventClass', 'create', 'api').last
          expect(demanded).to eql existing_report
        end

        context "when no today's day_report is present" do
          it 'delivers empty ActiceRecord::Relation' do
            expect(BestBoy::MonthReport.current_for(Time.now, 'GibberishClass', 'create')).to be_empty
          end
        end
      end
    end

    describe '.current_or_create_for' do
      context 'when month_report exists' do
        it 'returns existing month report without source' do
          existing_report = BestBoy::MonthReport.create_for(owner.class.to_s, 'create')
          demanded        = BestBoy::MonthReport.current_or_create_for(owner.class.to_s, 'create')
          expect(demanded).to eql existing_report
        end

        it 'returns existing month report with source' do
          existing_report = BestBoy::MonthReport.create_for(owner.class.to_s, 'create', 'api')
          demanded        = BestBoy::MonthReport.current_or_create_for(owner.class.to_s, 'create', 'api')
          expect(demanded).to eql existing_report
        end
      end

      context 'when no month_report is present' do
        it 'creates a report without source' do
          report = BestBoy::DayReport.create_for(owner.class.to_s, 'create')
          expect(report).to be_valid
          expect(report.owner_type).to eql owner.class.name
          expect(report.event_source).to be_nil
        end

        it 'creates a new month_report' do
          BestBoy::MonthReport.destroy_all
          scope = BestBoy::MonthReport.where(owner_type: TestEvent.to_s, event: 'create')
          expect(scope.between(Time.now.beginning_of_month, Time.now)).to be_empty
          expect { BestBoy::MonthReport.current_or_create_for(owner.class.to_s, 'create') }.
            to change(scope.between(Time.now.beginning_of_month, Time.now), :count).by(1)
        end
      end
    end

    describe '.create_for' do
      let(:report) { BestBoy::MonthReport.create_for(owner.class, 'create') }
      let(:report_with_source) { BestBoy::MonthReport.create_for(owner.class.to_s, 'create', 'api') }

      it { expect(report).to be_valid }
      it { expect(report_with_source).to be_valid }

      it { expect(report.owner_type).to be_eql(owner.class.to_s) }
      it { expect(report_with_source.owner_type).to be_eql(owner.class.to_s) }

      it { expect(report.event).to be_eql('create') }
      it { expect(report_with_source.event).to be_eql('create') }

      it { expect(report.event_source).to be_nil }
      it { expect(report_with_source.event_source).to eql 'api' }
    end
  end
end
