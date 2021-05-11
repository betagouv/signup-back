class ApiDroitsCnamBridge < BridgeService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    EnrollmentMailer.with(
      target_api: "api_droits_cnam",
      nom_raison_sociale: @enrollment.nom_raison_sociale,
      enrollment_id: @enrollment.id,
      previous_enrollment_id: @enrollment.previous_enrollment_id,
      scopes: @enrollment[:scopes].reject { |k, v| !v }.keys
    ).add_scopes_in_franceconnect_email.deliver_later
  end
end
