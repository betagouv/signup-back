class AddOrganizationIdToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_column :enrollments, :organization_id, :integer
  end
end
