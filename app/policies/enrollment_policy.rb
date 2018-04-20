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
    record.can_send_technical_inputs? && user.has_role?(:applicant, record)
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
        :validation_delegue_a_la_protection_des_données,
        :siren,
        contacts: [:id, :heading, :nom, :email],
        scopes: [
          :dgfip_declarants,
          :dgfip_foyer_fiscal,
          :dgfip_date_recouvrement,
          :dgfip_date_etablissement,
          :dgfip_nombre_parts,
          :dgfip_situation_famille,
          :dgfip_nombre_personnes_charge,
          :dgfip_revenu_brut_global,
          :dgfip_revenu_imposable,
          :dgfip_revenu_net_avant_corrections,
          :dgfip_montant_impot,
          :dgfip_revenu_fiscal_reference,
          :dgfip_avis_imposition,
          :cnaf_quotient_familial,
          :cnaf_attestation_droits
        ],
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
      if user.dgfip?
        scope.all
      else
        scope.with_role(:applicant, user)
      end
    end
  end
end
