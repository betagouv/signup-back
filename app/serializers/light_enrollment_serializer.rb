class LightEnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :updated_at, :nom_raison_sociale, :target_api, :status

  belongs_to :user

  attribute :acl do
    EnrollmentPolicy.acl_methods.map do |method|
      [method.to_s.delete("?"), EnrollmentPolicy.new(current_user, object).send(method)]
    end.to_h
  end

  attribute :is_renewal do
    object.copied_from_enrollment_id.present?
  end
end
