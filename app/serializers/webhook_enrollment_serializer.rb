class WebhookEnrollmentSerializer < ActiveModel::Serializer
  attributes :id,
    :target_api,
    :intitule,
    :description,
    :fondement_juridique_title,
    :fondement_juridique_url,
    :cgu_approved,
    :additional_content,
    :type_projet,
    :data_recipients,
    :data_retention_period,
    :data_retention_comment,
    :date_mise_en_production,
    :status,
    :data_retention_period,
    :data_retention_comment,
    :siret,
    :nom_raison_sociale,
    :organization_id,
    :contacts,
    :scopes,
    :updated_at,
    :created_at,
    :previous_enrollment_id,
    :copied_from_enrollment_id,
    :linked_token_manager_id,
    :volumetrie_approximative,
    :dpo_is_informed

  belongs_to :user, serializer: UserWithProfileSerializer
  belongs_to :dpo, serializer: UserWithProfileSerializer
  belongs_to :responsable_traitement, serializer: UserWithProfileSerializer

  has_many :events, serializer: WebhookEventSerializer
  has_many :documents
end
