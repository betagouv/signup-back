class EnrollmentMailer < ActionMailer::Base
  default charset: 'UTF-8'

  subject = {
      :send_application => 'Nouvelle demande sur signup.api.gouv.fr',
      :validate_application => 'Votre demande a été validée',
      :review_application => 'Votre demande requiert des modifications',
      :refuse_application => 'Votre demande a été refusée',
      :update_contacts => 'Contacts modifiés sur signup.api.gouv.fr',
      :notify_application_sent => "Nous avons bien reçu votre demande d'accès"
  }

  mailParams = {
    "franceconnect" => { 
      "sender" => "support.partenaires@franceconnect.gouv.fr", 
      "provider" => "FranceConnect"
    },
    "dgfip" => { 
      "sender" => "contact@api.gouv.fr", 
      "provider" => "API « impôt particulier »"
    },
    "api-particulier" => { 
      "sender" => "contact@particulier.api.gouv.fr", 
      "provider" => "API Particulier"
    },
    "api_droits_cnam" => { 
      "sender" => "contact@api.gouv.fr", 
      "provider" => "API CNAM"
    }
  }

  %i[send_application validate_application review_application refuse_application update_contacts notify_application_sent].each do |action|
    define_method(action) do
      recipients = enrollment.other_party(user).map(&:email)

      if action.to_sym == :notify_application_sent
        recipients = user.email
      end
      return unless recipients.present?

      sender = mailParams[enrollment.fournisseur_de_donnees]["sender"]

      @provider = mailParams[enrollment.fournisseur_de_donnees]["provider"]

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
