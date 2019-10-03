class Enrollment::ApiImpotParticulierStep2 < Enrollment
  protected

  def update_validation
    errors[:linked_franceconnect_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée" unless linked_franceconnect_enrollment_id.present?
    # the following 2 errors should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d'API cible" unless target_api.present?
    errors[:organization_id] << "Une erreur inattendue est survenue: pas d'organisation" unless organization_id.present?
  end

  def sent_validation
    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale.present?
    errors[:ips_de_production] << "Vous devez renseigner les IP(s) de production avant de continuer" unless additional_content&.fetch('ips_de_production', false)&.present?
    errors[:recette_fonctionnelle] << "Vous devez attester avoir réaliser une recette fonctionnelle avant de continuer" unless additional_content&.fetch('recette_fonctionnelle', false)&.present?
    unless user.email_verified
      errors[:base] << "Vous devez activer votre compte api.gouv.fr avant de continuer.
Merci de cliquer sur le lien d'activation que vous avez reçu par mail.
Vous pouvez également demander un nouveau lien d'activation en cliquant sur le lien
suivant #{ENV.fetch("OAUTH_HOST")}/users/send-email-verification?notification=email_verification_required"
    end
  end
end
