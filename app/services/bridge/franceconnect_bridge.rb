class FranceconnectBridge < BridgeService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    email = @enrollment.contacts.find { |contact| contact["id"] == "technique" }["email"]
    scopes = @enrollment[:scopes].reject { |k, v| !v }.keys
    create_enrollment_in_token_manager(@enrollment.id, name, email, scopes)
  end

  private

  def create_enrollment_in_token_manager(id, name, email, scopes)
    # note that the FC team test this call with this bash script: https://gitlab.com/france-connect/FranceConnect/snippets/1828712
    response = Http.post(
      "#{ENV.fetch("FRANCECONNECT_PARTICULIER_HOST")}/api/v2/service-provider/integration/create",
      {
        name: name,
        authorized_emails: [email],
        signup_id: id,
        scopes: scopes,
      },
      ENV.fetch("FRANCECONNECT_PARTICULIER_API_KEY"),
      "Espace Partenaire FranceConnect",
    )

    # The id returned here is the Data Pass id. It is not a generated id from "espace partenaires".
    response.parse["_id"]
  end
end
