# frozen_string_literal: true

class Message < ApplicationRecord
  enum category: { refuse_application: 0, review_application: 1 }
  belongs_to :enrollment, optional: true
  belongs_to :dgfip, optional: true, class_name: 'Enrollment::Dgfip'

  validate :presence_of_content

  resourcify

  def sender
    User.with_role(:sender, self).first
  end

  private

  def presence_of_content
    errors[:content] << "Vous devez renseigner un contenu de message avant de continuer" unless content.present?
  end
end
