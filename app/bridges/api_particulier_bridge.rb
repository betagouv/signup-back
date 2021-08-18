class ApiParticulierBridge < ApplicationBridge
  def call
    name = "#{@enrollment.nom_raison_sociale} - #{@enrollment.id}"
    contact_technique_email = @enrollment.team_members.where(type: "technique").pluck(:email).first
    demandeur_email = @enrollment.demandeurs.pluck(:email).first
    scopes = @enrollment[:scopes].reject { |_, v| !v }.keys
    linked_token_manager_id = create_enrollment_in_token_manager(
      @enrollment.id,
      name,
      contact_technique_email,
      demandeur_email,
      scopes
    )
    @enrollment.update({linked_token_manager_id: linked_token_manager_id})
  end

  private

  def create_enrollment_in_token_manager(id, name, contact_technique_email, demandeur_email, scopes)
    response = Http.post(
      "#{ENV.fetch("API_PARTICULIER_HOST")}/api/applications",
      {
        name: name,
        technical_contact_email: contact_technique_email,
        author_email: demandeur_email,
        data_pass_id: id,
        scopes: scopes
      },
      ENV.fetch("API_PARTICULIER_API_KEY"),
      "API Particulier",
      "X-Api-Key"
    )

    response.parse["id"]
  end
end
