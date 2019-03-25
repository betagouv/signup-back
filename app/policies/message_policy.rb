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
      %w[dgfip api_particulier franceconnect api_droits_cnam].each do |target_api|
        return scope.where(enrollment_id: Enrollment.send(target_api.to_sym).pluck(:id)) if user.is_admin?(target_api)
      end

      scope.where(enrollment_id: user.enrollments.pluck(:id))
    end
  end
end
