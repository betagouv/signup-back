class Enrollment::FranceconnectPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    if create? || send_application?
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
          :preferred_username,
          :address,
          :phone
        ],
        additional_content: [
          :has_alternative_authentication_methods
        ]
      ])
    end

    res
  end
end
