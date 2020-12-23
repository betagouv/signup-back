class Enrollment::FranceconnectPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :family_name,
        :given_name,
        :birthdate,
        :birthplace,
        :birthcountry,
        :gender,
        :preferred_username,
        :email,
        :openid
      ],
      additional_content: [
        :eidas_1,
        :eidas_2,
        :has_alternative_authentication_methods
      ]
    ])

    res
  end
end
