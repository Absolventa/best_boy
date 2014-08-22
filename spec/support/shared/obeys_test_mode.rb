shared_examples 'Short-circuits saving in test mode' do
  subject { described_class.new }

  describe '#save' do
    it 'does not create a record in test mode' do
      allow(subject).to receive(:valid?).and_return(true)
      BestBoy.in_test_mode do
        expect do
          expect(subject.save).to eql true
        end.not_to change { subject.class.count }
      end
    end
  end

  describe '#save!' do
    it 'does not create a record in test mode' do
      allow(subject).to receive(:valid?).and_return(true)
      BestBoy.in_test_mode do
        expect do
          expect(subject.save!).to eql true
        end.not_to change { subject.class.count }
      end
    end
  end
end
