# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
    Document::CNILVoucher
    Document::CertificationResults
    Document::FranceConnectCompliance
    Document::LegalBasis
  ].freeze
  SECURITY_DOCUMENT_TYPES = %w[
    Document::ProductionCertificatePublicKey
    Document::CertificationAuthorityPublicKey
  ].freeze

  resourcify
  has_many :messages

  validate :agreement_validation
  validate :applicant_validation
  validate :step_1

  before_save :clean_json
  after_save :applicant_workflow

  has_many :documents
  accepts_nested_attributes_for :documents

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: 'filled_application' do
    state 'filled_application'
    state 'waiting_for_approval' do
      validate :cnil_voucher_detail_validation
      validate :certification_results_detail_validation
      validate :document_validation

      def cnil_voucher_detail_validation
        errors.add(:cnil_voucher_detail, "CNIL : la référence de l'avis doit être rempli") unless cnil_voucher_detail['reference'].present?
        errors.add(:cnil_voucher_detail, "CNIL : la formalité CNIL doit être remplie") unless cnil_voucher_detail['formality'].present?
      end

      def certification_results_detail_validation
        errors.add(:certification_results_detail, "HOMOLOGATION : le nom de l'autorité de certification doit être rempli") unless certification_results_detail['name'].present?
        errors.add(:certification_results_detail, "HOMOLOGATION : la fonction de l'autorité de certification doit être remplie") unless certification_results_detail['position'].present?
        errors.add(:certification_results_detail, "HOMOLOGATION : la date d'homologation doit être remplie") unless certification_results_detail['start'].present?
        errors.add(:certification_results_detail, "HOMOLOGATION : la durée d'homologation doit être remplie") unless certification_results_detail['duration'].present?
      end

      def document_validation
        unless DOCUMENT_TYPES.all? do |document|
          documents.where(type: document).present?
        end
        errors.add(:documents, 'Vous devez envoyer tous les documents demandés')
        end
      end
    end
    state 'application_approved'
    state 'technical_validation' do
      validates :applicant, presence: true
    end
    state 'application_ready' do
      validate :technical_validation
      validate :document_validation

      after_save :create_archive

      def document_validation
        unless SECURITY_DOCUMENT_TYPES.all? do |document|
          documents.where(type: document).present?
        end
          errors.add(:documents, 'Vous devez envoyer tous les documents demandés')
        end
      end

      def technical_validation
        errors.add(:production_ips, 'Vous devez fournir les IPs de production') unless production_ips.present?
      end

      def create_archive
        zip_file = Rails.root.join("tmp/#{SecureRandom.hex}.zip")

        documents_to_zip = documents.select { |e| SECURITY_DOCUMENT_TYPES.include?(e.type) }

        Zip::File.open(zip_file, Zip::File::CREATE) do |zipfile|
          documents_to_zip.each do |document|
            zipfile.add("#{SecureRandom.hex}-#{File.basename(document.attachment.path)}", document.attachment.file.path)
          end
          zipfile.get_output_stream("production_ips.txt") { |f| f.write production_ips }
        end

        documents.create(
          type: 'Document::SecurityArchive',
          attachment: zip_file.open
        )
        FileUtils.rm(zip_file)
      end
    end
    state 'deployed'

    after_transition %w[filled_application completed_application] => 'waiting_for_approval' do |enrollment, transition|
      enrollment.messages.create(
        content: 'votre dossier a été complèté'
      )
    end
    event 'complete_application' do
      transition %w[filled_application completed_application] => 'waiting_for_approval'
    end

    event 'send_application' do
      transition 'completed_application' => 'waiting_for_approval'
    end

    before_transition 'waiting_for_approval' => 'filled_application' do |enrollment, transition|
      enrollment.messages.create(content: 'Votre dossier a été refusé')
    end
    event 'refuse_application' do
      transition %w[filled_application waiting_for_approval] => 'filled_application'
    end

    after_transition any => 'application_approved' do |enrollment, transition|
      enrollment.messages.create(
        content: 'votre dossier a été approuvé'
      )
    end
    event 'approve_application' do
      transition %w[filled_application completed_application waiting_for_approval] => 'application_approved'
    end

    after_transition any => 'technical_validation' do |enrollment, transition|
      enrollment.messages.create(
        content: 'vous avez signé la convention',
      )
    end
    event 'sign_convention' do
      transition 'application_approved' => 'technical_validation'
    end

    after_transition any => 'application_ready' do |enrollment, transition|
      enrollment.messages.create(
        content: "vos données de sécurité sont en cours d'intégration",
      )
    end
    event 'deploy_security' do
      transition %w[application_ready technical_validation] => 'application_ready'
    end

    after_transition any => 'deployed' do |enrollment, transition|
      enrollment.messages.create(
        content: 'votre application est prête pour la mise en production',
      )
    end
    event 'deploy_application' do
      transition 'application_ready' => 'deployed'
    end
  end

  private

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
