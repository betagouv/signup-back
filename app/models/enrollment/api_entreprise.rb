class Enrollment::ApiEntreprise < Enrollment
  protected

  def sent_validation
    super

    email_regex = URI::MailTo::EMAIL_REGEXP
    # loose homemade regexp to match large amount of phone number
    phone_number_regex = /^\+?(?:[0-9][ -]?){6,14}[0-9]$/

    contact_technique = contacts&.find { |e| e["id"] == "technique" }
    errors[:contacts] << "Vous devez renseigner un email valide pour le contact technique avant de continuer" unless email_regex.match?(contact_technique&.fetch("email", false))
    errors[:contacts] << "Vous devez renseigner un numéro de téléphone valide pour le contact technique avant de continuer" unless phone_number_regex.match?(contact_technique&.fetch("phone_number", false))

    contact_metier = contacts&.find { |e| e["id"] == "metier" }
    errors[:contacts] << "Vous devez renseigner un email valide le contact métier avant de continuer" unless email_regex.match?(contact_metier&.fetch("email", false))
    errors[:contacts] << "Vous devez renseigner un numéro de téléphone valide pour le contact métier avant de continuer" unless phone_number_regex.match?(contact_metier&.fetch("phone_number", false))

    errors[:scopes] << "Vous devez cocher au moins un périmètre de donnée avant de continuer" unless scopes.any? { |_, v| v }

    errors[:data_retention_period] << "Vous devez renseigner la conservation des données avant de continuer" unless data_retention_period.present?
    errors[:data_recipients] << "Vous devez renseigner les destinataires des données avant de continuer" unless data_recipients.present?
  end
end
