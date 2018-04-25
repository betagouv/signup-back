# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  validate :fournisseur_de_donnees_validation
  validate :agreements_validation

  scope :api_particulier, -> { where(fournisseur_de_donnees: 'api-particulier') }
  scope :api_entreprise, -> { where(fournisseur_de_donnees: 'api-entreprise') }
  scope :dgfip, -> { where(fournisseur_de_donnees: 'dgfip') }

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validate :fields_validation

      def fields_validation
        %w[dpo technique responsable_traitement]. each do |contact_type|
          contact = contacts.find { |e| e['id'] == contact_type }
          errors[:contacts] << "Vous devez renseigner le #{contact&.fetch('heading', nil)} avant de continuer" unless contact&.fetch('nom', false)&.present? && contact&.fetch('email', false)&.present?
        end

        errors[:siren] << "Vous devez renseigner le SIREN de votre organisation avant de continuer" unless siren.present?
        errors[:demarche] << "Vous devez renseigner la description de la démarche avant de continuer" unless demarche['description'].present?
        errors[:demarche] << "Vous devez renseigner le fondement juridique de la démarche avant de continuer" unless demarche['fondement_juridique'].present?
        errors[:donnees] << "Vous devez renseigner la conservation des données avant de continuer" unless donnees['conservation'].present?
        errors[:donnees] << "Vous devez renseigner les destinataires des données avant de continuer" unless donnees['destinataires'].present?
      end
    end
    state :validated
    state :refused
    state :technical_inputs do
      validates_presence_of :ips_de_production
    end
    state :deployed

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

    event :send_technical_inputs do
      transition from: :validated, to: :technical_inputs
    end

    event :deploy_application do
      transition from: :technical_inputs, to: :deployed
    end
  end

  def short_workflow?
    fournisseur_de_donnees == 'api-entreprise'
  end

  def applicant
    User.with_role(:applicant, self).first
  end

  private

  def agreements_validation
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end

  def fournisseur_de_donnees_validation
    errors[:demarche] << "Vous devez renseigner l'intitulé de la démarche avant de continuer" unless demarche&.fetch('intitule', nil).present?
    errors[:fournisseur_de_donnees] << "Vous devez renseigner le fournisseur de données avant de continuer" unless fournisseur_de_donnees.present?
  end
end
