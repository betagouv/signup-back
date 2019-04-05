# frozen_string_literal: true
class Enrollment < ActiveRecord::Base
  validate :update_validation

  before_save :clean_and_format_scopes
  before_save :set_company_info

  has_many :documents, as: :attachable
  accepts_nested_attributes_for :documents
  belongs_to :user
  has_many :events

  scope :api_particulier, -> { where(target_api: 'api_particulier') }
  scope :dgfip, -> { where(target_api: 'dgfip') }
  scope :franceconnect, -> { where(target_api: 'franceconnect') }
  scope :api_droits_cnam, -> { where(target_api: 'api_droits_cnam') }
  scope :api_entreprise, -> { where(target_api: 'api_entreprise') }

  scope :no_draft, -> {where.not(status: %w(pending))}
  scope :pending, -> {where.not(status: %w(validated refused))}
  scope :archived, -> {where(status: %w(validated refused))}
  scope :status, -> (status) {where(status: status)}
  scope :target_api, -> (target_api) {where(target_api: target_api)}

  state_machine :status, initial: :pending do
    state :pending
    state :sent do
      validate :sent_validation
    end
    state :validated
    state :refused

    event :send_application do
      transition from: :pending, to: :sent
    end

    event :refuse_application do
      transition :sent => :refused, :pending => :refused
    end

    event :review_application do
      transition from: :sent, to: :pending
    end

    event :validate_application do
      transition from: :sent, to: :validated
    end

    before_transition :sent => :validated do |enrollment, transition|
      if enrollment.target_api == 'api_particulier'
        RegisterApiParticulierEnrollment.call(enrollment)
      end

      if enrollment.target_api == 'franceconnect'
        RegisterFranceconnectEnrollment.call(enrollment)
      end

      if enrollment.target_api == 'dgfip'
        RegisterDgfipEnrollment.call(enrollment)
      end
    end

    event :loop_without_job do
      transition any => same
    end
  end

  def admins
    User.where(role: self.target_api)
  end

  protected

  def clean_and_format_scopes
    # we need to convert boolean values as it is send as string because of the data-form serialisation
    self.scopes = scopes.transform_values { |e| e.to_s == "true" }

    # in a similar way, format additional boolean content
    if additional_content.key?('dgfip_data_years')
      self.additional_content['dgfip_data_years'] =
          additional_content['dgfip_data_years'].transform_values { |e| e.to_s == "true" }
    end
    if additional_content.key?('rgpd_general_agreement')
      self.additional_content['rgpd_general_agreement'] =
          additional_content['rgpd_general_agreement'].to_s == "true"
    end
    if additional_content.key?('has_alternative_authentication_methods')
      self.additional_content['has_alternative_authentication_methods'] =
          additional_content['has_alternative_authentication_methods'].to_s == "true"
    end
  end

  def set_company_info
    escapedSpacelessSiret = CGI.escape(siret.delete(" \t\r\n"))
    url = URI("https://sirene.entreprise.api.gouv.fr/v1/siret/#{escapedSpacelessSiret}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)

    response = http.request(request)

    if response.code == '200'
      nom_raison_sociale = JSON.parse(response.read_body)["etablissement"]["nom_raison_sociale"]
      self.nom_raison_sociale = nom_raison_sociale
    else
      self.nom_raison_sociale = nil
    end
  end

  def update_validation
    errors[:intitule] << "Vous devez renseigner l'intitulé de la démarche avant de continuer" unless intitule.present?
    errors[:target_api] << "Vous devez renseigner le fournisseur de données avant de continuer" unless target_api.present?
    errors[:siret] << "Vous devez renseigner le SIRET de votre organisation avant de continuer" unless siret.present?
  end

  def sent_validation
    %w[dpo technique responsable_traitement]. each do |contact_type|
      contact = contacts&.find { |e| e['id'] == contact_type }
      errors[:contacts] << "Vous devez renseigner le #{contact&.fetch('heading', nil)} avant de continuer" unless contact&.fetch('nom', false)&.present? && contact&.fetch('email', false)&.present?
    end

    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?
    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:fondement_juridique_title] << "Vous devez renseigner le fondement juridique de la démarche avant de continuer" unless fondement_juridique_title.present?
    errors[:fondement_juridique_url] << "Vous devez renseigner le document associé au fondement juridique" unless (fondement_juridique_url.present?) || documents.where(type: 'Document::LegalBasis').present?
    errors[:base] << "Vous devez activer votre compte api.gouv.fr avant de continuer. Merci de cliquer sur le lien d'activation que vous avez reçu par mail." unless user.email_verified
  end
end
