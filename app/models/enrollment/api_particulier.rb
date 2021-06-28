class Enrollment::ApiParticulier < Enrollment
  protected

  def sent_validation
    super

    scopes_validation
    contact_technique_validation
  end
end
