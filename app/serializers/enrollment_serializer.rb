class EnrollmentSerializer < ActiveModel::Serializer
  attributes :updated_at, :created_at, :id, :target_api, :previous_enrollment_id, :copied_from_enrollment_id,
    :cgu_approved, :scopes, :contacts, :organization_id, :siret, :nom_raison_sociale, :status, :linked_token_manager_id,
    :additional_content, :intitule, :description, :fondement_juridique_title, :fondement_juridique_url,
    :data_recipients, :data_retention_period, :data_retention_comment, :dpo_family_name, :dpo_given_name, :dpo_email,
    :dpo_phone_number, :dpo_job, :responsable_traitement_family_name, :responsable_traitement_given_name,
    :responsable_traitement_email, :responsable_traitement_phone_number, :responsable_traitement_job, :demarche,
    :type_projet, :date_mise_en_production, :volumetrie_approximative, :dpo_is_informed

  belongs_to :user, serializer: UserWithProfileSerializer

  has_many :documents
  has_many :events

  attribute :acl do
    EnrollmentPolicy.acl_methods.map { |method|
      [method.to_s.delete("?"), EnrollmentPolicy.new(current_user, object).send(method)]
    }.to_h
  end
end
