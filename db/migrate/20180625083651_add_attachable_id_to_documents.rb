class AddAttachableIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :attachable_id, :integer
  end
end
