# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  resourcify
  has_many :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  validates_presence_of(
    :fournisseur_de_service,
    :description_service
  )
  validate :convention_validated?

  # Note convention on events "#{verb}_#{what}" (see CoreAdditions::String#as_event_personified)
  state_machine :state, initial: :pending do
    state :pending
    state :sent do
      validates_presence_of(
        :validation_de_convention,
        :fondement_juridique,
      )
    end
    state :validated
    state :refused

    event :send_application do
      transition from: :pending, to: :sent
    end

    event :validate_application do
      transition from: :sent, to: :validated
    end

    event :refuse_application do
      transition from: :sent, to: :refused
    end

    event :review_application do
      transition from: :sent, to: :pending
    end
  end

  private

  def convention_validated?
    errors[:validation_de_convention] << "Vous devez valider la convention avant de continuer" unless validation_de_convention?
  end
end
