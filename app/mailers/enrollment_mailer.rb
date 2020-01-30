class EnrollmentMailer < ActionMailer::Base
  default charset: "UTF-8"

  MAIL_PARAMS = {
    "franceconnect" => {
      "sender" => "support.partenaires@franceconnect.gouv.fr",
      "target_api" => "FranceConnect",
    },
    "api_particulier" => {
      "sender" => "contact@particulier.api.gouv.fr",
      "target_api" => "API Particulier",
    },
    "api_impot_particulier" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier",
    },
    "api_impot_particulier_step2" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier 2/2",
    },
    "api_droits_cnam" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API CNAM",
    },
    "api_entreprise" => {
      "sender" => "support@entreprise.api.gouv.fr",
      "target_api" => "API Entreprise",
    },
    "preuve_covoiturage" => {
      "sender" => "contact@covoiturage.beta.gouv.fr",
      "target_api" => "Registre de preuve de covoiturage",
    },
  }

  def notification_email
    @target_api_label = MAIL_PARAMS[params[:target_api]]["target_api"]
    @message = params[:message]
    @applicant_email = params[:applicant_email]
    @rgpd_role = params[:rgpd_role]
    @owner_email = params[:owner_email]
    @nom_raison_sociale = params[:nom_raison_sociale]
    @intitule = params[:intitule]
    @target_api_support_email = MAIL_PARAMS[params[:target_api]]["sender"]

    @url = "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"
    @front_host = ENV.fetch("FRONT_HOST")

    subjects = {
      "send_application" => "Nous avons bien reçu votre demande d'accès",
      "validate_application" => "Votre demande a été validée",
      "review_application" => "Votre demande requiert des modifications",
      "refuse_application" => "Votre demande a été refusée",
      "notify_application_sent" => "Nouvelle demande sur signup.api.gouv.fr",
      "notify_application_validated" => "Vous avez été désigné #{@rgpd_role} pour l’organisation #{@nom_raison_sociale}",
      "create_application" => "Votre demande a été enregistrée",
    }

    mail(
      # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
      to: params[:to],
      subject: subjects[params[:template]],
      from: MAIL_PARAMS[params[:target_api]]["sender"],
      template_path: %W[enrollment_mailer/#{params[:target_api]} enrollment_mailer],
      template_name: params[:template],
    )
  end
end
