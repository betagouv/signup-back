class EnrollmentPolicy < ApplicationPolicy
  def create?
    record.pending?
  end

  def update?
    record.pending? && user == record.user
  end

  def delete?
    false
  end

  def send_application?
    record.can_send_application? && user == record.user
  end

  def validate_application?
    record.can_validate_application? && user.is_admin?(record.target_api)
  end

  def review_application?
    record.can_review_application? && user.is_admin?(record.target_api)
  end

  def refuse_application?
    record.can_refuse_application? && user.is_admin?(record.target_api)
  end

  def update_contacts?
    record.validated? && user == record.user
  end

  def permitted_attributes
    res = []
    if create? || send_application?
      res.concat([
        :cgu_approved,
        :target_api,
        :linked_franceconnect_enrollment_id,
        :siret,
        :intitule,
        :description,
        :fondement_juridique_title,
        :fondement_juridique_url,
        :data_recipients,
        :data_retention_period,
        contacts: [:id, :heading, :nom, :email, :phone_number],
        documents_attributes: [
          :attachment,
          :type
        ]
      ])
    end

    if update_contacts?
      res.concat([
        contacts: [:id, :heading, :nom, :email, :phone_number],
      ])
    end

    res
  end

  class Scope < Scope
    def resolve
      scope.where("status <> 'pending' AND target_api IN (?)", user.roles).or(scope.where(user_id: user.id))
    end
  end
end
