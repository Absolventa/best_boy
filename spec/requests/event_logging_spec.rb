require 'spec_helper'

describe "Testing Event Logging", type: :request do

  include_context 'ensure commit hooks'

  describe "events calling" do
    it "creates 3 test events" do
      expect{ get root_path }.to change { BestBoy::Event.count }.by(3)
    end

    it "explictly creates a custom event with a custom event source" do
      expect { get root_path }.to change { BestBoy::Event.where(event: 'test_event', event_source: 'test_source').count }.by(1)
    end
  end
end
