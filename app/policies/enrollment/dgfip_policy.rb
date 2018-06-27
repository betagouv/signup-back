# frozen_string_literal: true

class Enrollment::DgfipPolicy < EnrollmentPolicy
  def convention?
    false
  end

  def send_application?
    record.can_send_application? && user.has_role?(:applicant, record)
  end

  def validate_application?
    record.can_validate_application? && user.dgfip?
  end

  def refuse_application?
    record.can_refuse_application? && user.dgfip?
  end

  def send_technical_inputs?
    record.can_send_technical_inputs? && user.has_role?(:applicant, record)
  end

  def show_technical_inputs?
    (
      (
        record.can_send_technical_inputs? || record.technical_inputs? || record.deployed?
      ) && user.has_role?(:applicant, record)
    ) || user.dgfip?
  end

  def deploy_application?
    record.can_deploy_application? && user.dgfip?
  end

  def delete?
    user.has_role?(:applicant, record)
  end

  def review_application?
    record.can_review_application? && user.dgfip?
  end
end
