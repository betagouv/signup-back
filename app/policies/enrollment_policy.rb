class EnrollmentPolicy < ApplicationPolicy
  def create?
    record.pending?
  end

  def update?
    (record.pending? || record.modification_pending?) && user == record.user
  end

  def delete?
    (record.pending? || record.modification_pending?) && user == record.user
  end

  def notify?
    record.can_notify? && user.is_instructor?(record.target_api)
  end

  def send_application?
    record.can_send_application? && user == record.user
  end

  def validate_application?
    record.can_validate_application? && user.is_instructor?(record.target_api)
  end

  def review_application?
    record.can_review_application? && user.is_instructor?(record.target_api)
  end

  def refuse_application?
    record.can_refuse_application? && user.is_instructor?(record.target_api)
  end

  def update_rgpd_contact?
    record.validated? && user.is_administrator?
  end

  def permitted_attributes_for_update_rgpd_contact
    [:responsable_traitement_email, :dpo_email]
  end

  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :previous_enrollment_id,
      :organization_id,
      :intitule,
      :description,
      :fondement_juridique_title,
      :fondement_juridique_url,
      :data_recipients,
      :data_retention_period,
      :data_retention_comment,
      :dpo_label,
      :dpo_email,
      :dpo_phone_number,
      :responsable_traitement_label,
      :responsable_traitement_email,
      :responsable_traitement_phone_number,
      :demarche,
      contacts: [:id, :email, :phone_number],
      documents_attributes: [
        :attachment,
        :type
      ]
    ])

    res
  end

  class Scope < Scope
    def resolve
      target_apis = user.roles
        .select { |r| r.end_with?(":reporter") }
        .map { |r| r.split(":").first }
        .uniq
      scope.where("target_api IN (?)", target_apis)
        .or(scope.where(user_id: user.id))
        .or(scope.where(dpo_id: user.id).where(status: "validated"))
        .or(scope.where(responsable_traitement_id: user.id).where(status: "validated"))
    end
  end
end
