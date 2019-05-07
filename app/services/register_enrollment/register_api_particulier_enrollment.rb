class RegisterApiParticulierEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.select { |contact| contact['id'] == 'technique' }.first['email']
    linked_token_manager_id = create_enrollment_in_token_manager(@enrollment.id, name, email)
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})

    scopes = @enrollment[:scopes].reject {|k, v| !v}.keys
    register_enrollment_in_api_scopes(@enrollment.id.to_s, linked_token_manager_id, 'api_particulier', scopes)
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

    request.body = "{\"name\": #{name.to_json},\"email\": #{email.to_json},\"signup_id\": #{id.to_json}}"

    response = http.request(request)

    if response.code != '200'
      raise "Error when registering token in API Particulier. Error message was: #{response.read_body} (#{response.code})"
    end

    JSON.parse(response.read_body)["_id"]
  end
end
