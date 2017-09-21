class EnrollmentPolicy < ApplicationPolicy
  def create?
    return false unless user.france_connect?
    true
  end

  def update?
    return record.can_complete_application? if user.france_connect?
    false
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
