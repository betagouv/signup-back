class Enrollment::ApiImpotParticulier < Enrollment
  protected

  def update_validation
    errors[:linked_franceconnect_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée" unless linked_franceconnect_enrollment_id.present?
    super
  end

  def sent_validation
    super
    errors[:data_retention_period] << "Vous devez renseigner la conservation des données avant de continuer" unless data_retention_period.present?
    errors[:data_recipients] << "Vous devez renseigner les destinataires des données avant de continuer" unless data_recipients.present?
    errors[:rgpd_general_agreement] << "Vous devez attester respecter les principes RGPD avant de continuer" unless additional_content&.fetch("rgpd_general_agreement", false)
  end
end
