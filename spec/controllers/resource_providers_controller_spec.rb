require 'rails_helper'

RSpec.describe ResourceProvidersController, type: :controller do

  let(:resource_provider) { FactoryGirl.create(:resource_provider) }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: {id: resource_provider.to_param}
      expect(response).to be_success
    end

    it "returns the right schema" do
      get :show, params: {id: resource_provider.to_param}
      validator = JSON::Validator.validate!(File.read(Rails.root.join('lib/schemas/resource_provider.json')), response.body)

      expect(validator).to be_truthy
    end
  end
end
