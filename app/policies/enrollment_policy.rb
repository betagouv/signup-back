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
        :validation_de_convention,
        :fournisseur_de_donnees,
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
      %w[dgfip api_particulier franceconnect api_droits_cnam api_entreprise].each do |target_api|
        return scope.no_draft.send(target_api.to_sym) if user.is_admin?(target_api)
      end

      user.enrollments
    end
  end
end
