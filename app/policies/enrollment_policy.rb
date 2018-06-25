# frozen_string_literal: true

class EnrollmentPolicy < ApplicationPolicy
  PARAMS_BY_EVENT = {
      'review_application' => {
          messages_attributes: [:content]
      },
      'send_technical_inputs' => [
        :ips_de_production
      ]
  }

  def create?
    user.service_provider?
  end

  def update?
    (record.pending? && user.has_role?(:applicant, record)) ||
      send_technical_inputs?
  end

  def send_application?
    false
  end

  def validate_application?
    false
  end

  def refuse_application?
    false
  end

  def deploy_application?
    false
  end

  def review_application?
    false
  end

  def send_technical_inputs?
    record.can_send_technical_inputs? &&
      !record.short_workflow? &&
      user.has_role?(:applicant, record)
  end

  def show_technical_inputs?
    false
  end

  def delete?
    false
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
        ],
        documents_attributes: [
          :attachment,
          :type
        ]
      ])
    end

    res
  end

  class Scope < Scope
    def resolve
      %w[dgfip api_particulier api_entreprise].each do |provider|
        return scope.send(provider.to_sym) if user.send("#{provider}?".to_sym)
      end

      begin
        scope.with_role(:applicant, user)
      rescue Exception => e
        Enrollment.with_role(:applicant, user)
      end
    end
  end
end
