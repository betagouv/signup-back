RSpec.describe EnrollmentsController, "#update_owner", type: :controller do
  subject(:update_enrollment) do
    patch :update_owner, params: {
      id: enrollment.id,
      enrollment: enrollment_attributes
    }
  end

  let(:enrollment) { create(:enrollment, :franceconnect, enrollment_status, user: enrollment_creator) }
  let(:enrollment_attributes) do
    {
      intitule: new_intitule
    }
  end
  let(:new_intitule) { "Nouvel intitulé" }
  let(:enrollment_status) { :pending }
  let(:enrollment_creator) { create(:user) }

  describe "authorization" do
    context "without user" do
      it { is_expected.to have_http_status(:unauthorized) }
    end

    context "with a user" do
      let(:user) { create(:user) }

      before do
        login(user)
      end

      context "when user created this enrollment" do
        let(:enrollment_creator) { user }

        context "when enrollment is pending" do
          let(:enrollment_status) { :pending }

          it { is_expected.to have_http_status(:forbidden) }
        end

        context "when enrollment is validated" do
          let(:enrollment_status) { :validated }

          it { is_expected.to have_http_status(:forbidden) }
        end
      end

      context "when user did not create this enrollment" do
        it { is_expected.to have_http_status(:not_found) }
      end

      context "when user is an administrator" do
        let(:user) { create(:user, :administrator) }

        context "when enrollment is pending" do
          let(:enrollment_status) { :pending }

          it { is_expected.to have_http_status(:not_found) }
        end

        context "when enrollment is validated" do
          let(:enrollment_status) { :validated }

          it { is_expected.to have_http_status(:not_found) }
        end

        context "when user is also a reporter for this enrollment" do
          before do
            user.roles << "franceconnect:reporter"
            user.save!
          end

          context "when enrollment is pending" do
            let(:enrollment_status) { :pending }

            it { is_expected.to have_http_status(:forbidden) }
          end

          context "when enrollment is validated" do
            let(:enrollment_status) { :validated }

            it { is_expected.to have_http_status(:ok) }
          end
        end
      end
    end
  end

  describe "update" do
    let(:user) { create(:user, roles: %w[administrator franceconnect:reporter]) }
    let(:enrollment_status) { :validated }

    before do
      login(user)
    end

    context "with unpermitted params" do
      let(:enrollment_attributes) do
        {
          intitule: new_intitule
        }
      end

      it "does not update enrollment" do
        expect {
          update_enrollment
        }.not_to change { enrollment.reload.intitule }
      end
    end

    context "with permitted params (only user_email)" do
      let(:enrollment_attributes) do
        {
          user_email: new_user_email
        }
      end
      let(:new_user_email) { "update_#{generate(:email)}" }

      it "updates enrollment user email" do
        expect {
          update_enrollment
        }.to change { enrollment.reload.user.email }.to(new_user_email)
      end

      it "creates an event 'updated' associated to this enrollment and user" do
        expect {
          update_enrollment
        }.to change { user.events.count }.by(1)

        latest_user_event = user.events.last

        expect(latest_user_event.name).to eq("updated")
        expect(latest_user_event.enrollment.id).to eq(enrollment.id)
      end
    end
  end
end
