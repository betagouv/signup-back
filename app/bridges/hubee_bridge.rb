class HubeeBridge < ApplicationBridge
  def call
    email = @enrollment.user.email
    phone_number = @enrollment.user.phone_number
    contacts = @enrollment.contacts
    siret = @enrollment[:siret]
    created_at = @enrollment[:created_at]
    updated_at = @enrollment[:updated_at]
    validated_at = @enrollment.validated_at
    linked_token_manager_id = create_enrollment_in_token_manager(
      @enrollment.id,
      email,
      phone_number,
      contacts,
      siret,
      created_at,
      updated_at,
      validated_at
    )
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(
    id,
    email,
    phone_number,
    contacts,
    siret,
    created_at,
    updated_at,
    validated_at
  )
    response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/#{siret}")
    denomination = response.parse["etablissement"]["unite_legale"]["denomination"]
    sigle = response.parse["etablissement"]["unite_legale"]["sigle"]
    code_postal = response.parse["etablissement"]["code_postal"]
    code_commune = response.parse["etablissement"]["code_commune"]
    libelle_commune = response.parse["etablissement"]["libelle_commune"]

    api_host = ENV.fetch("HUBEE_HOST")
    client_id = ENV.fetch("HUBEE_CLIENT_ID")
    client_secret = ENV.fetch("HUBEE_CLIENT_SECRET")

    # 1. get token
    token_response = Http.post(
      "#{api_host}/token",
      {grant_type: "client_credentials", scope: "ADMIN"},
      Base64.strict_encode64("#{client_id}:#{client_secret}"),
      "HubEE",
      nil,
      "Basic"
    )

    token = token_response.parse
    access_token = token["access_token"]

    # 2.1 get organization
    begin
      Http.get(
        "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}",
        access_token,
        "HubEE"
      )
    rescue ApplicationController::BadGateway => e
      if e.http_code == 404
        # 2.2 if organization does not exist, create the organization
        Http.post(
          "#{api_host}/referential/v1/organizations",
          {
            type: "SI",
            companyRegister: siret,
            branchCode: code_commune,
            name: denomination,
            code: sigle,
            country: "France",
            postalCode: code_postal,
            territory: libelle_commune,
            email: email,
            phoneNumber: phone_number,
            status: "Actif"
          },
          access_token,
          "HubEE"
        )
      else
        raise
      end
    end

    # 3. create subscription
    create_subscription_response = Http.post(
      "#{api_host}/referential/v1/subscriptions",
      {
        datapassId: id,
        processCode: "CERTDC",
        subscriber: {
          type: "SI",
          companyRegister: siret,
          branchCode: code_commune
        },
        accessMode: "API",
        notificationFrequency: "unitaire",
        activateDateTime: created_at.iso8601,
        validateDateTime: validated_at.iso8601,
        rejectDateTime: nil,
        endDateTime: nil,
        updateDateTime: updated_at.iso8601,
        delegationActor: {
          email: contacts.find { |contact| contact["id"] == "technique" }["email"],
          firstName: contacts.find { |contact| contact["id"] == "technique" }["given_name"],
          lastName: contacts.find { |contact| contact["id"] == "technique" }["family_name"],
          function: contacts.find { |contact| contact["id"] == "technique" }["job"],
          phoneNumber: contacts.find { |contact| contact["id"] == "technique" }["phone_number"],
          mobileNumber: nil
        },
        rejectionReason: nil,
        status: "Actif",
        email: email,
        localAdministrator: {
          email: contacts.find { |contact| contact["id"] == "metier" }["email"],
          firstName: contacts.find { |contact| contact["id"] == "metier" }["given_name"],
          lastName: contacts.find { |contact| contact["id"] == "metier" }["family_name"],
          function: contacts.find { |contact| contact["id"] == "metier" }["job"],
          phoneNumber: contacts.find { |contact| contact["id"] == "metier" }["phone_number"],
          mobileNumber: nil
        }
      },
      access_token,
      "HubEE"
    )

    create_subscription_response.parse["id"]
  end
end
