# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  validate :convention_validated?

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
  end

  private

  def convention_validated?
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end

  def clean_json
    self.service_description = _clean_json(service_description)
    self.legal_basis = _clean_json(legal_basis)
    self.applicant = _clean_json(applicant)
  end

  def _clean_json(hash)
    return hash unless hash.is_a?(Hash)
    Hash[hash.map do |k, v|
      [k, v.blank? ? nil : v]
    end]
  end

  def step_1
    errors[:service_description] << "Vous devez décrire le service avant de continer" unless service_description&.fetch('main')
    errors[:legal_basis] << "Vous devez décrire le fondement légal avant de continer" unless legal_basis&.fetch('comment')
    errors[:seasonality] << "Vous devez renseigner la saisonnalité" unless service_description&.fetch('seasonality')&.count&.positive? && service_description['seasonality'].all? { |e| e['max_charge'].present? }
  end

  def agreement_validation
    return if agreement

    errors.add(:agreement, "Vous devez accepter les conditions d'utilisation")
  end

  def applicant_validation # rubocop:disable Metrics/AbcSize
    return unless applicant_changed? && can_sign_convention?

    errors.add(:applicant, "Vous devez renseigner l'Email") unless applicant['email'].present?
    errors.add(:applicant, 'Vous devez renseigner la Fonction') unless applicant['position'].present?
    errors.add(:applicant, 'Vous devez accepter la convention') unless applicant['agreement'].present?
  end

  def applicant_workflow
    if applicant&.fetch('email', nil).present? &&
       can_sign_convention?
      sign_convention!
    end
  end
end
