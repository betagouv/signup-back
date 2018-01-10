# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def create?
    return false unless user.france_connect?
    true
  end

  def update?
    res = false
    res = true if record.can_complete_application?
    res = record.applicant&.fetch('email', nil).present? if record.can_sign_convention?
    res = true if record.can_deploy_security?
    res && user.france_connect?
  end

  def convention?
    record.can_sign_convention? || record.can_deploy_security? || record.can_deploy_application? || record.deployed?
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

  def sign_convention?
    user.france_connect? && record.can_sign_convention?
  end

  def edit_security?
    user.france_connect? && record.can_deploy_security?
  end

  def show_security?
    user && %w[application_ready deployed].include?(record.state)
  end

  def deploy_security?
    user.france_connect? && record.can_deploy_security?
  end

  def deploy_application?
    user.dgfip? && record.can_deploy_application?
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
