class EnrollmentMailer < ApplicationMailer
  default from: 'contact@particulier.api.gouv.fr'

  %i[send_application validate_application refuse_application review_application send_technical_inputs deploy_application].each do |action|
    define_method(action) do
      reciepients = enrollment.other_party(user).map(&:email)

      mail(to: reciepients) do |format|
        format.html { render inline: I18n.t("enrollment_mailer.#{action}.content"), layout: 'enrollment' }
        format.text { render inline: I18n.t("enrollment_mailer.#{action}.content"), layout: 'enrollment' }
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
