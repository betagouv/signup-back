# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :enrollment

  validates_presence_of :content

  resourcify

  def sender
    User.with_role(:sender, self).first
  end

  def reciepients
    enrollment.user
  end
end
