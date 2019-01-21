class RegisterFranceconnectEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.select { |contact| contact['id'] == 'technique' }.first['email']
    create_enrollment_in_token_manager(@enrollment.id, name, email)

    scopes = @enrollment[:scopes].reject {|k, v| !v}.keys
    register_enrollment_in_api_scopes(@enrollment.id.to_s, nil, 'franceconnect', scopes)
  end

  private

  def create_enrollment_in_token_manager(id, name, email)
    url = URI("#{ENV.fetch('FRANCECONNECT_PARTICULIER_HOST')}/api/v2/service-provider/integration/create")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["authorization"] = "Basic #{ENV.fetch('FRANCECONNECT_PARTICULIER_API_KEY') {''}}"

    request.body = "{\"name\": \"#{name}\",\"authorized_emails\": [\"#{email}\"],\"signup_id\": \"#{id}\"}"

    response = http.request(request)

    if response.code != '200'
      raise "Error when registering the FS on FranceConnect. Error message was: #{response.read_body} (#{response.code})"
    end

    # The id returned here is the signup id. It is not a generated id from "espace partenaires".
    JSON.parse(response.read_body)["_id"]
  end
end
