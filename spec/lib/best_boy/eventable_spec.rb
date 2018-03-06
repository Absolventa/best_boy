require "spec_helper"

describe BestBoy::Eventable do
  let(:owner) { TestResource.new }

  context 'with callbacks' do
    context 'within real mode' do
      it 'sends a valid create event' do
        expect { owner.save }.to change { BestBoy::Event.count }.by(1)
        expect(owner.best_boy_events).to eq [BestBoy::Event.last]
      end

      it 'sends a valid destroy event' do
        owner.save
        expect { owner.destroy }.to change { BestBoy::Event.count }.by(1)
        best_boy_event = BestBoy::Event.where(event: 'destroy').last
        expect(best_boy_event.owner_type).to eql owner.class.name
        expect(best_boy_event.owner_id).to eql owner.id
      end
    end

    context 'within test mode' do
      it 'does not create a BestBoy create event' do
        BestBoy.in_test_mode do
          expect { owner.save }.not_to change { BestBoy::Event.count }
        end
      end

      it 'does not create a BestBoy destroy event' do
        owner.save
        BestBoy.in_test_mode do
          expect { owner.destroy }.not_to change { BestBoy::Event.count }
        end
      end
    end

  end

  describe '.best_boy_disable_callbacks' do
    it { expect(owner.class).to respond_to :best_boy_disable_callbacks }
    it { expect(owner.class).to respond_to :best_boy_disable_callbacks= }

    it 'enables best boy callbacks by default' do
      klass.has_a_best_boy
      expect(klass.best_boy_disable_callbacks).to be_falsey
    end

    it 'sets callbacks to be disabled' do
      klass.has_a_best_boy disable_callbacks: true
      expect(klass.best_boy_disable_callbacks).to eql true
    end

    def klass
      @klass ||= Class.new do
        class << self
          def has_many(*args); end
          alias :after_create  :has_many
          alias :after_destroy :has_many
        end
        include BestBoy::Eventable
      end
    end

  end

  context 'with reporting' do
    let(:month_report) do
      BestBoy::MonthReport.where(
        owner_type: owner.class.to_s,
        event: 'create'
      ).first
    end
    let(:day_report) do
      BestBoy::DayReport.where(
        owner_type: owner.class.to_s,
        event: 'create'
      ).first
    end

    it 'loads reports' do
      owner.save
      expect(month_report).to be_present
      expect(day_report).to be_present
    end

    it 'increases occurrence counter when a new instance is created' do
      expect_any_instance_of(BestBoy::MonthReport).to receive(:increment!)
      expect_any_instance_of(BestBoy::DayReport).to receive(:increment!)
      owner.save
    end

    it 'increases occurrence counter when an instance is destroyed' do
      owner.save
      expect_any_instance_of(BestBoy::MonthReport).to receive(:increment!)
      expect_any_instance_of(BestBoy::DayReport).to receive(:increment!)
      owner.destroy
    end
  end
end
