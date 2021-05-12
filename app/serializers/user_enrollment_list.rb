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
    EnrollmentPolicy.acl_methods.map { |method|
      [method.to_s.delete("?"), EnrollmentPolicy.new(current_user, object).send(method)]
    }.to_h
  end
end
