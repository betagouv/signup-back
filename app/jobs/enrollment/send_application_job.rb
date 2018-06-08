class Enrollment::SendApplicationJob < ApplicationJob
  queue_as :default

  def perform(enrollment, user)
  end
end
