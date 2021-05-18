class EnrollmentMailer < ActionMailer::Base
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
    provider_config = providers_config.config_for(params[:target_api])

    @target_api_label = provider_config["label"]
    @message = params[:message]
    @applicant_email = params[:applicant_email]
    @target_api_support_email = provider_config["support_email"]

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
        from: @target_api_support_email,
        content_type: "text/plain",
        body: params[:message]
      )
    else
      mail(
        # The list of emails can be an array of email addresses or a single string with the addresses separated by commas.
        to: params[:to],
        subject: SUBJECTS[params[:template]],
        from: @target_api_support_email,
        template_path: %W[enrollment_mailer/#{params[:target_api]} enrollment_mailer],
        template_name: params[:template]
      )
    end
  end

  def add_scopes_in_franceconnect_email
    provider_config = providers_config.config_for(params[:target_api])

    @target_api_label = provider_config["label"]
    from = provider_config["support_email"]
    @nom_raison_sociale = params[:nom_raison_sociale]
    @previous_enrollment_id = params[:previous_enrollment_id]
    @scopes = params[:scopes]
    @url = "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"

    mail(
      to: "support.partenaires@franceconnect.gouv.fr",
      subject: "[DataPass] nouveaux scopes pour \"#{@nom_raison_sociale} - #{@previous_enrollment_id}\"",
      from: from,
      cc: "datapass@api.gouv.fr",
      template_path: "enrollment_mailer",
      template_name: "add_scopes_in_franceconnect"
    )
  end

  private

  def providers_config
    ProvidersConfiguration.instance
  end
end
