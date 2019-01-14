# frozen_string_literal: true
class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  validate :update_validation

  before_save :clean_and_format_scopes
  before_save :set_company_info

  has_many :messages
  accepts_nested_attributes_for :messages
  has_many :documents, as: :attachable
  accepts_nested_attributes_for :documents

  # Be aware with the duplication of attribute with type
  scope :api_particulier, -> { where(fournisseur_de_donnees: 'api-particulier') }
  scope :dgfip, -> { where(fournisseur_de_donnees: 'dgfip') }
  scope :franceconnect, -> { where(fournisseur_de_donnees: 'franceconnect') }
  scope :api_droits_cnam, -> { where(fournisseur_de_donnees: 'api-droits-cnam') }

  scope :no_draft, -> {where.not(state: %w(pending))}
  scope :pending, -> {where.not(state: %w(validated refused))}
  scope :archived, -> {where(state: %w(validated refused))}

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validate :sent_validation
    end
    state :validated
    state :refused

    after_transition any => any do |enrollment, transition|
      event = transition.event.to_s
      user = transition.args.first&.fetch(:user)
      user&.add_role(event.as_personified_event.to_sym, enrollment)

      Enrollment::SendMailJob.perform_now(enrollment, user, event)
    end

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
      if enrollment.fournisseur_de_donnees == 'api-particulier'
        RegisterApiParticulierEnrollment.call(enrollment)
      end

      if ENV.fetch('ENABLE_REGISTER_FRANCECONNECT_ENROLLMENT') == 'True' && enrollment.fournisseur_de_donnees == 'franceconnect'
        RegisterFranceconnectEnrollment.call(enrollment)
      end
    end

    event :loop_without_job do
      transition any => same
    end
  end

  def other_party(user)
    if user.has_role?(:applicant, self)
      provider = self.class.name.underscore.split('/').last
      return User.where(provider: provider)
    end

    User.with_role(:applicant, self)
  end

  def applicant
    User.with_role(:applicant, self).first
  end

  def resource_provider
    self.class.name.demodulize.underscore
  end

  def self.with_role(type, user)
    return super(type, user) unless abstract?
    Rails.application.eager_load!

    enrollment_ids = descendants.map do |klass|
      klass.with_role(type, user).pluck(:id)
    end.flatten

    where(id: enrollment_ids)
  end

  def self.abstract?
    name == 'Enrollment'
  end

  def as_json(*_params)
    {
      'updated_at' => updated_at,
      'created_at' => created_at,
      'id' => id,
      'applicant' => applicant.as_json,
      'fournisseur_de_donnees' => fournisseur_de_donnees,
      'fournisseur_de_service' => fournisseur_de_service,
      'validation_de_convention' => validation_de_convention,
      'scopes' => scopes,
      'contacts' => contacts,
      'siret' => siret,
      'demarche' => demarche,
      'donnees' => donnees&.merge('destinataires' => donnees&.fetch('destinataires', {})),
      'state' => state,
      'documents' => documents.as_json(methods: :type),
      'messages' => messages.as_json(include: :sender),
      'token_id' => token_id
    }
  end

  protected

  def clean_and_format_scopes
    # we need to convert boolean values as it is send as string because of the data-form serialisation
    self.scopes = scopes.transform_values { |e| e.to_s == "true" }

    # remove the destinataires associated with disabled scopes
    scopes.each do |key, value|
      unless value
        donnees['destinataires'].delete(key.to_s)
      end
    end

    # in a similar way, format dgfip_data_years
    self.donnees['dgfip_data_years'] = donnees['dgfip_data_years'].transform_values { |e| e.to_s == "true" }
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
    errors[:base] << "Vous devez fournir un type d'enrôlement" if self.class.abstract?
    errors[:demarche] << "Vous devez renseigner l'intitulé de la démarche avant de continuer" unless demarche&.fetch('intitule', nil).present?
    errors[:fournisseur_de_donnees] << "Vous devez renseigner le fournisseur de données avant de continuer" unless fournisseur_de_donnees.present?
    errors[:siret] << "Vous devez renseigner le SIRET de votre organisation avant de continuer" unless siret.present?
  end

  def sent_validation
    %w[dpo technique responsable_traitement]. each do |contact_type|
      contact = contacts&.find { |e| e['id'] == contact_type }
      errors[:contacts] << "Vous devez renseigner le #{contact&.fetch('heading', nil)} avant de continuer" unless contact&.fetch('nom', false)&.present? && contact&.fetch('email', false)&.present?
    end

    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?
    errors[:validation_de_convention] << "Vous devez valider les modalités d'utilisation avant de continuer" unless validation_de_convention?
    errors[:demarche] << "Vous devez renseigner la description de la démarche avant de continuer" unless demarche && demarche['description'].present?
    errors[:demarche] << "Vous devez renseigner le fondement juridique de la démarche avant de continuer" unless demarche && demarche['fondement_juridique'].present?
    errors[:demarche] << "Vous devez renseigner le document associé au fondement juridique" unless (demarche && demarche['url_fondement_juridique'].present?) || documents.where(type: 'Document::LegalBasis').present?
  end
end
