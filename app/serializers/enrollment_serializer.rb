class EnrollmentSerializer < ActiveModel::Serializer
  attributes :updated_at, :created_at, :id, :fournisseur_de_donnees, :linked_franceconnect_enrollment_id,
             :validation_de_convention, :scopes, :contacts, :siret, :state, :token_id, :additional_content,
             :intitule, :description, :fondement_juridique_title, :fondement_juridique_url, :data_recipients,
             :data_retention_period


  belongs_to :user

  has_many :documents
  has_many :events

  attribute :acl do
    policy_class = Object.const_get("#{object.class.to_s}Policy")
    Hash[
      policy_class.acl_methods.map do |method|
        [method.to_s.delete('?'), policy_class.new(current_user, object).send(method)]
      end
    ]
  end
end
