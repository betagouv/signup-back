module EmailNotifierMethods
  protected

  def deliver_created_mail_to_enrollment_creator
    EnrollmentMailer.with(
      to: enrollment.user.email,
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      template: "create_application"
    ).notification_email.deliver_later
  end

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

  def notify_subscribers_by_email_for_sent_application(current_user: nil)
    EnrollmentMailer.with(
      to: enrollment.subscribers.map(&:email),
      target_api: enrollment.target_api,
      enrollment_id: enrollment.id,
      template: "notify_application_sent",
      applicant_email: current_user.email
    ).notification_email.deliver_later
  end

  def notify_rgpd_contacts_by_email(responsable_traitement_email:, dpo_email:)
    if responsable_traitement_email
      deliver_rgpd_email_for(:responsable_traitement)
    end

    if dpo_email
      deliver_rgpd_email_for(:dpo)
    end
  end
end
