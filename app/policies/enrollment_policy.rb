class EnrollmentPolicy < ApplicationPolicy
  def create?
    record.pending? && user.service_provider?
  end

  def update?
    record.pending? && user.has_role?(:applicant, record)
  end

  def update_contacts?
    record.validated? && user.has_role?(:applicant, record)
  end

  def send_application?
    record.can_send_application? && user.has_role?(:applicant, record)
  end

  %i[validate_application? review_application? refuse_application?].each do |ability|
    define_method(ability) do
      record.send("can_#{ability}") &&
        user.provided_by?(record.resource_provider)
    end
  end

  def delete?
    false
  end

  def permitted_attributes
    res = []
    if create? || send_application?
      res.concat([
        :validation_de_convention,
        :fournisseur_de_donnees,
        :linked_franceconnect_enrollment_id,
        :siret,
        contacts: [:id, :heading, :nom, :email, :telephone_portable],
        demarche: [
          :intitule,
          :fondement_juridique,
          :description,
          :url_fondement_juridique
        ],
        donnees: [
          :conservation,
          :destinataires,
          dgfip_data_years: [
            :n_moins_1,
            :n_moins_2
          ],
        ],
        documents_attributes: [
          :attachment,
          :type
        ]
      ])
    end

    if update_contacts?
      res.concat([
        contacts: [:id, :heading, :nom, :email, :telephone_portable],   
      ])
    end

    res
  end

  class Scope < Scope
    def resolve
      %w[dgfip api_particulier franceconnect api_droits_cnam].each do |resource_provider|
        return scope.no_draft.send(resource_provider.to_sym) if user.send("#{resource_provider}?".to_sym)
      end

      begin
        scope.with_role(:applicant, user)
      rescue Exception => e
        Enrollment.with_role(:applicant, user)
      end
    end
  end
end
