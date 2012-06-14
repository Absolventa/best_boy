require "spec_helper"

describe BestBoyEvent do
  it "should have valid model" do
    example = Example.create
    BestBoyEvent.create(:owner_id => example.id, :owner_type => example.class.name.to_s, :event => "create").should be_valid
  end

  it "should require a event" do
    BestBoyEvent.create(:event => "").should_not be_valid
  end

end