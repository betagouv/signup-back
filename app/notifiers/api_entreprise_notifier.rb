class ApiEntrepriseNotifier < AbstractNotifier
  include WebhookNotifierMethods
  include EmailNotifierMethods

  def created
    deliver_event_webhook(__method__)
    deliver_created_mail_to_enrollment_creator if default_mailer_active?
  end

  def updated(diff:, user_id:)
    deliver_event_webhook(__method__)
  end

  def team_member_updated(team_member_type:)
    if team_member_type.in?(%w[delegue_protection_donnees responsable_traitement])
      deliver_rgpd_email_for(team_member_type)
    end
  end

  def send_application(comment:, current_user:)
    deliver_event_webhook(__method__)
    deliver_event_mailer(__method__, comment) if default_mailer_active?

    notify_subscribers_by_email_for_sent_application(current_user: current_user)
  end

  def notify(comment:, current_user:)
    deliver_event_webhook(__method__)
    deliver_event_mailer(__method__, comment) if default_mailer_active?
  end

  def review_application(comment:, current_user:)
    deliver_event_webhook(__method__)
    deliver_event_mailer(__method__, comment) if default_mailer_active?
  end

  def refuse_application(comment:, current_user:)
    deliver_event_webhook(__method__)
    deliver_event_mailer(__method__, comment) if default_mailer_active?
  end

  def validate_application(comment:, current_user:)
    deliver_event_webhook(__method__)
    deliver_event_mailer(__method__, comment) if default_mailer_active?

    if enrollment.team_members.exists?(type: "responsable_traitement")
      deliver_rgpd_email_for("responsable_traitement")
    end

    if enrollment.team_members.exists?(type: "delegue_protection_donnees")
      deliver_rgpd_email_for("delegue_protection_donnees")
    end
  end

  private

  def default_mailer_active?
    ENV["API_ENTREPRISE_MAILER_OFF"].nil?
  end
end
