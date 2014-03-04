require 'spec_helper'

describe BestBoyController do
  include BestBoyController::InstanceMethods

  let(:test_event) { TestEvent.create }

  it 'sends valid custom event' do
    best_boy_event test_event, 'testing'
    best_boy = BestBoyEvent.where(owner_id: test_event.id, owner_type: test_event.class.name, event: 'testing').first
    expect(best_boy).not_to be_nil
  end

  it 'raises error on empty event_phrase' do
    expect { best_boy_event(test_event, '') }.to raise_error
  end

  it 'raises error on class not beeing an eventable' do
    klass = Object.new
    expect { best_boy_event(klass, 'testing') }.to raise_error
  end
end
