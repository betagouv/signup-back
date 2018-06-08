class Enrollment::DeployApplicationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
