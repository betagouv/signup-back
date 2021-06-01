class EnrollmentMailer < ActionMailer::Base
  layout false

  def notification_email
    @enrollment = Enrollment.find(params[:enrollment_id])
    @user = @enrollment.user

    @target_api_label = data_provider_config["label"]
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
        body: params[:message]
      )
    else
      render_mail(
        template_name: params[:template]
      )
    end
  end

  def add_scopes_in_franceconnect_email
    @target_api_label = data_provider_config["label"]
    from = data_provider_config["support_email"]
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
    subject = data_provider_mailer_config["subject"]

    mail({
      to: params[:to],
      subject: subject,
      from: data_provider_config["support_email"]
    }) do |format|
      format.text do
        if attributes[:body]
          render plain: attributes[:body]
        else
          render template: extract_template_path(attributes[:template_name])
        end
      end
    end
  end

  def manual_review_from_instructor?
    %w[
      notify
      refuse_application
      review_application
      validate_application
    ].include?(params[:template])
  end

  def extract_template_path(template_name)
    if custom_template_exists?(template_name)
      "enrollment_mailer/#{params[:target_api]}/#{template_name}"
    else
      "enrollment_mailer/#{template_name}"
    end
  end

  def custom_template_exists?(template_name)
    File.exist?(
      Rails.root.join(
        File.join(
          "app/views/enrollment_mailer/#{params[:target_api]}/#{template_name}.text.erb"
        )
      )
    )
  end

  def data_provider_mailer_config
    @data_provider_mailer_config ||= data_provider_config["mailer"][params[:template]]
  end

  def data_provider_config
    @data_provider_config ||= DataProvidersConfiguration.instance.config_for(params[:target_api])
  end
end
