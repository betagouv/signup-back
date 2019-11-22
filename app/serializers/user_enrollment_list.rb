class UserEnrollmentListSerializer < ActiveModel::Serializer
  attributes :id,
             :updated_at,
             :description,
             :nom_raison_sociale,
             :target_api,
             :status,
             :siret,
             :intitule

  belongs_to :user

  has_many :events

  attribute :acl do
    Hash[
      EnrollmentPolicy.acl_methods.map do |method|
        [method.to_s.delete('?'), EnrollmentPolicy.new(current_user, object).send(method)]
      end
    ]
  end
end
