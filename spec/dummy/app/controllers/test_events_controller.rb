class TestEventsController < ApplicationController

  def index
    te = TestEvent.create
    best_boy_event te, "test_event", "test_source"
    te.destroy
  end

end