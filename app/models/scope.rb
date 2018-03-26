class Scope < ApplicationRecord
  belongs_to :resource_provider

  validate :services_validation

  private

  def services_validation
    JSON::Validator.validate!(File.read(Rails.root.join('lib/schemas/resource_provider_services.json')), services)
  rescue JSON::Schema::ValidationError => e
    errors.add(:services, e.message)
  end
end
