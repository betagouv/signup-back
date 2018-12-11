# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def show?
    return true if user.provided_by?(record.attachable.resource_provider)
    return false unless user.service_provider?
    user.has_role?(:applicant, record.attachable)
  end
end
