class Enrollment::LeTaxiChauffeurs < Enrollment
  def sent_validation
    contact = contacts&.find { |e| e["id"] == "metier" }
    errors[:contacts] << "Vous devez renseigner un chargé de suivit avant de continuer" unless contact&.fetch("email", false)&.present?

    rgpd_validation

    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?
    unless user.email_verified
      errors[:base] << "L'accès à votre adresse email n'a pas pu être vérifié. Merci de vous rendre sur #{ENV.fetch("OAUTH_HOST")}/users/verify-email puis de cliquer sur 'Me renvoyer un code de confirmation'"
    end
  end
end
