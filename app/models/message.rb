# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :enrollment
  belongs_to :user

  validates_presence_of :content
end
