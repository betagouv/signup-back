class BaseNotifier
  attr_reader :enrollment

  def initialize(enrollment)
    @enrollment = enrollment
  end

  def created
    EnrollmentMailer.with(
      to: enrollment.user.email,
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      template: "create_application"
    ).notification_email.deliver_later
  end

  def updated(diff:, user_id:)
  end

  def owner_updated(diff:, user_id:)
  end

  def rgpd_contact_updated(diff:, user_id:, responsable_traitement_email:, dpo_email:)
    if responsable_traitement_email
      deliver_rgpd_email_for(:responsable_traitement)
    end

    if dpo_email
      deliver_rgpd_email_for(:dpo)
    end
  end

  def send_application(comment:, current_user:)
    deliver_event_mailer(__method__, comment)

    EnrollmentMailer.with(
      to: enrollment.subscribers.map(&:email),
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      template: "notify_application_sent",
      applicant_email: current_user.email
    ).notification_email.deliver_later
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

  private

  def deliver_event_mailer(event, comment)
    EnrollmentMailer.with(
      to: enrollment.user.email,
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      template: event.to_s,
      message: comment
    ).notification_email.deliver_later
  end

  def deliver_rgpd_email_for(entity)
    RgpdMailer.with(
      to: enrollment.public_send(entity).email,
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      rgpd_role: Kernel.const_get("EnrollmentsController::#{entity.upcase}_LABEL"),
      contact_label: enrollment.public_send("#{entity}_full_name"),
      owner_email: enrollment.user.email,
      nom_raison_sociale: enrollment.nom_raison_sociale,
      intitule: enrollment.intitule
    ).rgpd_contact_email.deliver_later
  end
end
