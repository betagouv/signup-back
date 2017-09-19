class Enrollment < ApplicationRecord
  resourcify
  validate :agreement_validation

  has_many :documents
  accepts_nested_attributes_for :documents

  private

  def agreement_validation
    return if agreement

    errors.add(:agreement, "Vous devez accepter les conditions d'utilisation")
  end
end
