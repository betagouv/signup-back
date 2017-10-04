# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def create?
    return false unless user.france_connect?
    true
  end

  def update?
    record.can_complete_application? && user.france_connect?
  end

  def complete_application?
    user.france_connect? && record.can_complete_application?
  end

  def approve_application?
    user.dgfip? && record.can_approve_application?
  end

  def refuse_application?
    user.dgfip? && record.can_refuse_application?
  end

  def deploy?
    user.france_connect? && record.can_deploy?
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
