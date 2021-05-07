class EnrollmentEmailTemplateSerializer < ActiveModel::Serializer
  attributes :action_name,
    :plain_text_content
end
