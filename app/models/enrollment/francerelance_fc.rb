class Enrollment::FrancerelanceFc < Enrollment
  protected

  def sent_validation
    super

    date_regex = /^\d{4}-\d{2}-\d{2}$/
    errors[:date_integration] << "Vous devez renseigner la date prévisionnelle de fin d’intégration au format AAAA-MM-JJ avant de continuer" unless date_regex.match?(additional_content&.fetch("date_integration", ""))

    scopes_validation
    contact_validation("metier", "porteur de projet")
    contact_validation("technique", "responsable technique")
  end
end
