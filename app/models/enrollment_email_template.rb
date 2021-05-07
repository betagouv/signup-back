class EnrollmentEmailTemplate < ActiveModelSerializers::Model
  attributes :action_name,
             :plain_text_content
end
