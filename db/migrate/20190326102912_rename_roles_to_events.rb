class RenameRolesToEvents < ActiveRecord::Migration[5.1]
  def change
    add_reference :roles, :user, foreign_key: true
    add_reference :roles, :enrollment, foreign_key: true
    remove_column :roles, :resource_type
    add_column :roles, :comment, :string
    rename_table :roles, :events
  end
end

# manual requests were made after this migration:
# DELETE FROM events
# WHERE name = 'technical_inputs_sender' OR name = 'application_deployer';
# 
# UPDATE events
# SET name = CASE name
#   WHEN 'application_sender' THEN 'submitted'
#   WHEN 'applicant' THEN 'created'
#   WHEN 'application_validater' THEN 'validated'
#   WHEN 'application_reviewer' THEN 'asked_for_modification'
#   WHEN 'application_refuser' THEN 'refused'
#   ELSE name
# END;
#
# UPDATE events
# SET enrollment_id = resource_id
# WHERE exists (SELECT 1 FROM enrollments e WHERE e.id = events.resource_id);
#
# UPDATE
#     events AS e
# SET
#     user_id = users_roles.user_id
# FROM
#     events AS e_alias
# INNER JOIN
#     users_roles ON users_roles.role_id = e_alias.id
# WHERE
#     e.id = e_alias.id;
