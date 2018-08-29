class EnrollmentMailer < ActionMailer::Base
  default from: %("API Particulier" <contact@particulier.api.gouv.fr>), charset: 'UTF-8'

  subject = {
      :send_application => 'Nouvelle demande sur signup.api.gouv.fr',
      :validate_application => 'Votre demande a été validée',
      :review_application => 'Votre demande requiert des modifications',
      :refuse_application => 'Votre demande a été refusée'
  }

  %i[send_application validate_application review_application refuse_application].each do |action|
    define_method(action) do
      recipients = enrollment.other_party(user).map(&:email)

      return unless recipients.present?

      @email = user.email
      @url = "#{ENV.fetch('FRONT_HOST')}/#{enrollment.fournisseur_de_donnees}/#{enrollment.id}"
      mail(to: recipients, subject: subject[action.to_sym])
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
