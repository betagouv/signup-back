class EnrollmentSerializer < ActiveModel::Serializer
  attributes :updated_at, :created_at, :id, :fournisseur_de_donnees, :linked_franceconnect_enrollment_id,
             :validation_de_convention, :scopes, :contacts, :siret, :demarche, :state, :token_id

  belongs_to :user

  has_many :documents
  has_many :events

  attribute :donnees do
    object.donnees&.merge('destinataires' => object.donnees&.fetch('destinataires', {}))
  end

  attribute :acl do
    puts "#{current_user.inspect} current_user"
    policy_class = Object.const_get("#{object.class.to_s}Policy")
    Hash[
      policy_class.acl_methods.map do |method|
        [method.to_s.delete('?'), policy_class.new(current_user, object).send(method)]
      end
    ]
  end
end
