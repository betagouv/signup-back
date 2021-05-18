RSpec.describe EnrollmentsController, "#show", type: :controller do
  describe "authorization" do
    subject do
      get :show, params: {
        id: enrollment.id
      }
    end

    context "without user" do
      let(:enrollment) { create(:enrollment, :franceconnect) }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "with user" do
      let(:user) { create(:user) }

      before do
        login(user)
      end

      context "when user created this enrollment" do
        let(:enrollment) { create(:enrollment, :franceconnect, user: user) }

        it { is_expected.to have_http_status(:ok) }
      end

      context "when user is the DPO associated to this enrollment" do
        let(:enrollment) { create(:enrollment, :franceconnect, status_trait, dpo: user) }

        context "when this enrollment has been validated" do
          let(:status_trait) { :validated }

          it { is_expected.to have_http_status(:ok) }
        end

        context "when this enrollment has not been validated" do
          let(:status_trait) { :pending }

          it { is_expected.to have_http_status(:not_found) }
        end
      end

      context "when user is the responsable traitement associated to this enrollment" do
        let(:enrollment) { create(:enrollment, :franceconnect, status_trait, responsable_traitement: user) }

        context "when this enrollment has been validated" do
          let(:status_trait) { :validated }

          it { is_expected.to have_http_status(:ok) }
        end

        context "when this enrollment has not been validated" do
          let(:status_trait) { :pending }

          it { is_expected.to have_http_status(:not_found) }
        end
      end

      context "when user is a reporter for the enrollment's target api" do
        let(:user) { create(:user, roles: ["franceconnect:reporter"]) }
        let(:enrollment) { create(:enrollment, :franceconnect) }

        it { is_expected.to have_http_status(:ok) }
      end

      context "when user is a only reporter for another target api" do
        let(:user) { create(:user, roles: ["api_entreprise:reporter"]) }
        let(:enrollment) { create(:enrollment, :franceconnect) }

        it { is_expected.to have_http_status(:not_found) }
      end
    end
  end

  describe "payload" do
    subject(:show_enrollment_payload) do
      get :show, params: {
        id: enrollment.id
      }

      JSON.parse(response.body)
    end

    let(:user) { create(:user) }
    let(:enrollment) { create(:enrollment, :franceconnect, user: user) }

    before do
      login(user)
    end

    it "includes fields defined in EnrollmentSerializer only" do
      expect(show_enrollment_payload["dpo_label"]).to eq(enrollment.dpo_label)
    end
  end
end
