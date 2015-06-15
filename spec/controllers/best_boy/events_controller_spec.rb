require 'spec_helper'

describe BestBoy::EventsController, type: :controller do
  routes { BestBoy::Engine.routes }

  describe 'GET index' do
    it "renders the template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET stats' do
    it "renders the template" do
      get :stats
      expect(response).to render_template :stats
    end

    it "renders the xml template if requested" do
      get :stats, format: :xml
      expect(response.content_type).to eq('application/xml')
      expect(response).to render_template :stats
    end
  end

  describe 'GET lists' do
    it "renders the template" do
      get :lists
      expect(response).to render_template :lists
    end

    it "renders the xml template if requested" do
      get :lists, format: :xml
      expect(response.content_type).to eq('application/xml')
      expect(response).to render_template :lists
    end
  end

  describe 'GET details' do
    it "renders the template" do
      get :details
      expect(response).to render_template :details
    end

    it "renders the xml template if requested" do
      get :details, format: :xml
      expect(response.content_type).to eq('application/xml')
      expect(response).to render_template :details
    end
  end

  describe 'GET monthly_details' do
    it "renders the template" do
      get :monthly_details, {year: Time.zone.now.year, month: Time.zone.now.month }
      expect(response).to render_template :monthly_details
    end

    it "renders the xml template if requested" do
      get :monthly_details, {year: Time.zone.now.year, month: Time.zone.now.month, format: :xml}
      expect(response.content_type).to eq('application/xml')
      expect(response).to render_template :monthly_details
    end
  end

  describe 'GET charts' do
    it "renders the template" do
      get :charts
      expect(response).to render_template :charts
    end
  end
end