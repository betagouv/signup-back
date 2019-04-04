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
          :given,
          :family,
          :email,
          :preferred,
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
