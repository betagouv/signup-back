RSpec.describe EnrollmentMailer, type: :mailer do
  describe "#notification_email" do
    subject(:mail) do
      described_class.with(
        to: to_email,
        target_api: target_api,
        enrollment_id: enrollment.id,
        template: template,
        message: message
      ).notification_email
    end

    let(:to_email) { generate(:email) }
    let(:target_api) { "franceconnect" }
    let(:enrollment) { create(:enrollment, :franceconnect, user: user) }
    let(:user) { create(:user, :with_all_infos) }

    describe "manual review from instructor" do
      context "with custom message" do
        let(:template) { "review_application" }
        let(:message) { "Hello world!" }

        it "renders valid headers" do
          expect(mail.subject).to eq("Votre demande requiert des modifications")
          expect(mail.to).to eq([to_email])
          expect(mail.from).to eq(["support.partenaires@franceconnect.gouv.fr"])
        end

        it "renders valid body with message only" do
          expect(mail.body.encoded).to eq(message)
        end
      end
    end

    describe "custom layout for a target API" do
      let(:target_api) { "api_entreprise" }
      let(:template) { "create_application" }
      let(:message) { nil }

      it "renders custom subject" do
        expect(mail.subject).to eq("💾 Le brouillon de votre demande a bien été enregistré")
      end
    end
  end
end
