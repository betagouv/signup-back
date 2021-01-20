class Enrollment::FrancerelanceApiOuvertePolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :target_api,
      :organization_id,
      :intitule,
      :description,
      contacts: [
        :id,
        :family_name,
        :given_name,
        :email,
        :phone_number
      ],
      additional_content: [
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
