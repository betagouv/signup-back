# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def create?
    user.service_provider?
  end

  def update?
    user.has_role?(:applicant, record)
  end

  def convention?
    false
  end

  def send_application?
    user.has_role?(:applicant, record)
  end

  class Scope < Scope
    def resolve
      if user.dgfip?
        scope.all
      else
        scope.with_role(:applicant, user)
      end
    end
  end
end
