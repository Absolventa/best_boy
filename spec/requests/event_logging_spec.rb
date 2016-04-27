require 'spec_helper'

describe "Testing Event Logging", type: :request do

  include_context 'ensure commit hooks on save'

  describe "events calling" do
    before do
      # Manually trigger after_commit hook
      allow_any_instance_of(TestEvent).to receive(:save).and_wrap_original { |method, _| method.call; method.receiver.run_callbacks(:commit) }
    end

    it "creates 3 test events" do
      expect{ get root_path }.to change { BestBoy::Event.count }.by(3)
    end

    it "explictly creates a custom event with a custom event source" do
      expect { get root_path }.to change { BestBoy::Event.where(event: 'test_event', event_source: 'test_source').count }.by(1)
    end
  end
end
