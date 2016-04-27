shared_context 'ensure commit hooks on save' do
  before do
    allow_any_instance_of(TestEvent).to receive(:save).and_wrap_original { |method, _| method.call; method.receiver.run_callbacks(:commit) }
  end
end
