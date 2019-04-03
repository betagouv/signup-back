class Enrollment::Dgfip < Enrollment
  protected

  def sent_validation
    super
    errors[:linked_franceconnect_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée" unless linked_franceconnect_enrollment_id.present?
    errors[:donnees] << "Vous devez renseigner la conservation des données avant de continuer" unless donnees && donnees['conservation'].present?
    errors[:donnees] << "Vous devez renseigner les destinataires des données avant de continuer" unless donnees && donnees['destinataires'].present?
    errors[:ips_de_production] << "Vous devez renseigner les IP(s) de production avant de continuer" unless ips_de_production.present?
    errors[:recette_fonctionnelle] << "Vous devez attester avoir réaliser une recette fonctionnelle avant de continuer" unless recette_fonctionnelle?
  end
end
