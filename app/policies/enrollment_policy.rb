class EnrollmentPolicy < ApplicationPolicy
  def create?
    record.pending?
  end

  def update?
    (record.pending? || record.modification_pending?) && user.is_owner?(record)
  end

  def destroy?
    (record.pending? || record.modification_pending?) && user.is_owner?(record)
  end

  def notify?
    record.can_notify? && user.is_instructor?(record.target_api)
  end

  def send_application?
    record.can_send_application? && user.is_owner?(record)
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

  def update_owner?
    (record.validated? || record.refused?) && user.is_administrator?
  end

  def update_rgpd_contact?
    record.validated? && user.is_administrator?
  end

  def get_email_templates?
    user.is_instructor?(record.target_api)
  end

  def permitted_attributes_for_update_owner
    [:user_email]
  end

  def permitted_attributes_for_update_rgpd_contact
    [
      :responsable_traitement_family_name,
      :responsable_traitement_given_name,
      :responsable_traitement_email,
      :responsable_traitement_phone_number,
      :responsable_traitement_job,
      :dpo_family_name,
      :dpo_given_name,
      :dpo_email,
      :dpo_phone_number,
      :dpo_job
    ]
  end

  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :dpo_is_informed,
      :target_api,
      :previous_enrollment_id,
      :organization_id,
      :intitule,
      :description,
      :type_projet,
      :date_mise_en_production,
      :volumetrie_approximative,
      :fondement_juridique_title,
      :fondement_juridique_url,
      :data_recipients,
      :data_retention_period,
      :data_retention_comment,
      :demarche,
      team_members: [:type, :family_name, :given_name, :email, :phone_number, :job],
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
      scope.includes(:team_members).where(target_api: target_apis)
        .or(scope.includes(:team_members).where(team_members: {user_id: user.id}))
    end
  end
end
