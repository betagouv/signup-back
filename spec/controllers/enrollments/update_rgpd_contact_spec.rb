RSpec.describe EnrollmentsController, "#update_rgpd_contact", type: :controller do
  subject(:update_enrollment) do
    patch :update_rgpd_contact, params: {
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

    context "with permitted params" do
      context "with dpo informations" do
        let(:enrollment_attributes) do
          {
            dpo_label: "dpo_label",
            dpo_email: generate(:email),
            dpo_phone_number: "0636656565"
          }
        end

        it "updates enrollment with these information" do
          update_enrollment
          enrollment.reload

          enrollment_attributes.each do |key, value|
            expect(enrollment.public_send(key)).to eq(value)
          end
        end

        it "creates an event 'updated' associated to this enrollment and user" do
          expect {
            update_enrollment
          }.to change { user.events.count }.by(1)

          latest_user_event = user.events.last

          expect(latest_user_event.name).to eq("updated")
          expect(latest_user_event.enrollment.id).to eq(enrollment.id)
        end

        describe "email sent" do
          let(:stubbed_sendinblue_post) do
            stub_request(:post, "https://api.sendinblue.com/v3/smtp/email")
          end

          before do
            stubbed_sendinblue_post

            ActiveJob::Base.queue_adapter = :inline
          end

          after do
            ActiveJob::Base.queue_adapter = :test
          end

          it "sends an email through RgpdMailer to this new email" do
            update_enrollment

            expect(stubbed_sendinblue_post).to have_been_requested
          end
        end
      end

      context "with responsable traitement informations" do
        let(:enrollment_attributes) do
          {
            responsable_traitement_label: "responsable_traitement_label",
            responsable_traitement_email: generate(:email),
            responsable_traitement_phone_number: "0636656565"
          }
        end

        it "updates enrollment with these information" do
          update_enrollment
          enrollment.reload

          enrollment_attributes.each do |key, value|
            expect(enrollment.public_send(key)).to eq(value)
          end
        end

        it "creates an event 'updated' associated to this enrollment and user" do
          expect {
            update_enrollment
          }.to change { user.events.count }.by(1)

          latest_user_event = user.events.last

          expect(latest_user_event.name).to eq("updated")
          expect(latest_user_event.enrollment.id).to eq(enrollment.id)
        end

        describe "email sent" do
          let(:stubbed_sendinblue_post) do
            stub_request(:post, "https://api.sendinblue.com/v3/smtp/email")
          end

          before do
            stubbed_sendinblue_post

            ActiveJob::Base.queue_adapter = :inline
          end

          after do
            ActiveJob::Base.queue_adapter = :test
          end

          it "sends an email through RgpdMailer to this new email" do
            update_enrollment

            expect(stubbed_sendinblue_post).to have_been_requested
          end
        end
      end

      context "with valid attributes but no email" do
        let(:stubbed_sendinblue_post) do
          stub_request(:post, "https://api.sendinblue.com/v3/smtp/email")
        end

        let(:enrollment_attributes) do
          {
            responsable_traitement_label: "responsable_traitement_label"
          }
        end

        before do
          ActiveJob::Base.queue_adapter = :inline
        end

        after do
          ActiveJob::Base.queue_adapter = :test
        end

        it "does not send an email through RgpdMailer" do
          update_enrollment

          expect(stubbed_sendinblue_post).not_to have_been_requested
        end
      end
    end
  end
end
