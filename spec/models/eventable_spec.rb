require "spec_helper"

describe BestBoy::Eventable do
  let(:owner) { TestEvent.new }

  it 'sends a valid create event' do
    expect { owner.save }.to change { BestBoyEvent.count }.by(1)
    expect(owner.best_boy_events).to eq [BestBoyEvent.last]
  end

  it 'sends a valid destroy event' do
    owner.save
    expect { owner.destroy }.to change { BestBoyEvent.count }.by(1)
    best_boy_event = BestBoyEvent.where(event: 'destroy').last
    expect(best_boy_event.owner_type).to eql owner.class.name
    expect(best_boy_event.owner_id).to eql owner.id
  end

  it 'is an eventable' do
    expect(owner).to respond_to :eventable?
  end

  context 'with reporting' do
    let(:month_report) do
      BestBoy::MonthReport.where(
        owner_type: owner.class,
        event: 'create'
      ).first
    end
    let(:day_report) do
      BestBoy::DayReport.where(
        owner_type: owner.class,
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
