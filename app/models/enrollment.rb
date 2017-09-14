class Enrollment < ApplicationRecord
  validate :agreement_validation

  private

  def agreement_validation
    return if agreement

    errors.add(:agreement, "Vous devez accepter les conditions d'utilisation")
  end
end
