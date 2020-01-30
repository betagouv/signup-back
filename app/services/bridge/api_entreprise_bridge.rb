class ApiEntrepriseBridge < BridgeService
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
    create_enrollment_in_token_manager(@enrollment.id, name, email, scopes, contacts, siret, cgu_agreement_date)
  end

  private

  def create_enrollment_in_token_manager(id, name, email, scopes, contacts, siret, cgu_agreement_date)
    api_host = ENV.fetch("API_ENTREPRISE_HOST")
    api_key = ENV.fetch("API_ENTREPRISE_API_KEY")

    # 1. get user id within the list of users
    # TODO API Entreprise: to avoid this, add a get user by mail endpoint
    list_users_response = Http.get(
      "#{api_host}/api/admin/users/",
      api_key,
      "dashboard API entreprise"
    )

    users = list_users_response.parse
    user = users.detect { |user| user["email"] == email }

    if user.nil?
      # 2. if user does not exist, create the user
      # note that the siret recorded is the siret of the first demand for this users
      # further siret will not be recorded
      create_user_response = Http.post(
        "#{api_host}/api/admin/users/",
        {
          email: email,
          context: siret,
          cgu_agreement_date: cgu_agreement_date,
        },
        api_key,
        "dashboard API entreprise"
      )

      user = create_user_response.parse
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
      .reject { |_, v| !v }
      .keys
      .map { |scope|
        {
          "code" => scope,
        }
      }

    Http.post(
      "#{api_host}/api/admin/users/#{user_id}/jwt_api_entreprise",
      {
        subject: name,
        roles: formatted_scopes,
        contacts: formatted_contacts,
        authorization_request_id: id.to_s,
      },
      api_key,
      "dashboard API entreprise"
    )

    # TODO API Entreprise: return token id, so we can forge an url that point to the token directly
    user_id
  end
end
