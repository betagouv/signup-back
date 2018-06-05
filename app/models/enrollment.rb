# frozen_string_literal: true
require 'zip'

class Enrollment < ApplicationRecord
  DOCUMENT_TYPES = %w[
  ].freeze

  validate :abstract_class_validation

  has_many :messages
  accepts_nested_attributes_for :messages
  has_many :documents
  accepts_nested_attributes_for :documents

  scope :api_particulier, -> { where(fournisseur_de_donnees: 'api-particulier') }
  scope :api_entreprise, -> { where(fournisseur_de_donnees: 'api-entreprise') }
  scope :dgfip, -> { where(fournisseur_de_donnees: 'dgfip') }

  state_machine :state, initial: :pending do
    state :pending
    state :sent
    state :validated
    state :refused
    state :technical_inputs
    state :deployed

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

    event :send_technical_inputs do
      transition from: :validated, to: :technical_inputs
    end

    event :deploy_application do
      transition from: :technical_inputs, to: :deployed
    end
  end

  def can_send_technical_inputs?
    if self.class.abstract?
      false
    else
      super
    end
  end

  def self.with_role(type, user)
    return super(type, user) unless abstract?
    Rails.application.eager_load!

    enrollment_ids = descendants.map do |klass|
      klass.with_role(type, user).pluck(:id)
    end.flatten

    where(id: enrollment_ids)
  end

  protected

  def self.abstract?
    name == 'Enrollment'
  end

  def abstract_class_validation
    errors[:base] << "Vous devez fournir un type d'enrôlement" if self.class.abstract?
  end
end
