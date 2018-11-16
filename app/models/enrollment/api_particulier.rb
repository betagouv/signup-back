class Enrollment::ApiParticulier < Enrollment
  resourcify

  protected

  def sent_validation
    super
    errors[:donnees] << "Vous devez renseigner la conservation des données avant de continuer" unless donnees && donnees['conservation'].present?
    errors[:donnees] << "Vous devez renseigner les destinataires des données avant de continuer" unless donnees && donnees['destinataires'].present?
  end
end
