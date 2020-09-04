class Enrollment::Cartobio < Enrollment
  def sent_validation
    contact = contacts&.find { |e| e["id"] == "technique" }
    errors[:contacts] << "Vous devez renseigner le responsable technique avant de continuer" unless contact&.fetch("email", false)&.present?

    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?

    # Données
    unless additional_content&.fetch("location_scopes", false)&.present? || documents.where(type: "Document::GeoShape").present?
      errors[:location_scopes] << "Vous devez renseigner le périmètre de données"
    end

    # Modalités d’utilisation
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?
    errors[:secret_statistique_agreement] << "Vous devez valider le respect du secret statistique avant de continuer" unless additional_content&.fetch("secret_statistique_agreement", false)&.present?
    errors[:partage_agreement] << "Vous devez valider la restriction du partage des données avant de continuer" unless additional_content&.fetch("partage_agreement", false)&.present?
    errors[:protection_agreement] << "Vous devez valider la mise en œuvre des mesures limitant la divulgation des données avant de continuer" unless additional_content&.fetch("protection_agreement", false)&.present?
    errors[:exhaustivite_agreement] << "Vous devez valider avoir pris connaissance de la non exhaustivité des données avant de continuer" unless additional_content&.fetch("exhaustivite_agreement", false)&.present?
    errors[:information_agreement] << "Vous devez valider l'information systématique à l'équipe CartoBio avant de continuer" unless additional_content&.fetch("information_agreement", false)&.present?

    unless user.email_verified
      errors[:base] << "L'accès à votre adresse email n'a pas pu être vérifié. Merci de vous rendre sur #{ENV.fetch("OAUTH_HOST")}/users/verify-email puis de cliquer sur 'Me renvoyer un code de confirmation'"
    end
  end
end
