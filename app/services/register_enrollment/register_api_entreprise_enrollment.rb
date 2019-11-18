class RegisterApiEntrepriseEnrollment < RegisterEnrollmentService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.user.email
    contacts = @enrollment.contacts
    scopes = @enrollment[:scopes].reject { |k, v| !v }.keys
    linked_token_manager_id = create_enrollment_in_token_manager(name, email, scopes, contacts)
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(name, email, scopes, contacts)
    api_key = ENV.fetch("API_ENTREPRISE_API_KEY")

    # 1. create user
    formatted_contacts = contacts
      .select { |contact| contact["id"].in?(%w[technique metier]) }
      .map { |contact|
      {
        "email" => contact["email"],
        "phone_number" => contact["phone_number"],
        "contact_type" => contact["id"] == "technique" ? "tech" : "admin",
      }
    }

    create_user_response = Http.post(
      "#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/",
      "{\"email\": #{email.to_json},\"contacts\": #{formatted_contacts.to_json}}",
      {"Authorization" => "Bearer #{api_key}"}
    )

    # 1. b) catch user already exists error
    # TODO entreprise: to avoid this, do not return an error if the user exists
    if (create_user_response.code != "201") && !((create_user_response.code == "422") && (JSON.parse(create_user_response.body)["errors"]["email"].first == "value already exists"))
      # in the case the user exists already, we do not care about updating the contacts
      raise "Error when registering token in API Particulier. Error message was: #{create_user_response.body} (#{create_user_response.code})"
    end

    # 2. get user id within the list of users
    # TODO entreprise: to avoid this, return the id on create and add a get user by mail endpoint
    list_users_response = Http.get("#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/", {"Authorization" => "Bearer #{api_key}"})
    users = JSON.parse(list_users_response.body)
    user_id = users.detect { |user| user["email"] == email }["id"]

    # 3. create token
    # TODO entreprise: it may be better to have the token id instead of the token itself
    create_token_response = Http.post(
      "#{ENV.fetch("API_ENTREPRISE_HOST")}/api/admin/users/#{user_id}/jwt_api_entreprise/admin_create",
      "{\"subject\": #{name.to_json},\"roles\": #{scopes.to_json}}",
      {"Authorization" => "Bearer #{api_key}"}
    )

    if create_token_response.code != "201"
      raise "Error when registering token in API Particulier. Error message was: #{create_token_response.body} (#{create_token_response.code})"
    end

    user_id
  end
end
