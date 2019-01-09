class RegisterEnrollmentService < ApplicationService
  def register_enrollment_in_api_scopes(signup_id, client_id, provider, scopes)
    database_url = "#{ENV.fetch('API_SCOPES_DOMAIN_NAME') {'scopes-development.api.gouv.fr'}}:#{ENV.fetch('API_SCOPES_DATABASE_PORT') {'27017'}}"
    database = ENV.fetch('API_SCOPES_DATABASE_NAME') {'scopes'}
    user = ENV.fetch('API_SCOPES_READWRITE_USER') {'signup'}
    password = ENV.fetch('API_SCOPES_READWRITE_PASSWORD') {'signup'}
    client = Mongo::Client.new([database_url], database: database, user: user, password: password)

    collection = client[:scopes]

    doc = {
        scopes: scopes,
        client_id: client_id,
        provider: provider,
        signup_id: signup_id
    }

    result = collection.insert_one(doc)
    if result.n != 1
      raise "Error when registering enrollment in api-scope."
    end
    client.close
    true
  end
end
