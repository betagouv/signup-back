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
    let(:enrollment) { create(:enrollment, :franceconnect) }
    let(:template) { "review_application" }
    let(:message) { "Hello world!" }

    context "without configuration mocking" do
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
end
