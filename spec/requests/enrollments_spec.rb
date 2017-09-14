require 'rails_helper'

RSpec.describe "Enrollments", type: :request do
  describe "GET /enrollments" do
    it "works! (now write some real specs)" do
      get enrollments_path
      expect(response).to have_http_status(200)
    end
  end
end
