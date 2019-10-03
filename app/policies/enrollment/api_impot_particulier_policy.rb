class Enrollment::ApiImpotParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_rfr,
        :dgfip_nbpart,
        :dgfip_sitfam,
        :dgfip_pac,
        :dgfip_aft,
        :dgfip_data_years_n_moins_1,
        :dgfip_data_years_n_moins_2,
      ],
      additional_content: [
        :rgpd_general_agreement,
      ],
    ])

    res
  end
end
