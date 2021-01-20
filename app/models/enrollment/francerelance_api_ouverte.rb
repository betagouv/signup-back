class Enrollment::FrancerelanceApiOuverte < Enrollment
  protected

  def sent_validation
    errors[:description] << "Vous devez renseigner la description de la démarche avant de continuer" unless description.present?
    errors[:siret] << "Vous devez renseigner un SIRET d'organisation valide avant de continuer" unless nom_raison_sociale

    subvention_info_validation
  end
end
