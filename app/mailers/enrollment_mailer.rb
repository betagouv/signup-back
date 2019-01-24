class EnrollmentMailer < ActionMailer::Base
  default charset: 'UTF-8'

  subject = {
      :send_application => 'Nouvelle demande sur signup.api.gouv.fr',
      :validate_application => 'Votre demande a été validée',
      :review_application => 'Votre demande requiert des modifications',
      :refuse_application => 'Votre demande a été refusée',
      :update_contacts => 'Contacts modifiés sur signup.api.gouv.fr',
      :sent_application_notification => "Nous avons bien reçu votre demande d'accès"
  }

  %i[send_application validate_application review_application refuse_application update_contacts sent_application_notification].each do |action|
    define_method(action) do
      recipients = enrollment.other_party(user).map(&:email)

      if action.to_sym == :sent_application_notification
        recipients = user.email
      end
      return unless recipients.present?

      sender = case enrollment.fournisseur_de_donnees
        when "franceconnect" then "support.partenaires@franceconnect.gouv.fr"
        when "dgfip" then "contact@api.gouv.fr"
        when "api-particulier" then "contact@particulier.api.gouv.fr"
        when "api_droits_cnam" then "contact@api.gouv.fr"
        else
          "contact@api.gouv.fr"
        end

      @provider = case enrollment.fournisseur_de_donnees
        when "franceconnect" then "FranceConnect"
        when "dgfip" then "API « impôt particulier »"
        when "api-particulier" then "API Particulier"
        when "api_droits_cnam" then "API CNAM"
        else
          "API"
        end

      @email = user.email
      @url = "#{ENV.fetch('FRONT_HOST')}/#{enrollment.fournisseur_de_donnees}/#{enrollment.id}"
      mail(to: recipients, subject: subject[action.to_sym], from: sender)
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
