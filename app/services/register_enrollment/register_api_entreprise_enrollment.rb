class RegisterApiEntrepriseEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = @enrollment.intitule
    email = @enrollment.user.email
    scopes = @enrollment[:scopes]
    contacts = @enrollment.contacts
    siret = @enrollment[:siret]
    cgu_agreement_date = @enrollment.submitted_at
    create_enrollment_in_token_manager(name, email, scopes, contacts, siret, cgu_agreement_date)
  end

  private

  def create_enrollment_in_token_manager(name, email, scopes, contacts, siret, cgu_agreement_date)
    api_key = ENV.fetch("API_ENTREPRISE_API_KEY")

    # 1. get user id within the list of users
    # TODO API Entreprise: to avoid this, add a get user by mail endpoint
    list_users_response = Http.get("#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/", {"Authorization" => "Bearer #{api_key}"})
    users = JSON.parse(list_users_response.body)
    user = users.detect { |user| user["email"] == email }

    if user.nil?
      # 2. if user does not exist, create the user
      # note that the siret recorded is the siret of the first demand for this users
      # further siret will not be recorded
      create_user_response = Http.post(
        "#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/",
        "{\"email\": #{email.to_json}, \"context\": #{siret.to_json},\"cgu_agreement_date\": #{cgu_agreement_date.to_json}}",
        {"Authorization" => "Bearer #{api_key}"}
      )

      if create_user_response.code != "201"
        raise "Error when registering user in API entreprise dashboard. Error message was: #{create_user_response.body} (#{create_user_response.code})"
      end

      user = JSON.parse(create_user_response.body)
    end

    user_id = user["id"]

    # 3. create token
    formatted_contacts = contacts
      .select { |contact| contact["id"].in?(%w[technique metier]) }
      .map { |contact|
        {
          "email" => contact["email"],
          "phone_number" => contact["phone_number"],
          "contact_type" => contact["id"] == "technique" ? "tech" : "admin",
        }
      }
    formatted_scopes = scopes
      .reject { |k, v| !v }
      .keys
      .map { |scope|
        {
          "code" => scope,
        }
      }
    create_token_response = Http.post(
      "#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/#{user_id}/jwt_api_entreprise",
      "{\"subject\": #{name.to_json},\"roles\": #{formatted_scopes.to_json}, \"contacts\": #{formatted_contacts.to_json}}",
      {"Authorization" => "Bearer #{api_key}"}
    )

    if create_token_response.code != "201"
      raise "Error when registering token in API Particulier. Error message was: #{create_token_response.body} (#{create_token_response.code})"
    end

    # TODO API Entreprise: return token id, so we can forge an url that point to the token directly
    user_id
  end
end
