# frozen_string_literal: true

class Document < ApplicationRecord
  mount_uploader :attachment, DocumentUploader

  belongs_to :attachable, polymorphic: true, optional: true

  validates_presence_of :type, :attachment

  before_save :overwrite
  after_save :touch_enrollment

  default_scope -> { where(archive: false) }

  private

  def touch_enrollment
    attachable.touch
  end

  def overwrite
    attachable
      .documents
      .where(type: type)
      .update_all(archive: true)
  end
end
