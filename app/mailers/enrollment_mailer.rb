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
      "target_api" => "FranceConnect"
    },
    "dgfip" => { 
      "sender" => "contact@api.gouv.fr", 
      "target_api" => "API « impôt particulier »"
    },
    "api-particulier" => { 
      "sender" => "contact@particulier.api.gouv.fr", 
      "target_api" => "API Particulier"
    },
    "api_droits_cnam" => { 
      "sender" => "contact@api.gouv.fr", 
      "target_api" => "API CNAM"
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

      @target_api = mailParams[enrollment.fournisseur_de_donnees]["target_api"]
      
      if [:review_application, :refuse_application].include? action.to_sym
        messages_for_enrollment = Message.where(enrollment_id: enrollment.id)
        # This infers that the last message corresponds to the action that triggered the email.
        # If the wrong message is received, this might be the cause
        # TODO strongly bind the message to the action with database relation
        @last_message = messages_for_enrollment.order(:created_at).last.content
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
