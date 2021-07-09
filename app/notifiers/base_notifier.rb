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
end
