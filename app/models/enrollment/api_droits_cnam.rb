class Enrollment::ApiDroitsCnam < Enrollment
  protected

  def sent_validation
    super
    errors[:linked_franceconnect_enrollment_id] << "Vous devez associer cette demande à une demande Franceconnect validée" unless linked_franceconnect_enrollment_id.present?
  end
end
