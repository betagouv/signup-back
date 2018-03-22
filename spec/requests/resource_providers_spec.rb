require 'rails_helper'

RSpec.describe "ResourceProviders", type: :request do
  describe "GET /resource_providers" do
    it "works! (now write some real specs)" do
      get resource_providers_path
      expect(response).to have_http_status(200)
    end
  end
end
