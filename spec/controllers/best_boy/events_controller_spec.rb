require 'spec_helper'

describe BestBoy::EventsController, type: :controller do
  describe 'GET index' do
    it "renders the template" do
      get :index, { use_route: :best_boy }
      expect(response).to render_template :index
    end
  end

  describe 'GET stats' do
    it "renders the template" do
      get :stats, { use_route: :best_boy }
      expect(response).to render_template :stats
    end
  end

  describe 'GET lists' do
    it "renders the template" do
      get :lists, { use_route: :best_boy }
      expect(response).to render_template :lists
    end
  end

  describe 'GET details' do
    it "renders the template" do
      get :details, { use_route: :best_boy }
      expect(response).to render_template :details
    end
  end

  describe 'GET monthly_details' do
    it "renders the template" do
      get :monthly_details, {year: Time.zone.now.year, month: Time.zone.now.month,  use_route: :best_boy }
      expect(response).to render_template :monthly_details
    end
  end

  describe 'GET charts' do
    it "renders the template" do
      get :charts, { use_route: :best_boy }
      expect(response).to render_template :charts
    end
  end
end