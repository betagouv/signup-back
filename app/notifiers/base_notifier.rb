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
      RgpdMailer.with(
        to: enrollment.responsable_traitement.email,
        target_api: enrollment.target_api,
        enrollment_id: enrollment.id,
        rgpd_role: EnrollmentsController::RESPONSABLE_TRAITEMENT_LABEL,
        contact_label: [enrollment.responsable_traitement_given_name, enrollment.responsable_traitement_family_name].join(" "),
        owner_email: enrollment.user.email,
        nom_raison_sociale: enrollment.nom_raison_sociale,
        intitule: enrollment.intitule
      ).rgpd_contact_email.deliver_later
    end

    if enrollment.dpo.present?
      RgpdMailer.with(
        to: enrollment.dpo.email,
        target_api: enrollment.target_api,
        enrollment_id: enrollment.id,
        rgpd_role: EnrollmentsController::DPO_LABEL,
        contact_label: [enrollment.dpo_given_name, enrollment.dpo_family_name].join(" "),
        owner_email: enrollment.user.email,
        nom_raison_sociale: enrollment.nom_raison_sociale,
        intitule: enrollment.intitule
      ).rgpd_contact_email.deliver_later
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
end
