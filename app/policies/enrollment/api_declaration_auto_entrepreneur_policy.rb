class Enrollment::ApiDeclarationAutoEntrepreneurPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      contacts: [
        :id,
        :family_name,
        :given_name,
        :email,
        :phone_number
      ]
    ])

    res
  end
end
