class Enrollment::FrancerelanceApiRestreinte < Enrollment
  before_save :set_info_from_previous_enrollment, if: :will_save_change_to_previous_enrollment_id?

  protected

  def set_info_from_previous_enrollment
    self.intitule = previous_enrollment.intitule
    self.organization_id = previous_enrollment.organization_id
    set_company_info
  end

  def update_validation
    errors[:previous_enrollment_id] << "Vous devez associer cette demande à une demande d'API validée. Aucun changement n’a été sauvegardé." unless previous_enrollment_id.present?
    # the following error should never occur #defensiveprogramming
    errors[:target_api] << "Une erreur inattendue est survenue: pas d’API cible. Aucun changement n’a été sauvegardé." unless target_api.present?
  end

  def sent_validation
    subvention_info_validation
  end
end
