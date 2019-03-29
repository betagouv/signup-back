class EventSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :name, :comment, :user
end
