class FlattenContactsInEnrollments < ActiveRecord::Migration[5.1]
  def change
    add_reference :enrollments, :dpo, references: :users, index: true
    add_foreign_key :enrollments, :users, column: :dpo_id
    add_column :enrollments, :dpo_label, :string
    add_column :enrollments, :dpo_phone_number, :string
    add_reference :enrollments, :responsable_traitement, references: :users, index: true
    add_foreign_key :enrollments, :users, column: :responsable_traitement_id
    add_column :enrollments, :responsable_traitement_label, :string
    add_column :enrollments, :responsable_traitement_phone_number, :string
  end
end
