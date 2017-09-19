class Document < ApplicationRecord
  mount_uploader :attachment, DocumentUploader

  belongs_to :enrollment

  validates_presence_of :type, :attachment

  before_save :overwrite

  def overwrite
    enrollment
      .documents
      .where(type: type).to_a
     .map(&:delete)
  end
end
