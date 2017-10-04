# frozen_string_literal: true

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
    Document::CNILVoucher
    Document::CertificationResults
    Document::FranceConnectCompliance
  ].freeze

  resourcify
  has_many :messages

  validate :agreement_validation
  validate :applicant_validation
  before_save :clean_json
  after_touch :document_workflow
  after_save :applicant_workflow

  has_many :documents
  accepts_nested_attributes_for :documents

  state_machine :state, initial: 'filled_application' do
    state 'filled_application'
    state 'waiting_for_approval'
    state 'application_approved'
    state 'application_ready'
    state 'deployed'

    event 'complete_application' do
      transition %w[filled_application completed_application] => 'waiting_for_approval'
    end

    event 'send_application' do
      transition 'completed_application' => 'waiting_for_approval'
    end

    event 'refuse_application' do
      transition 'waiting_for_approval' => 'filled_application'
    end

    event 'approve_application' do
      transition %w[filled_application completed_application waiting_for_approval] => 'application_approved'
    end

    event 'sign_convention' do
      transition 'application_approved' => 'application_ready'
    end

    event 'deploy' do
      transition 'application_ready' => 'deployed'
    end
  end

  private

  def clean_json
    self.service_description = _clean_json(service_description)
    self.legal_basis = _clean_json(legal_basis)
    self.applicant = _clean_json(applicant)
  end

  def _clean_json(h)
    return h unless h.is_a?(Hash)
    Hash[h.map do |k, v|
      [k, v.blank? ? nil : v]
    end]
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

  def document_workflow
    if DOCUMENT_TYPES.all? do |document|
      documents.where(type: document).present?
    end && can_complete_application?

      complete_application!
    end

    true
  end
end
