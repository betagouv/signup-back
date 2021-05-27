RSpec.describe EnrollmentMailer, type: :mailer do
  describe "#notification_email" do
    let(:to_email) { generate(:email) }
    let(:target_api) { "franceconnect" }
    let(:enrollment) { create(:enrollment, :franceconnect, user: user) }
    let(:user) { create(:user, :with_all_infos) }

    describe "manual review from instructor" do
      subject(:mail) do
        described_class.with(
          to: to_email,
          target_api: target_api,
          enrollment_id: enrollment.id,
          template: template,
          message: message
        ).notification_email
      end

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

    describe "email triggered from backend" do
      subject(:mail) do
        described_class.with(
          to: to_email,
          target_api: target_api,
          enrollment_id: enrollment.id,
          template: template
        ).notification_email
      end

      let(:create_application_email_sample) do
        File.open(Rails.root.join("app/views/enrollment_mailer/create_application.text.erb")) { |f| f.readline }.chomp
      end

      let(:template_sample) do
        File.open(Rails.root.join("app/views/layouts/enrollment_mailer.text.erb")) { |f| f.readline }.chomp
      end

      let(:cartobio_send_application_email_sample) do
        File.open(Rails.root.join("app/views/enrollment_mailer/cartobio/send_application.text.erb")) { |f| f.readline }.chomp
      end

      describe "default layout for a target API" do
        let(:target_api) { "aidants_connect" }
        let(:template) { "create_application" }

        it "renders default subject" do
          expect(mail.subject).to eq("Votre demande a été enregistrée")
        end

        it "renders default template" do
          expect(mail.body.encoded).to include(create_application_email_sample)
        end

        it "uses default layout" do
          expect(mail.body.encoded).to include(template_sample)
        end
      end

      describe "custom subject for a target API" do
        let(:target_api) { "api_entreprise" }
        let(:template) { "create_application" }

        it "renders custom subject" do
          expect(mail.subject).to eq("💾 Le brouillon de votre demande a bien été enregistré")
        end
      end

      describe "custom template for a target API" do
        let(:template) { "send_application" }

        context "when skip layout option is true" do
          let(:target_api) { "api_entreprise" }

          it "does not use default layout" do
            expect(mail.body.encoded).not_to include(template_sample)
          end

          it "renders custom template" do
            expect(mail.body.encoded).to include("Bonjour #{enrollment.user.given_name}")
          end
        end

        context "when skip layout option is false" do
          let(:target_api) { "cartobio" }

          it "uses default layout" do
            expect(mail.body.encoded).to include(template_sample)
          end

          it "renders custom template" do
            expect(mail.body.encoded).to include(cartobio_send_application_email_sample)
            expect(mail.body.encoded).not_to include(create_application_email_sample)
          end
        end
      end
    end
  end
end
