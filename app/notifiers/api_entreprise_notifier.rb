class ApiEntrepriseNotifier < AbstractNotifier
  include WebhookNotifierMethods
  include EmailNotifierMethods

  def created
    deliver_event_webhook(__method__)
  end

  def updated(diff:, user_id:)
    deliver_event_webhook(__method__)
  end

  def owner_updated(diff:, user_id:)
  end

  def rgpd_contact_updated(diff:, user_id:, responsable_traitement_email:, dpo_email:)
    notify_rgpd_contacts_by_email(
      responsable_traitement_email: responsable_traitement_email,
      dpo_email: dpo_email
    )
  end

  def send_application(comment:, current_user:)
    deliver_event_webhook(__method__)

    notify_subscribers_by_email_for_sent_application(current_user: current_user)
  end

  def notify(comment:, current_user:)
    deliver_event_webhook(__method__)
  end

  def review_application(comment:, current_user:)
    deliver_event_webhook(__method__)
  end

  def refuse_application(comment:, current_user:)
    deliver_event_webhook(__method__)
  end

  def validate_application(comment:, current_user:)
    deliver_event_webhook(__method__)

    if enrollment.responsable_traitement.present?
      deliver_rgpd_email_for(:responsable_traitement)
    end

    if enrollment.dpo.present?
      deliver_rgpd_email_for(:dpo)
    end
  end
end
