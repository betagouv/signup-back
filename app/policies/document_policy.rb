# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def show?
    return true if user.dgfip?
    return false unless user.france_connect?
    user.has_role?(:applicant, record.enrollment)
  end
end
