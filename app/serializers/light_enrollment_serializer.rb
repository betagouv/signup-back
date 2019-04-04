class LightEnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :updated_at, :intitule, :fournisseur_de_donnees, :state

  belongs_to :user

  attribute :acl do
    policy_class = Object.const_get("#{object.class.to_s}Policy")
    Hash[
      policy_class.acl_methods.map do |method|
        [method.to_s.delete('?'), policy_class.new(current_user, object).send(method)]
      end
    ]
  end
end
