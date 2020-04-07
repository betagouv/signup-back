class Enrollment::ApiImpotParticulierStep2 < Enrollment
  protected

  def update_validation
    errors[:previous_enrollment_id] << "Vous devez associer cette demande à une demande API Impôt particulier validée. Aucun changement n'a été sauvegardé." unless previous_enrollment_id.present?
    # the following 2 errors should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d’API cible. Aucun changement n'a été sauvegardé." unless target_api.present?
    errors[:organization_id] << "Une erreur inattendue est survenue: pas d’organisation. Aucun changement n'a été sauvegardé." unless organization_id.present?
  end

  def sent_validation
    # Form
    errors[:siret] << "Vous devez renseigner un SIRET d’organisation valide avant de continuer" unless nom_raison_sociale.present?

    # Homologation de securite
    errors[:autorite_homologation_nom] << "Vous devez renseigner le nom de l’autorité d’homologation avant de continuer" unless additional_content&.fetch("autorite_homologation_nom", false)&.present?
    errors[:autorite_homologation_fonction] << "Vous devez renseigner la fonction de l’autorité d’homologation avant de continuer" unless additional_content&.fetch("autorite_homologation_fonction", false)&.present?
    errors[:date_homologation] << "Vous devez renseigner la date de début de l’homologation avant de continuer" unless additional_content&.fetch("date_homologation", false)&.present?
    errors[:date_fin_homologation] << "Vous devez renseigner la date de fin de l’homologation avant de continuer" unless additional_content&.fetch("date_fin_homologation", false)&.present?
    errors[:documents_attributes] << "Vous devez joindre le document de décision d’homologation avant de continuer" unless documents.where(type: "Document::DecisionHomologation").present?

    # Entrant technique
    errors[:ips_de_production] << "Vous devez renseigner les IP(s) de production avant de continuer" unless additional_content&.fetch("ips_de_production", false)&.present?

    # Volumetrie
    errors[:nombre_demandes_annuelle] << "Vous devez renseigner le nombre de demandes annuelle avant de continuer" unless additional_content&.fetch("nombre_demandes_annuelle", false)&.present?
    errors[:pic_demandes_par_heure] << "Vous devez renseigner le nombre de demandes mensuel par heure avant de continuer" unless additional_content&.fetch("pic_demandes_par_heure", false)&.present?

    if (additional_content&.fetch("nombre_demandes_mensuelles", [])&.include? "") || (additional_content&.fetch("nombre_demandes_mensuelles", [])&.length != 12)
      errors[:nombre_demandes_mensuelles] << "Vous devez renseigner le nombre de demandes mensuel pour chaque mois avant de continuer"
    end

    # Recette fonctionnelle
    errors[:recette_fonctionnelle] << "Vous devez attester avoir réaliser une recette fonctionnelle avant de continuer" unless additional_content&.fetch("recette_fonctionnelle", false)&.present?

    unless user.email_verified
      errors[:base] << "L'accès à votre adresse email n'a pas pu être vérifié. Merci de vous rendre sur #{ENV.fetch("OAUTH_HOST")}/users/verify-email puis de cliquer sur 'Me renvoyer un code de confirmation'"
    end
  end
end
