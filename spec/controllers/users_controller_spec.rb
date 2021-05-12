# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  describe "#me" do
    subject(:make_call) { get :me }

    let(:user) { create(:user, :with_all_infos) }

    before do
      login(user)
    end

    it "renders 200" do
      make_call

      expect(response.status).to eq(200)
    end

    it "renders user's attributes" do
      make_call

      expect(user.attributes).to include(JSON.parse(response.body))
    end
  end
end
