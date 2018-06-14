# Preview all emails at http://localhost:3000/rails/mailers/enrollment
class EnrollmentPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/send_application
  def send_application
    EnrollmentMailer.send_application
  end
end
