class RegisterApiParticulierEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.select { |contact| contact['id'] == 'technique' }.first['email']
    token_id = create_enrollment_in_token_manager(@enrollment.id, name, email)
    @enrollment.update({token_id: token_id})

    scopes = @enrollment[:scopes].reject {|k, v| !v}.keys
    register_enrollment_in_api_scopes(@enrollment.id.to_s, token_id, 'api-particulier', scopes)
  end

  private

  def create_enrollment_in_token_manager(id, name, email)
    url = URI("#{ENV.fetch('API_PARTICULIER_HOST') {'https://particulier-development.api.gouv.fr'}}/admin/api/token")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["x-api-key"] = ENV.fetch('API_PARTICULIER_API_KEY')

    request.body = "{\"name\": \"#{name}\",\"email\": \"#{email}\",\"signup_id\": \"#{id}\"}"

    response = http.request(request)

    if response.code != '200'
      raise "Error when registering token in api-particulier. Error message was: #{response.read_body} (#{response.code})"
    end

    JSON.parse(response.read_body)["_id"]
  end
end
