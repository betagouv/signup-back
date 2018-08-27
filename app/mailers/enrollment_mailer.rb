class EnrollmentMailer < ActionMailer::Base
  default from: %("API Particulier" <contact@particulier.api.gouv.fr>), charset: 'UTF-8'

  %i[send_application].each do |action|
    define_method(action) do
      recipients = enrollment.other_party(user).map(&:email)

      return unless recipients.present?

      @email = user.email
      @url = "#{ENV.fetch('FRONT_HOST')}/#{enrollment.fournisseur_de_donnees}/#{enrollment.id}"
      mail(to: recipients, subject: 'Nouvelle demande sur signup.api.gouv.fr')
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
