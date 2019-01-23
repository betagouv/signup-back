class RegisterDgfipEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    scopes = @enrollment[:scopes].reject {|k, v| !v}.keys
    signup_id = @enrollment.linked_franceconnect_enrollment_id.to_s
    update_enrollment_in_api_scopes(signup_id, scopes)
  end

  private

  def update_enrollment_in_api_scopes(signup_id, scopes)
    database_url = "#{ENV.fetch('API_SCOPES_DOMAIN_NAME') {'scopes-development.api.gouv.fr'}}:#{ENV.fetch('API_SCOPES_DATABASE_PORT') {'27017'}}"
    database = ENV.fetch('API_SCOPES_DATABASE_NAME') {'scopes'}
    user = ENV.fetch('API_SCOPES_READWRITE_USER') {'signup'}
    password = ENV.fetch('API_SCOPES_READWRITE_PASSWORD') {'signup'}
    client = Mongo::Client.new([database_url], database: database, user: user, password: password)

    collection = client[:scopes]

    result = collection.update_one({:signup_id => signup_id}, '$push' => {'scopes' => {'$each' => scopes}})
    if result.n != 1
      raise "Error when registering enrollment in api-scope."
    end
    client.close
    true
  end
end
