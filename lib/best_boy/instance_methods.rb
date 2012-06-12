module InstanceMethods
  def create_best_boy_event type
    self.best_boy_events.create(:event => type)
  end
end