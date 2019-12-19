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
    # note that the FC team test this call with this bash script: https://gitlab.com/france-connect/FranceConnect/snippets/1828712
    response = Http.post(
      "#{ENV.fetch("FRANCECONNECT_PARTICULIER_HOST")}/api/v2/service-provider/integration/create",
      "{\"name\": #{name.to_json},\"authorized_emails\": [#{email.to_json}],\"signup_id\": \"#{id.to_json}\", \"scopes\": #{scopes.to_json}}",
      {"authorization" => "Bearer #{ENV.fetch("FRANCECONNECT_PARTICULIER_API_KEY") { "" }}"}
    )

    if response.code != "200"
      raise ApplicationController::BadGateway.new(
        "Espace Partenaire FranceConnect",
        "#{ENV.fetch("FRANCECONNECT_PARTICULIER_HOST")}/api/v2/service-provider/integration/create",
        response.code,
        response.body,
      )
    end

    # The id returned here is the signup id. It is not a generated id from "espace partenaires".
    JSON.parse(response.read_body)["_id"]

  # error list from https://stackoverflow.com/questions/5370697/what-s-the-best-way-to-handle-exceptions-from-nethttp#answer-11802674
  rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, SocketError => e
    raise ApplicationController::BadGateway.new(
      "Espace Partenaire FranceConnect",
      "#{ENV.fetch("FRANCECONNECT_PARTICULIER_HOST")}/api/v2/service-provider/integration/create",
      nil,
      nil,
    ), e.message
  end
end
