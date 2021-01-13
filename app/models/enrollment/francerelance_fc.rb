class Enrollment::FrancerelanceFc < Enrollment
  protected

  def sent_validation
    super

    errors[:scopes] << "Vous devez cocher au moins un périmètre de données avant de continuer" unless scopes.any? { |_, v| v }

    contact_validation("metier", "porteur de projet")
    contact_validation("comptable", "contact comptable")
    contact_validation("technique", "responsable technique")
  end
end
