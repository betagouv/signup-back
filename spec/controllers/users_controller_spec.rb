# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  describe "#me" do
    subject(:make_call) { get :me }

    let(:user) { create(:user, :with_all_infos) }

    before do
      login(user)
    end

    it { is_expected.to have_http_status(:ok) }

    it "renders user's attributes" do
      make_call

      expect(user.attributes).to include(JSON.parse(response.body))
    end
  end

  describe "#index" do
    subject(:users_index) do
      get :index, params: {
        users_with_roles_only: users_with_roles_only
      }
    end

    let(:users_with_roles_only) { nil }

    before do
      login(user)
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context "when user is an admin" do
      let(:user) { create(:user, :administrator) }

      it { is_expected.to have_http_status(:ok) }

      describe "payload" do
        subject(:users_index_payload) do
          get :index, params: {
            users_with_roles_only: users_with_roles_only
          }

          JSON.parse(response.body)["users"]
        end

        let!(:first_user_with_role) { create(:user, email: "a#{generate(:email)}", roles: ["whatever"]) }
        let!(:second_user_without_role) { create(:user, email: "b#{generate(:email)}", roles: []) }
        it "renders all users ordered by email" do
          expect(users_index_payload.count).to eq(3)

          expect(users_index_payload.map { |user_payload| user_payload["id"] }).to eq([
            first_user_with_role.id,
            second_user_without_role.id,
            user.id
          ])
        end

        context "when users_with_roles_only is set to true" do
          let(:users_with_roles_only) { true }

          it "renders users with roles only" do
            expect(users_index_payload.count).to eq(2)

            expect(users_index_payload.map { |user_payload| user_payload["id"] }).to eq([
              first_user_with_role.id,
              user.id
            ])
          end
        end
      end
    end
  end

  describe "#update" do
    subject(:update_user) do
      put :update, params: {
        id: user_updated.id,
        user: user_updated_params
      }
    end

    let(:user_updated) { create(:user) }
    let(:user_updated_params) do
      {
        given_name: "not relevant",
        roles: ["hello"]
      }
    end

    before do
      login(user)
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context "when user is an admin" do
      let(:user) { create(:user, :administrator) }

      it { is_expected.to have_http_status(:ok) }

      it "updates roles" do
        expect {
          update_user
        }.to change { user_updated.reload.roles }.to(user_updated_params[:roles])
      end

      it "does not update other attributes" do
        expect {
          update_user
        }.not_to change { user_updated.reload.given_name }
      end
    end
  end
end
