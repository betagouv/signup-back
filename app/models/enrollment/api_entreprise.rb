class Enrollment::ApiEntreprise < Enrollment
  protected

  def sent_validation
    super

    scopes_validation
    contact_technique_validation
    contact_metier_validation
  end
end
