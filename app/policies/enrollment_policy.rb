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
        :fournisseur_de_service,
        :fournisseur_donnees,
        :description_service,
        :fondement_juridique,
        :scope_dgfip_avis_imposition,
        :scope_cnaf_attestation_droits,
        :scope_cnaf_quotient_familial,
        :scope_dgfip_adresse_fiscale_taxation,
        :scope_dgfip_RFR,
        :nombre_demandes_annuelle,
        :pic_demandes_par_heure,
        :nombre_demandes_mensuelles_jan,
        :nombre_demandes_mensuelles_fev,
        :nombre_demandes_mensuelles_mar,
        :nombre_demandes_mensuelles_avr,
        :nombre_demandes_mensuelles_mai,
        :nombre_demandes_mensuelles_jui,
        :nombre_demandes_mensuelles_jul,
        :nombre_demandes_mensuelles_aou,
        :nombre_demandes_mensuelles_sep,
        :nombre_demandes_mensuelles_oct,
        :nombre_demandes_mensuelles_nov,
        :nombre_demandes_mensuelles_dec,
        :demarche_cnil,
        :autorite_certification_nom,
        :autorite_certification_fonction,
        :date_homologation,
        :date_fin_homologation,
        :delegue_protection_donnees,
        :validation_de_convention,
        :certificat_pub_production,
        :autorite_certification,
        :ips_de_production,
        :recette_fonctionnelle
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
