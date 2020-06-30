class Enrollment::ApiEntreprise < Enrollment
  protected

  def sent_validation
    super

    errors[:scopes] << "Vous devez cocher au moins un périmètre de données avant de continuer" unless scopes.any? { |_, v| v }

    contact_technique_validation
    contact_metier_validation
  end
end
