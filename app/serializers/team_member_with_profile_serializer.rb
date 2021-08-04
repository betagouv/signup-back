class TeamMemberWithProfileSerializer < ActiveModel::Serializer
  attributes :id, :type, :email, :given_name, :family_name, :phone_number, :job
end
