class Enrollment::FranceconnectPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    if create? || send_application?
      res.concat([
        additional_content: [
          :has_alternative_authentication_methods
        ]
      ])
    end
  end
end
