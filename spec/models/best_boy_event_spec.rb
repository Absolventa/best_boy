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
