class Enrollment::ApiImpotParticulierStep2 < Enrollment
  before_save :set_info_from_previous_enrollment, if: :will_save_change_to_previous_enrollment_id?

  protected

  def set_info_from_previous_enrollment
    self.intitule = previous_enrollment.intitule
    self.organization_id = previous_enrollment.organization_id
    set_company_info
  end

  def update_validation
    errors[:previous_enrollment_id] << "Vous devez associer cette demande à une demande API Impôt particulier validée. Aucun changement n'a été sauvegardé." unless previous_enrollment_id.present?
    # the following 2 errors should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d’API cible. Aucun changement n'a été sauvegardé." unless target_api.present?
  end

  def sent_validation
    # Recette fonctionnelle
    errors[:recette_fonctionnelle] << "Vous devez attester avoir réaliser une recette fonctionnelle avant de continuer" unless additional_content&.fetch("recette_fonctionnelle", false)&.present?

    # Données personnelles
    rgpd_validation

    # Cadre juridique
    errors[:fondement_juridique_title] << "Vous devez renseigner la nature du texte vous autorisant à traiter les données avant de continuer" unless fondement_juridique_title.present?
    errors[:fondement_juridique_url] << "Vous devez joindre l'URL ou le document du texte relatif au traitement avant de continuer" unless fondement_juridique_url.present? || documents.where(type: "Document::LegalBasis").present?

    # Homologation de securite
    errors[:autorite_homologation_nom] << "Vous devez renseigner le nom de l’autorité d’homologation avant de continuer" unless additional_content&.fetch("autorite_homologation_nom", false)&.present?
    errors[:autorite_homologation_fonction] << "Vous devez renseigner la fonction de l’autorité d’homologation avant de continuer" unless additional_content&.fetch("autorite_homologation_fonction", false)&.present?
    date_regex = /^\d{4}-\d{2}-\d{2}$/
    errors[:date_homologation] << "Vous devez renseigner la date de début de l’homologation au format yyyy-mm-jj avant de continuer" unless date_regex.match?(additional_content&.fetch("date_homologation", false))
    errors[:date_fin_homologation] << "Vous devez renseigner la date de fin de l’homologation au format yyyy-mm-jj avant de continuer" unless date_regex.match?(additional_content&.fetch("date_fin_homologation", false))
    errors[:documents_attributes] << "Vous devez joindre le document de décision d’homologation avant de continuer" unless documents.where(type: "Document::DecisionHomologation").present?

    # CGU
    errors[:cgu_approved] << "Vous devez valider les modalités d'utilisation avant de continuer" unless cgu_approved?

    unless user.email_verified
      errors[:base] << "L'accès à votre adresse email n'a pas pu être vérifié. Merci de vous rendre sur #{ENV.fetch("OAUTH_HOST")}/users/verify-email puis de cliquer sur 'Me renvoyer un code de confirmation'"
    end
  end
end
