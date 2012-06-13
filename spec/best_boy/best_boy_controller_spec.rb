require "spec_helper"

describe BestBoyController do
  before(:each) do
    @user = User.create
  end

  it "should send valid custom event" do
    best_boy_event @user, "testing"
    BestBoyEvent.where(:owner_id => @user.id, :owner_type => @user.class.name.to_s, :event => "testing").first.should_not be_nil
  end

  it "should raise error on empty event_phrase" do
    expect {best_boy_event(@user, "")}.should raise_error
  end

  it "should raise error on class not beeing a eventable" do
    klass = Dummy.new
    expect {best_boy_event(klass, "testing")}.should raise_error
  end
end