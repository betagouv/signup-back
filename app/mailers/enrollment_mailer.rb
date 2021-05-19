class EnrollmentMailer < ActionMailer::Base
  def notification_email
    @target_api_label = provider_config["label"]
    @message = params[:message]
    @applicant_email = params[:applicant_email]

    @url = "#{ENV.fetch("FRONT_HOST")}/#{params[:target_api].tr("_", "-")}/#{params[:enrollment_id]}"
    @front_host = ENV.fetch("FRONT_HOST")

    @majority_percentile_processing_time_in_days = nil
    if params[:template] == "send_application"
      @majority_percentile_processing_time_in_days = GetMajorityPercentileProcessingTimeInDays.call(params[:target_api])
    end

    if manual_review_from_instructor?
      render_mail(
        content_type: "text/plain",
        body: params[:message]
      )
    else
      render_mail(
        template_path: %W[enrollment_mailer/#{params[:target_api]} enrollment_mailer],
        template_name: params[:template]
      )
    end
  end

  def add_scopes_in_franceconnect_email
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

  def render_mail(attributes)
    subject = provider_config["mailer"][params[:template]]["subject"]

    mail({
      to: params[:to],
      subject: subject,
      from: provider_config["support_email"]
    }.merge(attributes))
  end

  def manual_review_from_instructor?
    %w[
      notify
      refuse_application
      review_application
      validate_application
    ].include?(params[:template])
  end

  def provider_config
    @provider_config ||= ProvidersConfiguration.instance.config_for(params[:target_api])
  end
end
