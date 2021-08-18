class ApiEntrepriseBridge < ApplicationBridge
  def call
    name = @enrollment.intitule
    email = @enrollment.demandeurs.pluck(:email).first
    uid = @enrollment.demandeurs.pluck(:uid).first
    scopes = @enrollment[:scopes]
    team_members = @enrollment.team_members.where(type: %w[metier technique])
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
      team_members,
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
    team_members,
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
          oauth_api_gouv_id: uid,
          context: siret,
          cgu_agreement_date: cgu_agreement_date
        },
        api_key,
        "dashboard API entreprise"
      )

      user = create_user_response.parse
    end

    if user["oauth_api_gouv_id"].nil?
      # 3. if the user does exist but do not has an oauth_api_gouv_id
      # we update the user so the reconciliation process (based on this id)
      # could go through when logging in « dashboard entreprise ».
      # Note that this can happen when the user already has a token in
      # « dashboard entreprise » but obtained it before the existence
      # of DataPass.
      update_user_response = Http.patch(
        "#{api_host}/api/admin/users/#{user["id"]}",
        {
          oauth_api_gouv_id: uid
        },
        api_key,
        "dashboard API entreprise"
      )

      user = update_user_response.parse
    end

    user_id = user["id"]

    # 4. create token
    formatted_team_members = team_members
      .map { |team_member|
        {
          "email" => team_member["email"],
          "phone_number" => team_member["phone_number"],
          "contact_type" => team_member["type"] == "technique" ? "tech" : "admin"
        }
      }
    formatted_scopes = scopes
      .reject { |_, v| !v }
      .keys
      .map { |scope|
        {
          "code" => scope
        }
      }

    create_jwt_response = Http.post(
      "#{api_host}/api/admin/users/#{user_id}/jwt_api_entreprise",
      {
        subject: name,
        roles: formatted_scopes,
        contacts: formatted_team_members,
        authorization_request_id: id.to_s
      },
      api_key,
      "dashboard API entreprise"
    )

    raw_jwt = create_jwt_response.parse["new_token"]
    jwt = JWT.decode(raw_jwt, nil, false)
    jwt_id = jwt[0]["jti"]

    # 5. if this authorization request already has a linked_token_manager_id
    # we archive the previous token. This happens when the authorization request
    # was copied from another authorization request.
    unless previous_linked_token_manager_id.nil?
      Http.patch(
        "#{api_host}/api/admin/jwt_api_entreprise/#{previous_linked_token_manager_id}",
        {
          archived: true
        },
        api_key,
        "dashboard API entreprise"
      )
    end

    jwt_id
  end
end
