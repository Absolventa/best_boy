require 'spec_helper'

describe BestBoy do
  after { BestBoy.test_mode = false }

  describe 'its configuration interface' do
    it 'defaults or :active_record as ORM' do
      expect(BestBoy.orm).to eql :active_record
    end

    it 'defaults to ApplicationController as base controller' do
      expect(BestBoy.base_controller).to eql 'ApplicationController'
    end

    [:before_filter, :custom_redirect, :skip_after_filter, :skip_before_filter].each do |config_var|
      it "defaults to nil for #{config_var}" do
        expect(BestBoy.public_send(config_var)).to be_nil
      end
    end
  end

  describe '.setup' do
    it 'yields self to block' do
      expect { |blk| BestBoy.setup(&blk) }.
        to yield_with_args BestBoy
    end
  end

  context 'its test mode' do
    it 'defaults to false' do
      expect(BestBoy.test_mode).to eql false
    end

    describe '.in_test_mode' do
      it 'yields to block' do
        expect { |blk| BestBoy.in_test_mode(&blk) }.
          to yield_control
      end

      it 'provides a test mode runtime' do
        BestBoy.test_mode = false
        expect do
          BestBoy.in_test_mode do
            expect(BestBoy.test_mode).to eql true
          end
        end.not_to change { BestBoy.test_mode }
      end

      it 'will not unset existing test mode' do
        BestBoy.test_mode = true
        expect { BestBoy.in_test_mode }.not_to change { BestBoy.test_mode }
      end
    end

    describe '.in_real_mode' do
      it 'yields to block' do
        expect { |blk| BestBoy.in_real_mode(&blk) }.
          to yield_control
      end

      it 'provides a real mode runtime' do
        BestBoy.test_mode = true
        expect do
          BestBoy.in_real_mode do
            expect(BestBoy.test_mode).to eql false
          end
        end.not_to change { BestBoy.test_mode }
      end

      it 'will not unset existing real mode' do
        BestBoy.test_mode = false
        expect { BestBoy.in_test_mode }.not_to change { BestBoy.test_mode }
      end
    end
  end
end
