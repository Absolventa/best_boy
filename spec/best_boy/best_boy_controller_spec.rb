require "spec_helper"

describe BestBoyController do
  before(:each) do
    @example = Example.create
  end

  it "should send valid custom event" do
    best_boy_event @example, "testing"
    BestBoyEvent.where(:owner_id => @example.id, :owner_type => @example.class.name.to_s, :event => "testing").first.should_not be_nil
  end

  it "should raise error on empty event_phrase" do
    expect {best_boy_event(@example, "")}.should raise_error
  end

  it "should raise error on class not beeing a eventable" do
    klass = Dummy.new
    expect {best_boy_event(klass, "testing")}.should raise_error
  end
end