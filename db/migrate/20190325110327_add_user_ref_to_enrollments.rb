class AddUserRefToEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_reference :enrollments, :user, foreign_key: true
  end
end
