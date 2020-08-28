class DocumentPolicy < ApplicationPolicy
  def show?
    user.is_reporter?(record.attachable.target_api) ||
      user.is_instructor?(record.attachable.target_api) ||
      (user == record.attachable.user)
  end
end
