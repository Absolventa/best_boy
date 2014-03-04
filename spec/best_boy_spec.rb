require 'spec_helper'

describe BestBoy do
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

  describe 'its test mode' do
    it 'defaults to false' do
      expect(BestBoy.test_mode).to eql false
    end
  end
end
