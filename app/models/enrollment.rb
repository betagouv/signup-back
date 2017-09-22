class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
    Document::CNILVoucher
    Document::CertificationResults
    Document::FranceConnectCompliance
  ].freeze

  resourcify
  validate :agreement_validation
  after_touch :document_workflow
  after_save :applicant_workflow

  has_many :documents
  accepts_nested_attributes_for :documents

  state_machine :state, initial: 'filled_application'do
    state 'filled_application'
    state 'completed_application'
    state 'waiting_for_approval'
    state 'application_approval'
    state 'deployed'

    event 'complete_application' do
      transition %w[filled_application completed_application] => 'completed_application'
    end

    event 'send_application' do
      transition 'completed_application' => 'waiting_for_approval'
    end

    event 'approve_application' do
      transition 'waiting_for_approval' => 'application_approval'
    end

    event 'deploy' do
      transition 'application_approval' => 'deployed'
    end
  end

  private

  def agreement_validation
    return if agreement

    errors.add(:agreement, "Vous devez accepter les conditions d'utilisation")
  end

  def applicant_workflow
    if applicant&.fetch('email', nil).present? &&
      can_send_application?
      send_application!
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
