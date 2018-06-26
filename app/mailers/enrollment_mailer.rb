class EnrollmentMailer < ApplicationMailer
  default from: 'contact@particulier.api.gouv.fr', charset: 'UTF-8'

  %i[send_application].each do |action|
    define_method(action) do
      recipients = enrollment.other_party(user).map(&:email)

      return unless recipients.present?
      mail(to: recipients) do |format|
        format.html { render inline: I18n.t("enrollment_mailer.#{action}.content"), layout: 'enrollment', charset: 'UTF-8' }
        format.text { render inline: I18n.t("enrollment_mailer.#{action}.content"), layout: 'enrollment', charset: 'UTF-8' }
      end
    end
  end
  private

  def user
    params[:user]
  end

  def enrollment
    params[:enrollment]
  end
end
