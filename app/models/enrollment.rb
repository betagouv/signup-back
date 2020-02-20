class Enrollment < ActiveRecord::Base
  self.inheritance_column = "target_api"

  # enable Single Table Inheritance with target_api as discriminatory field
  class << self
    # ex: 'api_particulier' => Enrollment::ApiParticulier
    def find_sti_class(target_api)
      "Enrollment::#{target_api.underscore.classify}".constantize
    end

    # ex: Enrollment::ApiParticulier => 'api_particulier'
    def sti_name
      name.demodulize.underscore
    end
  end

  validate :update_validation

  before_save :clean_and_format_scopes
  before_save :set_company_info, if: :will_save_change_to_organization_id?

  has_many :documents, as: :attachable
  accepts_nested_attributes_for :documents
  belongs_to :user
  has_many :events, dependent: :destroy
  belongs_to :dpo, class_name: :User, foreign_key: :dpo_id, optional: true
  belongs_to :responsable_traitement, class_name: :User, foreign_key: :responsable_traitement_id, optional: true

  state_machine :status, initial: :pending do
    state :pending
    state :sent do
      validate :sent_validation
    end
    state :modification_pending
    state :validated
    state :refused

    event :notify do
      transition modification_pending: same
    end

    event :send_application do
      transition from: [:pending, :modification_pending], to: :sent
    end

    event :refuse_application do
      transition from: [:modification_pending, :sent], to: :refused
    end

    event :review_application do
      transition from: :sent, to: :modification_pending
    end

    event :validate_application do
      transition from: :sent, to: :validated
    end

    before_transition all => all do |enrollment, transition|
      state_machine_event_to_event_names = {
        notify: "notified",
        send_application: "submitted",
        validate_application: "validated",
        review_application: "asked_for_modification",
        refuse_application: "refused",
      }

      enrollment.events.create!(
        name: state_machine_event_to_event_names[transition.event],
        user_id: transition.args[0][:user_id],
        comment: transition.args[0][:comment]
      )
    end

    before_transition sent: :validated do |enrollment, _|
      if enrollment.target_api == "api_particulier" && ! ENV["DISABLE_API_PARTICULIER_BRIDGE"].present?
        ApiParticulierBridge.call(enrollment)
      end

      if enrollment.target_api == "franceconnect" && ! ENV["DISABLE_FRANCECONNECT_BRIDGE"].present?
        FranceconnectBridge.call(enrollment)
      end

      if enrollment.target_api == "api_entreprise" && ! ENV["DISABLE_API_ENTREPRISE_BRIDGE"].present?
        ApiEntrepriseBridge.call(enrollment)
      end
    end

    event :loop_without_job do
      transition any => same
    end
  end

  def admins
    User.where("? = ANY(roles)", target_api)
  end

  def dpo_email=(email)
    self.dpo = if email.empty?
      nil
    else
      User.reconcile({"email" => email})
    end
  end

  def dpo_email
    dpo.try(:email)
  end

  def responsable_traitement_email=(email)
    self.responsable_traitement = if email.empty?
      nil
    else
      User.reconcile({"email" => email})
    end
  end

  def responsable_traitement_email
    responsable_traitement.try(:email)
  end

  def submitted_at
    events.where(name: "submitted").order("created_at").last["created_at"]
  end

  protected

  def clean_and_format_scopes
    # we need to convert boolean values as it is send as string because of the data-form serialisation
    self.scopes = scopes.transform_values { |e| e.to_s == "true" }

    # in a similar way, format additional boolean content
    if additional_content.key?("rgpd_general_agreement")
      additional_content["rgpd_general_agreement"] =
        additional_content["rgpd_general_agreement"].to_s == "true"
    end
    if additional_content.key?("has_alternative_authentication_methods")
      additional_content["has_alternative_authentication_methods"] =
        additional_content["has_alternative_authentication_methods"].to_s == "true"
    end
  end

  def set_company_info
    # taking the siret from users organization ensure the user belongs to the organization
    # this might not be the proper place to do this kind of authorization check
    selected_organization = user.organizations.find { |o| o["id"] == organization_id }
    if selected_organization.nil?
      raise ApplicationController::Forbidden, "Vous ne pouvez pas déposer une demande pour une organisation à laquelle vous n'appartenez pas"
    end
    siret = selected_organization["siret"]

    response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v1/siret/#{siret}")

    if response.status.success?
      nom_raison_sociale = response.parse["etablissement"]["nom_raison_sociale"]
      self.siret = siret
      self.nom_raison_sociale = nom_raison_sociale
    else
      self.organization_id = nil
      self.siret = nil
      self.nom_raison_sociale = nil
    end
  end

  def update_validation
    errors[:intitule] << "Vous devez renseigner l'intitulé de la démarche avant de continuer. Aucun changement n'a été sauvegardé." unless intitule.present?
    # the following 2 errors should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d'API cible. Aucun changement n'a été sauvegardé." unless target_api.present?
    errors[:organization_id] << "Une erreur inattendue est survenue: pas d'organisation. Aucun changement n'a été sauvegardé." unless organization_id.present?
  end

  def sent_validation
    contact = contacts&.find { |e| e["id"] == "technique" }
    errors[:contacts] << "Vous devez renseigner le responsable technique avant de continuer" unless contact&.fetch("email", false)&.present?

    errors[:dpo_label] << "Vous devez renseigner un nom pour le délégué à la protection des données avant de continuer" unless dpo_label.present?
    errors[:dpo_email] << "Vous devez renseigner un email pour le délégué à la protection des données avant de continuer" unless dpo_email.present?
    errors[:dpo_phone_number] << "Vous devez renseigner un numéro de téléphone pour le délégué à la protection des données avant de continuer" unless dpo_phone_number.present?
    errors[:responsable_traitement_label] << "Vous devez renseigner un nom pour le responsable de traitement avant de continuer" unless responsable_traitement_label.present?
    errors[:responsable_traitement_email] << "Vous devez renseigner un email pour le responsable de traitement avant de continuer" unless responsable_traitement_email.present?
    errors[:responsable_traitement_phone_number] << "Vous devez renseigner un numéro de téléphone pour le responsable de traitement avant de continuer" unless responsable_traitement_phone_number.present?

    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?
    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:fondement_juridique_title] << "Vous devez renseigner la nature du texte vous autorisant à traiter les données avant de continuer" unless fondement_juridique_title.present?
    errors[:fondement_juridique_url] << "Vous devez joindre l'URL ou le document du texte relatif au traitement avant de continuer" unless fondement_juridique_url.present? || documents.where(type: "Document::LegalBasis").present?
    unless user.email_verified
      errors[:base] << "Vous devez activer votre compte api.gouv.fr avant de continuer.
Merci de cliquer sur le lien d'activation que vous avez reçu par mail.
Vous pouvez également demander un nouveau lien d'activation en cliquant sur le lien
suivant #{ENV.fetch("OAUTH_HOST")}/users/send-email-verification?notification=email_verification_required"
    end
  end
end
