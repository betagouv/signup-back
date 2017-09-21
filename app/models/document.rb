class Document < ApplicationRecord
  mount_uploader :attachment, DocumentUploader


  belongs_to :enrollment

  validates_presence_of :type, :attachment

  before_save :overwrite
  after_save :touch_enrollment

  private

  def touch_enrollment
    enrollment.touch
  end

  def overwrite
    enrollment
      .documents
      .where(type: type)
      .delete_all
  end
end
