# frozen_string_literal: true

class Event < ActiveRecord::Base
  belongs_to :enrollment
  belongs_to :user

  validate :validate_comment

  protected

  def validate_comment
    errors[:comment] << "Vous devez renseigner un commentaire" if name.in?(["refused", "asked_for_modification"]) && !comment.present?
  end
end
