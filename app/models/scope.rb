class Scope < ApplicationRecord
  belongs_to :resource_provider

  validate :services_validation

  private

  def services_validation
    validator = JSON::Validator.validate!(File.read(Rails.root.join('lib/schemas/resource_provider_services.json')), response.body)
    return if validator
    errors.add(:services, 'Services ne respecte pas le schema')
  end
end
