class Enrollment::Dgfip < Enrollment
  resourcify

  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validate :fields_validation

      def fields_validation
        %w[dpo technique responsable_traitement]. each do |contact_type|
          contact = contacts&.find { |e| e['id'] == contact_type }
          errors[:contacts] << "Vous devez renseigner le #{contact&.fetch('heading', nil)} avant de continuer" unless contact&.fetch('nom', false)&.present? && contact&.fetch('email', false)&.present?
        end

        errors[:siren] << "Vous devez renseigner le SIREN de votre organisation avant de continuer" unless siren.present?
        errors[:demarche] << "Vous devez renseigner la description de la démarche avant de continuer" unless demarche && demarche['description'].present?
        errors[:demarche] << "Vous devez renseigner le fondement juridique de la démarche avant de continuer" unless (demarche && demarche['fondement_juridique'].present?) || documents.where(type: 'Document::LegalBasis').present?
        errors[:donnees] << "Vous devez renseigner la conservation des données avant de continuer" unless donnees && donnees['conservation'].present?
        errors[:donnees] << "Vous devez renseigner les destinataires des données avant de continuer" unless donnees && donnees['destinataires'].present?
      end
    end
    state :validated
    state :refused
    state :technical_inputs do
      validate :fields

      def fields
        errors[:ips_de_production] << "Vous devez renseigner les IP(s) de production avant de continuer" unless ips_de_production.present?
      end
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

  def as_json(*params)
    super(*params).merge({
      'id' => id,
      'applicant' => applicant.as_json,
      'fournisseur_de_donnees' => fournisseur_de_donnees,
      'validation_de_convention' => validation_de_convention,
      'scopes' => scopes,
      'contacts' => contacts,
      'siren' => siren,
      'demarche' => demarche,
      'donnees' => donnees&.merge('destinataires' => donnees&.fetch('destinataires', {})),
      'state' => state,
      'documents' => documents.as_json(methods: :type),
      'messages' => messages.as_json(include: :sender),
      'autorite_certification' => autorite_certification,
      'ips_de_production' => ips_de_production,
      'autorite_certification_nom' => autorite_certification_nom,
      'autorite_certification_fonction' => autorite_certification_fonction,
      'date_homologation' => date_homologation,
      'date_fin_homologation' => date_fin_homologation,
      'nombre_demandes_annuelle' => nombre_demandes_annuelle,
      'pic_demandes_par_seconde' => pic_demandes_par_seconde,
      'nombre_demandes_mensuelles_jan' => nombre_demandes_mensuelles_jan,
      'nombre_demandes_mensuelles_fev' => nombre_demandes_mensuelles_fev,
      'nombre_demandes_mensuelles_mar' => nombre_demandes_mensuelles_mar,
      'nombre_demandes_mensuelles_avr' => nombre_demandes_mensuelles_avr,
      'nombre_demandes_mensuelles_mai' => nombre_demandes_mensuelles_mai,
      'nombre_demandes_mensuelles_jui' => nombre_demandes_mensuelles_jui,
      'nombre_demandes_mensuelles_jul' => nombre_demandes_mensuelles_jul,
      'nombre_demandes_mensuelles_aou' => nombre_demandes_mensuelles_aou,
      'nombre_demandes_mensuelles_sep' => nombre_demandes_mensuelles_sep,
      'nombre_demandes_mensuelles_oct' => nombre_demandes_mensuelles_oct,
      'nombre_demandes_mensuelles_nov' => nombre_demandes_mensuelles_nov,
      'nombre_demandes_mensuelles_dec' => nombre_demandes_mensuelles_dec,
      'recette_fonctionnelle' => recette_fonctionnelle
    })
  end
end
