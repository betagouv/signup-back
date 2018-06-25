class RemoveDocumentsOldAssociations < ActiveRecord::Migration[5.1]
  def change
    remove_column :documents, :dgfip_id, :integer
    remove_column :documents, :enrollment_id, :integer
  end
end
