class Enrollment::Dgfip < Enrollment
  resourcify

  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  validate :initial_validation
  validate :convention_validated?

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validate :sent_validation

      def sent_validation
        errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention.present?
        errors[:fondement_juridique] << "Vous devez renseigner le fondement juridique avant de continuer" unless fondement_juridique.present?
      end
    end
    state :validated
    state :refused
    state :technical_inputs do
      validates_presence_of :ips_de_production
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
    {
      'id' => id,
      'demarche' => {
        'intitule' => fournisseur_de_service
      },
      'applicant' => applicant,
      'documents' => documents.as_json(methods: :type),
      'state' => state,
      'fournisseur_de_donnees' => fournisseur_de_donnees,
      'fournisseur_de_service' => fournisseur_de_service,
      'description_service' => description_service,
      'fondement_juridique' => fondement_juridique,
      'scope_dgfip_RFR' => scope_dgfip_RFR,
      'scope_dgfip_adresse_fiscale_taxation' => scope_dgfip_adresse_fiscale_taxation,
      'nombre_demandes_annuelle' => nombre_demandes_annuelle,
      'pic_demandes_par_heure' => pic_demandes_par_heure,
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
      'autorite_certification_nom' => autorite_certification_nom,
      'autorite_certification_fonction' => autorite_certification_fonction,
      'france_connect' => france_connect,
      'administration' => administration,
      'autorisation_legale' => autorisation_legale,
      'demarche_cnil' => demarche_cnil,
      'date_homologation' => date_homologation,
      'date_fin_homologation' => date_fin_homologation,
      'delegue_protection_donnees' => delegue_protection_donnees,
      'certificat_pub_production' => certificat_pub_production,
      'autorite_certification' => autorite_certification,
      'ips_de_production' => ips_de_production,
      'mise_en_production' => mise_en_production,
      'recette_fonctionnelle' => recette_fonctionnelle,
      'validation_de_convention' => validation_de_convention
    }
  end

  private

  def initial_validation
    errors[:fournisseur_de_service] << "Vous devez renseigner le fournisseur de service avant de continuer" unless fournisseur_de_service.present?
    errors[:description_service] << "Vous devez renseigner la description du service avant de continuer" unless description_service.present?
  end

  def convention_validated?
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end
end
