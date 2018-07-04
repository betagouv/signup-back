# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def show?
    return true if user.dgfip?
    return false unless user.service_provider?
    user.has_role?(:applicant, record.attachable)
  end
end
