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
      team_members_attributes: [:id, :type, :family_name, :given_name, :email, :phone_number, :job],
      additional_content: [
        :has_alternative_authentication_methods,
        :utilisation_franceconnect_autre_projet,
        :date_integration,
        :type_de_depenses,
        :code_ic
      ]
    ])

    res
  end
end
