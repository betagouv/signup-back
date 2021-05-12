class EnrollmentMailer < ActionMailer::Base
  # note that this list is also used for parameter control at enrollment creation and to notify subscribers
  MAIL_PARAMS = {
    "franceconnect" => {
      "sender" => "support.partenaires@franceconnect.gouv.fr",
      "target_api" => "FranceConnect"
    },
    "api_particulier" => {
      "sender" => "contact@particulier.api.gouv.fr",
      "target_api" => "API Particulier"
    },
    "api_impot_particulier_sandbox" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier (Bac à sable)"
    },
    "api_impot_particulier_production" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier (Production)"
    },
    "api_impot_particulier_fc_sandbox" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier (Bac à sable)"
    },
    "api_impot_particulier_fc_production" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Impôt particulier (Production)"
    },
    "api_r2p_sandbox" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API R2P (Bac à sable)"
    },
    "api_r2p_production" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API R2P (Production)"
    },
    "api_ficoba_sandbox" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API FICOBA (Bac à sable)"
    },
    "api_ficoba_production" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API FICOBA (Production)"
    },
    "api_droits_cnam" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Droits CNAM"
    },
    "api_entreprise" => {
      "sender" => "support@entreprise.api.gouv.fr",
      "target_api" => "API Entreprise"
    },
    "preuve_covoiturage" => {
      "sender" => "contact@covoiturage.beta.gouv.fr",
      "target_api" => "Registre de preuve de covoiturage"
    },
    "le_taxi_clients" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "le.Taxi"
    },
    "le_taxi_chauffeurs" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "le.Taxi"
    },
    "cartobio" => {
      "sender" => "cartobio@beta.gouv.fr",
      "target_api" => "CartoBio"
    },
    "aidants_connect" => {
      "sender" => "contact@aidantsconnect.beta.gouv.fr",
      "target_api" => "Aidants Connect"
    },
    "francerelance_fc" => {
      "sender" => "support.partenaires@franceconnect.gouv.fr",
      "target_api" => "FranceRelance - Guichet FranceConnect"
    },
    "api_service_national" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Service National"
    },
    "api_statut_etudiant" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Statut étudiant"
    },
    "api_hermes_sandbox" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Hermes (Bac à sable)"
    },
    "api_hermes_production" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "API Hermes (Production)"
    },
    "hubee" => {
      "sender" => "contact@api.gouv.fr",
      "target_api" => "Hubee"
    }
  }.freeze

  SUBJECTS = {
    "send_application" => "Nous avons bien reçu votre demande d’accès",
    "validate_application" => "Votre demande a été validée",
    "review_application" => "Votre demande requiert des modifications",
    "refuse_application" => "Votre demande a été refusée",
    "notify_application_sent" => "Nouvelle demande sur DataPass",
    "create_application" => "Votre demande a été enregistrée",
    "notify" => "Vous avez un nouveau message concernant votre demande"
  }

  def notification_email
    @target_api_label = MAIL_PARAMS[params[:target_api]]["target_api"]
    @message = params[:message]
    @applicant_email = params[:applicant_email]
    @target_api_support_email = MAIL_PARAMS[params[:target_api]]["sender"]

    @url = "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"
    @front_host = ENV.fetch("FRONT_HOST")

    @majority_percentile_processing_time_in_days = nil
    if params[:template] == "send_application"
      @majority_percentile_processing_time_in_days = GetMajorityPercentileProcessingTimeInDays.call(params[:target_api])
    end

    if params.has_key?(:comment_full_edit_mode) && params[:comment_full_edit_mode]
      mail(
        # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
        to: params[:to],
        subject: SUBJECTS[params[:template]],
        from: MAIL_PARAMS[params[:target_api]]["sender"],
        content_type: "text/plain",
        body: params[:message]
      )
    else
      mail(
        # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
        to: params[:to],
        subject: SUBJECTS[params[:template]],
        from: MAIL_PARAMS[params[:target_api]]["sender"],
        template_path: %W[enrollment_mailer/#{params[:target_api]} enrollment_mailer],
        template_name: params[:template]
      )
    end
  end

  def add_scopes_in_franceconnect_email
    @target_api_label = MAIL_PARAMS[params[:target_api]]["target_api"]
    @nom_raison_sociale = params[:nom_raison_sociale]
    @previous_enrollment_id = params[:previous_enrollment_id]
    @scopes = params[:scopes]
    @url = "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"

    mail(
      to: "support.partenaires@franceconnect.gouv.fr",
      subject: "[DataPass] nouveaux scopes pour \"#{@nom_raison_sociale} - #{@previous_enrollment_id}\"",
      from: MAIL_PARAMS[params[:target_api]]["sender"],
      cc: "datapass@api.gouv.fr",
      template_path: "enrollment_mailer",
      template_name: "add_scopes_in_franceconnect"
    )
  end
end
