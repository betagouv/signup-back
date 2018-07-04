# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def create?
    user ? true : false
  end

  def update?
    false
  end

  class Scope < Scope
    def resolve
      %w[dgfip api_particulier].each do |resource_provider|
        return scope.where(enrollment_id: Enrollment.send(resource_provider.to_sym).pluck(:id)) if user.send("#{resource_provider}?".to_sym)
      end

      return scope.where(enrollment_id: Enrollment.with_role(:applicant, user).pluck(:id)) if user.service_provider?
      scope.none
    end
  end
end
