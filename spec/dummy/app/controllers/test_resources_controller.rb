class TestResourcesController < ApplicationController

  def index
    resource = TestResource.create
    best_boy_event resource, "test_event", "test_source"
    resource.destroy
  end

end
