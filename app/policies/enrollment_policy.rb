# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  def create?
    user.service_provider?
  end

  def update?
    (record.pending? && user.has_role?(:applicant, record)) || upload?
  end

  def upload?
    record.can_send_technical_inputs? && user.has_role?(:applicant, record)
  end

  def convention?
    false
  end

  def send_application?
    record.can_send_application? && user.has_role?(:applicant, record)
  end

  def validate_application?
    record.can_validate_application? && user.dgfip?
  end

  def refuse_application?
    record.can_refuse_application? && user.dgfip?
  end

  def send_technical_inputs?
    record.can_send_technical_inputs? &&
      !record.short_workflow? &&
      user.has_role?(:applicant, record)
  end

  def show_technical_inputs?
    (
      (
        record.can_send_technical_inputs? || record.technical_inputs? || record.deployed?
      ) && user.has_role?(:applicant, record)
    ) || user.dgfip?
  end

  def deploy_application?
    record.can_deploy_application? && user.dgfip?
  end

  def delete?
    user.has_role?(:applicant, record)
  end

  def review_application?
    record.can_review_application? && user.dgfip?
  end

  def permitted_attributes
    res = []
    if create? || update?
      res.concat([
        :validation_de_convention,
        :fournisseur_de_donnees,
        :siren,
        contacts: [:id, :heading, :nom, :email],
        demarche: [
          :intitule,
          :fondement_juridique,
          :description
        ],
        donnees: [
          :conservation,
          :destinataires
        ]
      ])
    end

    if upload?
      res.push(documents_attributes: [:attachment, :type])
    end

    res
  end

  class Scope < Scope
    def resolve
      %w[dgfip api_particulier api_entreprise].each do |provider|
        return scope.send(provider.to_sym) if user.send("#{provider}?".to_sym)
      end

      scope.with_role(:applicant, user)
    end
  end
end
