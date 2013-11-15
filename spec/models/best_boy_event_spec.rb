require "spec_helper"

describe BestBoyEvent, 'with creating' do
  it "should have valid model" do
    example = TestEvent.create
    best_boy_event = BestBoyEvent.create(:event => "create")
    best_boy_event.owner = example
    best_boy_event.should be_valid
  end
end

describe BestBoyEvent, 'with associations' do
  it { should belong_to(:owner) }
end

describe BestBoyEvent, 'with validations' do
  it "should require a event" do
    BestBoyEvent.create(:event => "").should_not be_valid
  end
end

describe BestBoyEvent, 'with scopes' do
  context "#per_day" do
    it "includes event created right now" do
      brand_new = BestBoyEvent.create(:event => "create")
      expect(BestBoyEvent.per_day(Date.today).include?(brand_new)).to be_true
    end
    it "exlucdes events created yesterday" do
      old_buddy = BestBoyEvent.new(:event => "create")
      old_buddy.created_at = 1.day.ago
      old_buddy.save
      expect(BestBoyEvent.per_day(Date.today).include?(old_buddy)).to be_false
    end
  end
end
