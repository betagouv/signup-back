# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def show?
    user.is_admin?(record.attachable.target_api) or user == record.attachable.user
  end
end
