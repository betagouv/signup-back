class Enrollment::FrancerelanceFcPolicy < EnrollmentPolicy
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
      contacts: [
        :id,
        :family_name,
        :given_name,
        :email,
        :phone_number
      ],
      additional_content: [
        :has_alternative_authentication_methods,
        :utilisation_franceconnect_autre_projet,
        :date_integration,
        :types_de_depenses,
        :nom_beneficiaire,
        :iban,
        :bic
      ]
    ])

    res
  end
end
