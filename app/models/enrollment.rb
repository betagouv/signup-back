# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  validates_presence_of(
    :fournisseur_de_service,
    :description_service
  )
  validate :convention_validated?

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validates_presence_of(
        :validation_de_convention,
        :fondement_juridique,
        :scope_dgfip_avis_imposition,
        :scope_cnaf_attestation_droits,
        :scope_cnaf_quotient_familial,
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
        :autorite_certification_nom,
        :autorite_certification_fonction,
        :date_homologation,
        :date_fin_homologation,
        :delegue_protection_donnees,
        :validation_de_convention,
        :certificat_pub_production,
        :autorite_certification
      )
    end
    state :validated
    state :refused

    event :send_application do
      transition from: :pending, to: :sent
    end

    event :validate_application do
      transition from: :sent, to: :validated
    end

    event :refuse_application do
      transition from: :sent, to: :refused
    end

    event :review_application do
      transition from: :sent, to: :pending
    end
  end

  private

  def convention_validated?
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end
end
