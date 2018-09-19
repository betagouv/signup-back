class EnrollmentPolicy < ApplicationPolicy
  def create?
    record.pending? && user.service_provider?
  end

  def update?
    (record.pending? || record.technical_inputs_pending?) && (user.has_role?(:applicant, record) || user.provided_by?(record.resource_provider))
  end

  def update_contacts?
    (record.validated?) && (user.has_role?(:applicant, record))
  end

  def send_application?
    record.can_send_application? && (user.has_role?(:applicant, record) || user.provided_by?(record.resource_provider))
  end

  def send_technical_inputs?
    record.can_send_technical_inputs? && user.has_role?(:applicant, record)
  end

  %i[validate_application? review_application? refuse_application? validate_technical_inputs?].each do |ability|
    define_method(ability) do
      record.send("can_#{ability}") &&
        user.provided_by?(record.resource_provider)
    end
  end

  def show_technical_inputs?
    !record.short_workflow? && (record.technical_inputs_pending? || record.technical_inputs_sent? || record.validated?)
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
        :fournisseur_de_service,
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
          :destinataires
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

    if send_technical_inputs?
      res.concat([
        :autorite_certification,
        :ips_de_production,
        :autorite_homologation_nom,
        :autorite_homologation_fonction,
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
        :recette_fonctionnelle,
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
