class RegisterFranceconnectEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.select { |contact| contact["id"] == "technique" }.first["email"]
    scopes = @enrollment[:scopes].reject { |k, v| !v }.keys
    create_enrollment_in_token_manager(@enrollment.id, name, email, scopes)
  end

  private

  def create_enrollment_in_token_manager(id, name, email, scopes)
    response = Http.post(
      "#{ENV.fetch("FRANCECONNECT_PARTICULIER_HOST")}/api/v2/service-provider/integration/create",
      "{\"name\": #{name.to_json},\"authorized_emails\": [#{email.to_json}],\"signup_id\": \"#{id.to_json}\", \"scopes\": #{scopes.to_json}}",
      {"authorization" => "Bearer #{ENV.fetch("FRANCECONNECT_PARTICULIER_API_KEY") { "" }}"}
    )

    if response.code != "200"
      raise "Error when registering the FS on FranceConnect. Error message was: #{response.read_body} (#{response.code})"
    end

    # The id returned here is the signup id. It is not a generated id from "espace partenaires".
    JSON.parse(response.read_body)["_id"]
  end
end
