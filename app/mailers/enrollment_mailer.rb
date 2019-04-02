class EnrollmentMailer < ActionMailer::Base
  default charset: 'UTF-8'

  SUBJECTS = {
      'send_application' => "Nous avons bien reçu votre demande d'accès",
      'validate_application' => 'Votre demande a été validée',
      'review_application' => 'Votre demande requiert des modifications',
      'refuse_application' => 'Votre demande a été refusée',
      'update_contacts' => 'Contacts modifiés sur signup.api.gouv.fr',
      'notify_application_sent' => 'Nouvelle demande sur signup.api.gouv.fr',
      'create_application' => 'Votre demande a été enregistrée'
  }

  MAIL_PARAMS = {
    'franceconnect' => {
      'sender' => 'support.partenaires@franceconnect.gouv.fr',
      'target_api' => 'FranceConnect'
    },
    'dgfip' => {
      'sender' => 'contact@api.gouv.fr',
      'target_api' => 'API « impôt particulier »'
    },
    'api-particulier' => {
      'sender' => 'contact@particulier.api.gouv.fr',
      'target_api' => 'API Particulier'
    },
    'api-droits-cnam' => {
      'sender' => 'contact@api.gouv.fr',
      'target_api' => 'API CNAM'
    },
    "api_entreprise" => { 
      "sender" => "contact@api.gouv.fr", 
      "target_api" => "API Entreprise"
    }
  }

  def notification_email
    @target_api_label = MAIL_PARAMS[params[:target_api]]['target_api']
    @message = params[:message]
    @applicant_email = params[:applicant_email]

    @url = "#{ENV.fetch('FRONT_HOST')}/#{params[:target_api]}/#{params[:enrollment_id]}"
    mail(
        # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
        to: params[:to],
        subject: SUBJECTS[params[:template]],
        from: MAIL_PARAMS[params[:target_api]]['sender'],
        template_name: params[:template]
    )
  end
end
