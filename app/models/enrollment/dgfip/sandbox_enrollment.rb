class Enrollment::Dgfip::SandboxEnrollment < Enrollment
  protected

  def sent_validation
    # Organisation
    errors[:siret] << "Vous devez renseigner un SIRET d’organisation valide avant de continuer" unless nom_raison_sociale.present?

    # Description
    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?

    # Mise en œuvre
    contact_technique_validation
    contact_technique = contacts&.find { |e| e["id"] == "technique" }
    errors[:contacts] << "Vous devez renseigner un prénom pour le contact technique avant de continuer" if contact_technique&.fetch("given_name", "").to_s.strip.empty?
    errors[:contacts] << "Vous devez renseigner un nom pour le contact technique avant de continuer" if contact_technique&.fetch("family_name", "").to_s.strip.empty?

    # Données
    errors[:rgpd_general_agreement] << "Vous devez attester respecter les principes RGPD avant de continuer" unless additional_content&.fetch("rgpd_general_agreement", false)

    # CGU
    errors[:cgu_approved] << "Vous devez valider les modalités d’utilisation avant de continuer" unless cgu_approved?
  end
end
