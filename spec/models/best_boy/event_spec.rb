require 'spec_helper'

describe BestBoy::Event do
  let(:owner) { TestResource.create }

  context 'with associations' do
    it { expect(subject).to belong_to(:owner) }
  end

  context 'with validations' do
    it 'requires an event' do
      expect(subject).to validate_presence_of :event
    end
  end

  it 'creates a valid model' do
    subject = described_class.create(event: 'some random event type', owner: owner)
    expect(subject).to be_valid
    expect(subject).to be_persisted
  end

  it_behaves_like 'Short-circuits saving in test mode'

  describe ".per_day" do
    it 'includes event created right now' do
      brand_new = described_class.create(event: 'create')
      expect(described_class.per_day(Date.today)).
        to include brand_new
    end

    it 'exlucdes events created yesterday' do
      old_buddy = described_class.new(event: 'create')
      old_buddy.created_at = 1.day.ago
      old_buddy.save
      expect(described_class.per_day(Date.today)).
         not_to include old_buddy
    end
  end
end
