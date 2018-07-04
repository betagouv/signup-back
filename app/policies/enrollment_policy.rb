class EnrollmentPolicy < ApplicationPolicy
  PARAMS_BY_EVENT = {
      'review_application' => {
          messages_attributes: [:content]
      },
      'send_technical_inputs' => [
        :autorite_certification,
        :ips_de_production,
        :autorite_certification_nom,
        :autorite_certification_fonction,
        :date_homologation,
        :date_fin_homologation,
        :nombre_demandes_annuelle,
        :pic_demandes_par_seconde,
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
        :recette_fonctionnelle
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
    record.can_send_application? && user.has_role?(:applicant, record)
  end

  def send_technical_inputs?
    record.can_send_technical_inputs? && user.has_role?(:applicant, record)
  end

  %i[validate_application? review_application? refuse_application? deploy_application?].each do |ability|
    define_method(ability) do
      record.send("can_#{ability}") &&
        user.provided_by?(record.resource_provider)
    end
  end

  def show_technical_inputs?
    return false if record.short_workflow?
    (
      (
        record.can_send_technical_inputs? || record.technical_inputs? || record.deployed?
      ) && user.has_role?(:applicant, record)
    ) || user.provided_by?(record.resource_provider)
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
      %w[dgfip api_particulier].each do |resource_provider|
        return scope.send(resource_provider.to_sym) if user.send("#{resource_provider}?".to_sym)
      end

      begin
        scope.with_role(:applicant, user)
      rescue Exception => e
        Enrollment.with_role(:applicant, user)
      end
    end
  end
end
