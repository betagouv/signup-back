require "rails_helper"

RSpec.describe EnrollmentMailer, type: :mailer do
  %w[send_application].each do |action|
    describe action do
      let(:enrollment) { create(:enrollment_api_particulier) }
      let(:applicant) { create(:user, email: 'applicant@test.user') }
      let(:api_particulier_users) { create_list(:user, 10, provider: 'api_particulier') }
      before do
        applicant.add_role(:applicant, enrollment)
        api_particulier_users
      end
      let(:mail) do
        EnrollmentMailer.with(user: applicant, enrollment: enrollment).send(action.to_sym)
      end

      it "renders the headers" do
        expect(mail.subject).to eq(I18n.t("enrollment_mailer.#{action}.subject"))
        expect(mail.to).to eq(api_particulier_users.map(&:email))
        expect(mail.from).to eq(["contact@particulier.api.gouv.fr"])
      end

      # TODO messing with encodings
      # it "renders the body" do
      #   expect(mail.bodyi.encoded).to match(I18n.t('enrollment_mailer.layout.header'))
      #   expect(mail.body.encoded).to match(I18n.t("enrollment_mailer.#{action}.content"))
      #   expect(mail.body.encoded).to match(I18n.t('enrollment_mailer.layout.footer'))
      # end
    end
  end
end
