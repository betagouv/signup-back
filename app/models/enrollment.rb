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
  belongs_to :copied_from_enrollment, class_name: :Enrollment, foreign_key: :copied_from_enrollment_id, optional: true
  validates :copied_from_enrollment, uniqueness: true, if: -> { copied_from_enrollment.present? }
  belongs_to :previous_enrollment, class_name: :Enrollment, foreign_key: :previous_enrollment_id, optional: true
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
        refuse_application: "refused"
      }

      enrollment.events.create!(
        name: state_machine_event_to_event_names[transition.event],
        user_id: transition.args[0][:user_id],
        comment: transition.args[0][:comment]
      )
    end

    before_transition sent: :validated do |enrollment, _|
      if enrollment.target_api == "api_particulier" && !ENV["DISABLE_API_PARTICULIER_BRIDGE"].present?
        ApiParticulierBridge.call(enrollment)
      end

      if enrollment.target_api == "franceconnect" && !ENV["DISABLE_FRANCECONNECT_BRIDGE"].present?
        FranceconnectBridge.call(enrollment)
      end

      if enrollment.target_api == "api_entreprise" && !ENV["DISABLE_API_ENTREPRISE_BRIDGE"].present?
        ApiEntrepriseBridge.call(enrollment)
      end

      if enrollment.target_api == "api_droits_cnam" && !ENV["DISABLE_API_DROITS_CNAM_BRIDGE"].present?
        ApiDroitsCnamBridge.call(enrollment)
      end

      if enrollment.target_api == "api_impot_particulier_fc_sandbox" && !ENV["DISABLE_API_IMPOT_PARTICULIER_BRIDGE"].present?
        ApiImpotParticulierFcSandboxBridge.call(enrollment)
      end

      if enrollment.target_api == "francerelance_fc" && !ENV["DISABLE_FRANCECONNECT_BRIDGE"].present?
        FranceconnectBridge.call(enrollment)
      end

      if enrollment.target_api == "aidants_connect" && !ENV["DISABLE_AIDANTS_CONNECT_BRIDGE"].present?
        AidantsConnectBridge.call(enrollment)
      end

      if enrollment.target_api == "hubee" && !ENV["DISABLE_HUBEE_BRIDGE"].present?
        HubeeBridge.call(enrollment)
      end
    end

    event :loop_without_job do
      transition any => same
    end
  end

  def notify(event, *args)
    notifier_class.new(self).public_send(event, *args)
  end

  def notifier_class
    Kernel.const_get("#{self.class}Notifier")
  rescue NameError
    BaseNotifier
  end

  def subscribers
    unless DataProvidersConfiguration.instance.exists?(target_api)
      raise ApplicationController::UnprocessableEntity, "Une erreur inattendue est survenue: API cible invalide."
    end
    # Pure string conditions in a where query is dangerous!
    # see https://guides.rubyonrails.org/active_record_querying.html#pure-string-conditions
    # As long as the injected parameters is verified against a whitelist, we consider this safe.
    User.where("'#{target_api}:subscriber' = ANY(roles)")
  end

  def dpo_email=(email)
    self.dpo = if email.empty?
      nil
    else
      User.reconcile({"email" => email.strip})
    end
  end

  def dpo_email
    dpo.try(:email)
  end

  def responsable_traitement_email=(email)
    self.responsable_traitement = if email.empty?
      nil
    else
      User.reconcile({"email" => email.strip})
    end
  end

  def responsable_traitement_email
    responsable_traitement.try(:email)
  end

  def user_email=(email)
    self.user = if email.empty?
      nil
    else
      User.reconcile({"email" => email.strip})
    end
  end

  def responsable_traitement_full_name
    [responsable_traitement_given_name, responsable_traitement_family_name].join(" ")
  end

  def dpo_full_name
    [dpo_given_name, dpo_family_name].join(" ")
  end

  def submitted_at
    events.where(name: "submitted").order("created_at").last["created_at"]
  end

  def validated_at
    events.where(name: "validated").order("created_at").last["created_at"]
  end

  def copy(current_user)
    copied_enrollment = dup
    copied_enrollment.status = :pending
    copied_enrollment.user = current_user
    copied_enrollment.linked_token_manager_id = nil
    copied_enrollment.copied_from_enrollment = self
    copied_enrollment.save!
    copied_enrollment.events.create(
      name: "copied",
      user_id: current_user.id,
      comment: "Demande d’origine : ##{id}"
    )
    documents.each do |document|
      copied_document = document.dup
      copied_document.attachment = File.open(document.attachment.file.file)
      copied_enrollment.documents << copied_document
    end

    copied_enrollment
  end

  protected

  def clean_and_format_scopes
    # we need to convert boolean values as it is send as string because of the data-form serialisation
    self.scopes = scopes.transform_values { |value| value.to_s == "true" }

    # in a similar way, format additional boolean content
    self.additional_content = additional_content.transform_values do |value|
      case value.to_s
      when "true"
        true
      when "false"
        false
      else
        value
      end
    end
  end

  def set_company_info
    # taking the siret from users organization ensure the user belongs to the organization
    # this might not be the proper place to do this kind of authorization check
    selected_organization = user.organizations.find { |o| o["id"] == organization_id }
    if selected_organization.nil?
      raise ApplicationController::Forbidden, "Vous ne pouvez pas déposer une demande pour une organisation à laquelle vous n’appartenez pas"
    end
    siret = selected_organization["siret"]

    response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/#{siret}")

    if response.status.success? && response.parse["etablissement"]["etat_administratif"] == "A"
      nom_raison_sociale = response.parse["etablissement"]["unite_legale"]["denomination"]
      nom_raison_sociale ||= response.parse["etablissement"]["denomination_usuelle"]
      nom = response.parse["etablissement"]["unite_legale"]["nom"]
      prenom_1 = response.parse["etablissement"]["unite_legale"]["prenom_1"]
      prenom_2 = response.parse["etablissement"]["unite_legale"]["prenom_2"]
      prenom_3 = response.parse["etablissement"]["unite_legale"]["prenom_3"]
      prenom_4 = response.parse["etablissement"]["unite_legale"]["prenom_4"]
      nom_raison_sociale ||= "#{nom + "*" unless nom.nil?}#{prenom_1 unless prenom_1.nil?}#{" " + prenom_2 unless prenom_2.nil?}#{" " + prenom_3 unless prenom_3.nil?}#{" " + prenom_4 unless prenom_4.nil?}"
      self.siret = siret
      self.nom_raison_sociale = nom_raison_sociale
    else
      self.organization_id = nil
      self.siret = nil
      self.nom_raison_sociale = nil
    end
  end

  def update_validation
    errors[:intitule] << "Vous devez renseigner l’intitulé de la démarche avant de continuer. Aucun changement n’a été sauvegardé." unless intitule.present?
    # the following 2 errors should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d’API cible. Aucun changement n’a été sauvegardé." unless target_api.present?
    errors[:organization_id] << "Une erreur inattendue est survenue: pas d’organisation. Aucun changement n’a été sauvegardé." unless organization_id.present?
  end

  def rgpd_validation
    errors[:data_retention_period] << "Vous devez renseigner la conservation des données avant de continuer" unless data_retention_period.present?
    errors[:data_recipients] << "Vous devez renseigner les destinataires des données avant de continuer" unless data_recipients.present?
    errors[:dpo_family_name] << "Vous devez renseigner un nom pour le délégué à la protection des données avant de continuer" unless dpo_family_name.present?
    errors[:dpo_email] << "Vous devez renseigner un email pour le délégué à la protection des données avant de continuer" unless dpo_email.present?
    errors[:dpo_phone_number] << "Vous devez renseigner un numéro de téléphone pour le délégué à la protection des données avant de continuer" unless dpo_phone_number.present?
    errors[:responsable_traitement_family_name] << "Vous devez renseigner un nom pour le responsable de traitement avant de continuer" unless responsable_traitement_family_name.present?
    errors[:responsable_traitement_email] << "Vous devez renseigner un email pour le responsable de traitement avant de continuer" unless responsable_traitement_email.present?
    errors[:responsable_traitement_phone_number] << "Vous devez renseigner un numéro de téléphone pour le responsable de traitement avant de continuer" unless responsable_traitement_phone_number.present?
  end

  def contact_validation(key, label, validate_full_profile = false)
    email_regex = URI::MailTo::EMAIL_REGEXP
    # loose homemade regexp to match large amount of phone number
    phone_number_regex = /^\+?(?:[0-9][ -]?){6,14}[0-9]$/

    contact = contacts&.find { |e| e["id"] == key }
    errors[:contacts] << "Vous devez renseigner un email valide pour le #{label} avant de continuer" unless email_regex.match?(contact&.fetch("email", ""))
    errors[:contacts] << "Vous devez renseigner un numéro de téléphone valide pour le #{label} avant de continuer" unless phone_number_regex.match?(contact&.fetch("phone_number", ""))

    if validate_full_profile
      errors[:contacts] << "Vous devez renseigner un intitulé de poste valide pour le #{label} avant de continuer" unless contact&.fetch("job", false)&.present?
      errors[:contacts] << "Vous devez renseigner un nom valide pour le #{label} avant de continuer" unless contact&.fetch("given_name", false)&.present?
      errors[:contacts] << "Vous devez renseigner un prénom valide pour le #{label} avant de continuer" unless contact&.fetch("family_name", false)&.present?
    end
  end

  def contact_technique_validation
    contact_validation("technique", "contact technique", false)
  end

  def contact_metier_validation
    contact_validation("metier", "contact métier", false)
  end

  def cadre_juridique_validation
    errors[:fondement_juridique_title] << "Vous devez renseigner la nature du texte vous autorisant à traiter les données avant de continuer" unless fondement_juridique_title.present?
    errors[:fondement_juridique_url] << "Vous devez joindre l’URL ou le document du texte relatif au traitement avant de continuer" unless fondement_juridique_url.present? || documents.where(type: "Document::LegalBasis").present?
  end

  def scopes_validation
    errors[:scopes] << "Vous devez cocher au moins un périmètre de données avant de continuer" unless scopes.any? { |_, v| v }
  end

  def previous_enrollment_id_validation
    errors[:previous_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée" unless previous_enrollment_id.present?
  end

  def sent_validation
    contact = contacts&.find { |e| e["id"] == "technique" }
    errors[:contacts] << "Vous devez renseigner le responsable technique avant de continuer" unless contact&.fetch("email", false)&.present?

    rgpd_validation
    cadre_juridique_validation

    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:siret] << "Vous devez renseigner un SIRET d’organisation valide avant de continuer" unless nom_raison_sociale
    errors[:cgu_approved] << "Vous devez valider les modalités d’utilisation avant de continuer" unless cgu_approved?
    # TODO validate this plus full profile by default
    # errors[:dpo_is_informed] << "Vous devez confirmer avoir informé le DPD de votre organisation avant de continuer" unless dpo_is_informed?
  end
end
