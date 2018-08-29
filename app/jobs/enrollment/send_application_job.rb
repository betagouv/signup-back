class Enrollment::SendMailJob < ApplicationJob
  queue_as :default

  def perform(enrollment, user, event)
    EnrollmentMailer.with(user: user, enrollment: enrollment).send(event).deliver_now
  end
end
