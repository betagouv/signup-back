class ApiEntrepriseBridge < BridgeService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = @enrollment.intitule
    email = @enrollment.user.email
    uid = @enrollment.user.uid
    scopes = @enrollment[:scopes]
    contacts = @enrollment.contacts
    siret = @enrollment[:siret]
    cgu_agreement_date = @enrollment.submitted_at
    previous_linked_token_manager_id =
      @enrollment.copied_from_enrollment.present? ?
        @enrollment.copied_from_enrollment.linked_token_manager_id.presence :
        nil
    linked_token_manager_id = create_enrollment_in_token_manager(
      @enrollment.id,
      name,
      email,
      uid,
      scopes,
      contacts,
      siret,
      cgu_agreement_date,
      previous_linked_token_manager_id
    )
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(
    id,
    name,
    email,
    uid,
    scopes,
    contacts,
    siret,
    cgu_agreement_date,
    previous_linked_token_manager_id
  )
    api_host = ENV.fetch("API_ENTREPRISE_HOST")
    api_key = ENV.fetch("API_ENTREPRISE_API_KEY")

    # 1. get user id via user search
    list_users_response = Http.get(
      "#{api_host}/api/admin/users/?email=#{email}",
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
          oauth_api_gouv_id: uid.to_i,
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

    create_jwt_response = Http.post(
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

    raw_jwt = create_jwt_response.parse["new_token"]
    jwt = JWT.decode(raw_jwt, nil, false)
    jwt_id = jwt[0]["jti"]

    # 4. if this authorization request already has a linked_token_manager_id
    # we archive the previous token. This happens when the authorization request
    # was copied from another authorization request.
    unless previous_linked_token_manager_id.nil?
      Http.patch(
        "#{api_host}/api/admin/jwt_api_entreprise/#{previous_linked_token_manager_id}",
        {
          archived: true,
        },
        api_key,
        "dashboard API entreprise"
      )
    end

    jwt_id
  end
end
