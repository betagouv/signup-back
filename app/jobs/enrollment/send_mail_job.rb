class Enrollment::SendMailJob < ApplicationJob
  queue_as :default

  def perform(enrollment, user, event)
    begin
      EnrollmentMailer.with(user: user, enrollment: enrollment).send(event).deliver_now
    rescue NoMethodError => e
      # if no mail is defined for this action we just silently fail
    end
  end
end
