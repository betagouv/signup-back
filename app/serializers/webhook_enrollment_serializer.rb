class WebhookEnrollmentSerializer < ActiveModel::Serializer
  attributes :id,
    :intitule,
    :description,
    :status,
    :siret,
    :scopes,
    :team_members,
    :previous_enrollment_id,
    :copied_from_enrollment_id

  def team_members
    [
      build_team_member(:user, "demandeur"),
      build_team_member(:dpo, "delegue_protection_donnees"),
      build_team_member(:responsable_traitement, "responsable_traitement"),
      build_team_member_from_contact(:technique, "responsable_technique"),
      build_team_member_from_contact(:metier, "contact_metier")
    ].compact
  end

  has_many :events, serializer: WebhookEventSerializer

  private

  def build_team_member(model_key, type)
    model = object.public_send(model_key)

    return if model.blank?

    {
      id: model.id,
      uid: model.try(:uid),
      type: type,
      email: model.email,
      family_name: model.family_name,
      given_name: model.given_name,
      phone_number: model.phone_number,
      job: model.job
    }
  end

  def build_team_member_from_contact(original_contact_id, type)
    contact_payload = object.contacts.find do |contact|
      contact["id"] == original_contact_id.to_s
    end

    return if contact_payload.nil?

    {
      id: contact_payload["email"].to_i(36),
      uid: nil,
      type: type,
      email: contact_payload["email"],
      family_name: contact_payload["family_name"],
      given_name: contact_payload["given_name"],
      phone_number: contact_payload["phone_number"],
      job: contact_payload["job"]
    }
  end
end
