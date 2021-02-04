class Enrollment::FrancerelanceFc < Enrollment
  protected

  def sent_validation
    super

    errors[:scopes] << "Vous devez cocher au moins un périmètre de données avant de continuer" unless scopes.any? { |_, v| v }
    errors[:date_integration] << "Vous devez renseigner une date prévisionnelle de fin d’intégration valide avant de continuer" unless additional_content&.fetch("date_integration", false)&.present?

    contact_validation("metier", "porteur de projet")
    contact_validation("technique", "responsable technique")
  end
end
