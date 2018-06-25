class AddAttachableTypeToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :attachable_type, :string
  end
end
