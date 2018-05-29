class Enrollment::ApiEntreprise < Enrollment
  resourcify

  validate :fournisseur_de_donnees_validation
  validate :agreements_validation

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validate :fields_validation

      def fields_validation
        %w[dpo technique responsable_traitement]. each do |contact_type|
          contact = contacts.find { |e| e['id'] == contact_type }
          errors[:contacts] << "Vous devez renseigner le #{contact&.fetch('heading', nil)} avant de continuer" unless contact&.fetch('nom', false)&.present? && contact&.fetch('email', false)&.present?
        end

        errors[:siren] << "Vous devez renseigner le SIREN de votre organisation avant de continuer" unless siren.present?
        errors[:demarche] << "Vous devez renseigner la description de la démarche avant de continuer" unless demarche['description'].present?
        errors[:demarche] << "Vous devez renseigner le fondement juridique de la démarche avant de continuer" unless demarche['fondement_juridique'].present?
        errors[:donnees] << "Vous devez renseigner la conservation des données avant de continuer" unless donnees['conservation'].present?
        errors[:donnees] << "Vous devez renseigner les destinataires des données avant de continuer" unless donnees['destinataires'].present?
      end
    end
    state :validated
    state :refused

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
  end

  def short_workflow?
    true
  end

  def as_json(*params)
    {
      'id' => id,
      'applicant' => applicant,
      'fournisseur_de_donnees' => fournisseur_de_donnees,
      'validation_de_convention' => validation_de_convention,
      'scopes' => scopes,
      'contacts' => contacts,
      'siren' => siren,
      'demarche' => demarche,
      'donnees' => donnees&.merge('destinataires' => donnees&.fetch('destinataires', {})),
      'state' => state,
      'documents' => documents.as_json(methods: :type)
    }
  end

  private

  def agreements_validation
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end

  def fournisseur_de_donnees_validation
    errors[:demarche] << "Vous devez renseigner l'intitulé de la démarche avant de continuer" unless demarche&.fetch('intitule', nil).present?
    errors[:fournisseur_de_donnees] << "Vous devez renseigner le fournisseur de données avant de continuer" unless fournisseur_de_donnees.present?
  end
end
