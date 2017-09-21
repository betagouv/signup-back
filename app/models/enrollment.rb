class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
    Document::CNILVoucher
    Document::CertificationResults
    Document::FranceConnectCompliance
    Document::LegalBasis
  ].freeze

  resourcify
  validate :agreement_validation
  after_touch :workfollow

  has_many :documents
  accepts_nested_attributes_for :documents

  state_machine :state, initial: 'filled_application'do
    state 'filled_application'
    state 'waiting_for_approval'
    state 'application_approval'
    state 'deployed'

    event 'complete_application' do
      transition 'filled_application' => 'waiting_for_approval'
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

  def workfollow
    if DOCUMENT_TYPES.all? do |document|
      documents.where(type: document).present?
    end
      complete_application!
    end
    true
  end
end
