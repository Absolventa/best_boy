require "spec_helper"

describe BestBoyController do
  include BestBoyController::InstanceMethods

  before(:each) do
    @example = TestEvent.create
  end

  it 'sends valid custom event' do
    best_boy_event @example, "testing"
    best_boy = BestBoyEvent.where(owner_id: @example.id, owner_type: @example.class.name, event: 'testing').first
    expect(best_boy).not_to be_nil
  end

  it 'raises error on empty event_phrase' do
    expect { best_boy_event(@example, "") }.to raise_error
  end

  it 'raises error on class not beeing a eventable' do
    klass = Object.new
    expect { best_boy_event(klass, "testing") }.to raise_error
  end
end
