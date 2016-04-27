shared_context 'ensure commit hooks' do
  before do
    allow_any_instance_of(TestEvent).to receive(:destroy).and_wrap_original { |method, args| method.call && method.receiver.send(:committed!) }
    allow_any_instance_of(TestEvent).to receive(:save).and_wrap_original { |method, args| method.call && method.receiver.send(:committed!) }
  end
end
