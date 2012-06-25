require "spec_helper"

describe BestBoyEvent, 'with creating' do
  it "should have valid model" do
    example = Example.create
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
  def setup_data_aggreagations times, created_at
    ActiveRecord::Base.connection.execute("DELETE FROM 'best_boy_events'")
    example = Example.create
    (1..times).each do
      example.trigger_best_boy_event("year_test")
      example.best_boy_events.last.update_attribute(:created_at, created_at)
    end
  end

  it "should return correct per_year scope" do
    setup_data_aggreagations 3, Time.now - 2.years
    BestBoyEvent.per_year(Time.now - 2.years).count.should eql(3)
    BestBoyEvent.per_year(Time.now - 2.years).last.created_at.to_date.year.should eql((Time.now - 2.years).year)
  end

  it "should return correct per_month scope" do
    setup_data_aggreagations 4, Time.now - 2.month
    BestBoyEvent.per_month(Time.now - 2.month).count.should eql(4)
    BestBoyEvent.per_month(Time.now - 2.month).last.created_at.to_date.month.should eql((Time.now - 2.month).month)
  end

  it "should return correct per_week scope" do
    setup_data_aggreagations 5, Time.now - 2.weeks
    BestBoyEvent.per_week(Time.now - 2.weeks).count.should eql(5)
  end

  it "should return correct per_month scope" do
    setup_data_aggreagations 7, Time.now - 2.days
    BestBoyEvent.per_day(Time.now - 2.days).count.should eql(7)
    BestBoyEvent.per_day(Time.now - 2.days).last.created_at.to_date.day.should eql((Time.now - 2.days).day)
  end

  it "should return 0 for wrong dates" do
    setup_data_aggreagations 5, Time.now - 2.weeks
    BestBoyEvent.per_year(Time.now - 2.years).count.should eql(0)
    BestBoyEvent.per_month(Time.now - 2.month).count.should eql(0)
    BestBoyEvent.per_week(Time.now - 3.weeks).count.should eql(0)
    BestBoyEvent.per_day(Time.now - 2.days).count.should eql(0)
  end
end