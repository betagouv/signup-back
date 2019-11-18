class RegisterApiParticulierEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.select { |contact| contact["id"] == "technique" }.first["email"]
    scopes = @enrollment[:scopes].reject { |k, v| !v }.keys
    linked_token_manager_id = create_enrollment_in_token_manager(@enrollment.id, name, email, scopes)
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(id, name, email, scopes)
    response = Http.post(
      "#{ENV.fetch("API_PARTICULIER_HOST")}/admin/api/token",
      "{\"name\": #{name.to_json},\"email\": #{email.to_json},\"signup_id\": \"#{id.to_json}\", \"scopes\": #{scopes.to_json}}",
      {"x-api-key" => ENV.fetch("API_PARTICULIER_API_KEY")}
    )

    if response.code != "200"
      raise "Error when registering token in API Particulier. Error message was: #{response.read_body} (#{response.code})"
    end

    JSON.parse(response.read_body)["_id"]
  end
end
