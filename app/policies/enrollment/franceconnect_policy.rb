class Enrollment::FranceconnectPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :openid,
        :gender,
        :birthdate,
        :birthcountry,
        :birthplace,
        :given_name,
        :family_name,
        :email,
      ],
      additional_content: [
        :has_alternative_authentication_methods,
      ],
    ])

    res
  end
end
