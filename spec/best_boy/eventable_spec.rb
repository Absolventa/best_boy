require "spec_helper"

describe BestBoy::Eventable do
  before(:each) do
    @example = Example.create
  end

  it "should send valid create event" do
    best_boy_event = @example.best_boy_events.first.should_not be_nil
  end

  it "should send valid destroy event" do
    @example.destroy
    BestBoyEvent.where(:owner_type => "User", :event => "destroy").should_not be_nil
  end

  it "should be an eventable" do
    @example.respond_to?("eventable?").should eql(true)
  end

  context "with reporting" do
    let(:month_report) do
      BestBoy::MonthReport.where(
        eventable_id: @example.id,
        eventable_type: @example.class,
        event_type: 'create'
      ).first
    end
    let(:day_report) do
      BestBoy::DayReport.where(
        eventable_id: @example.id,
        eventable_type: @example.class,
        event_type: 'create'
      ).first
    end
    it "loads reports" do
      expect(month_report).to be_present
      expect(day_report).to be_present
    end

    it "increases occurence counter when a new instance is created" do
      BestBoy::MonthReport.any_instance.should_receive(:increment).and_return(true)
      BestBoy::DayReport.any_instance.should_receive(:increment).and_return(true)
      Example.create
    end

    it "increases occurence counter when an instance is destroyed" do
      BestBoy::MonthReport.any_instance.should_receive(:increment).and_return(true)
      BestBoy::DayReport.any_instance.should_receive(:increment).and_return(true)
      Example.first.destroy
    end
  end
end
