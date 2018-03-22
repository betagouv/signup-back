require "rails_helper"

RSpec.describe ResourceProvidersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/resource_providers").to route_to("resource_providers#index")
    end

    it "routes to #show" do
      expect(:get => "/api/resource_providers/1").to route_to("resource_providers#show", :id => "1")
    end
  end
end
