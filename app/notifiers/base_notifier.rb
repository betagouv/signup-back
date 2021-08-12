class BaseNotifier < AbstractNotifier
  include EmailNotifierMethods

  def created
    deliver_created_mail_to_enrollment_creator
  end

  def updated(diff:, user_id:)
  end

  def owner_updated(diff:, user_id:)
  end

  # TODO replace dpo with delegue_protection_donnees everywhere
  def rgpd_contact_updated(diff:, user_id:, responsable_traitement_email:, dpo_email:)
    notify_rgpd_contacts_by_email(
      responsable_traitement_email: responsable_traitement_email,
      dpo_email: dpo_email
    )
  end

  def send_application(comment:, current_user:)
    deliver_event_mailer(__method__, comment)

    notify_subscribers_by_email_for_sent_application
  end

  def notify(comment:, current_user:)
    deliver_event_mailer(__method__, comment)
  end

  def review_application(comment:, current_user:)
    deliver_event_mailer(__method__, comment)
  end

  def refuse_application(comment:, current_user:)
    deliver_event_mailer(__method__, comment)
  end

  def validate_application(comment:, current_user:)
    deliver_event_mailer(__method__, comment)

    if enrollment.responsable_traitement.present?
      deliver_rgpd_email_for(:responsable_traitement)
    end

    if enrollment.dpo.present?
      deliver_rgpd_email_for(:dpo)
    end
  end
end
