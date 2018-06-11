# Preview all emails at http://localhost:3000/rails/mailers/enrollment
class EnrollmentPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/send_application
  def send_application
    EnrollmentMailer.send_application
  end

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/validate_application
  def validate_application
    EnrollmentMailer.validate_application
  end

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/refuse_application
  def refuse_application
    EnrollmentMailer.refuse_application
  end

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/review_application
  def review_application
    EnrollmentMailer.review_application
  end

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/send_technical_inputs
  def send_technical_inputs
    EnrollmentMailer.send_technical_inputs
  end

  # Preview this email at http://localhost:3000/rails/mailers/enrollment/deploy_application
  def deploy_application
    EnrollmentMailer.deploy_application
  end

end
