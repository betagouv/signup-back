class ApiParticulierBridge < ApplicationBridge
  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    contact_technique_email = @enrollment.contacts.find { |contact| contact["id"] == "technique" }["email"]
    owner_email = @enrollment.user[:email]
    scopes = @enrollment[:scopes].reject { |_, v| !v }.keys
    linked_token_manager_id = create_enrollment_in_token_manager(
      @enrollment.id,
      name,
      contact_technique_email,
      owner_email,
      scopes
    )
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(id, name, contact_technique_email, owner_email, scopes)
    response = Http.post(
      "#{ENV.fetch("PORTAIL_API_GOUV_FR_HOST")}/api-particulier/subscribe",
      {
        name: name,
        technical_contact_email: contact_technique_email,
        author_email: owner_email,
        data_pass_id: id,
        scopes: scopes
      },
      ENV.fetch("PORTAIL_API_GOUV_FR_API_KEY"),
      "Portail api.gouv.fr",
      "X-Api-Key"
    )

    response.parse["id"]
  end
end
