class Enrollment::Franceconnect < Enrollment
  protected

  def sent_validation
    super
    errors[:data_retention_period] << "Vous devez renseigner la conservation des données avant de continuer" unless data_retention_period.present?
    errors[:data_recipients] << "Vous devez renseigner les destinataires des données avant de continuer" unless data_recipients.present?
  end
end
