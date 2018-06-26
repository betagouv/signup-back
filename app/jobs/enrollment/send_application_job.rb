class Enrollment::SendApplicationJob < ApplicationJob
  queue_as :default

  def perform(enrollment, user)
    return unless user.has_role?(:applicant, enrollment)

    EnrollmentMailer.with(user: user, enrollment: enrollment).send_application.deliver_now
  end
end
