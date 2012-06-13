require "spec_helper"

describe BestBoy::Eventable do
  before(:each) do
    @user = User.create
  end

  it "should send valid create event" do
    best_boy_event = @user.best_boy_events.first.should_not be_nil
  end

  it "should send valid destroy event" do
    @user.destroy
    BestBoyEvent.where(:owner_type => "User", :event => "destroy").should_not be_nil
  end

  it "should be an eventable" do
    @user.respond_to?("eventable?").should eql(true)
  end
end