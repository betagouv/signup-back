class Enrollment::ApiImpotParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_rfr,
        :dgfip_nbpart,
        :dgfip_aft,
        :dgfip_locaux_th,
        :dgfip_annee_n_moins_1,
        :dgfip_annee_n_moins_2,
      ],
      additional_content: [
        :rgpd_general_agreement,
        :production_date,
      ],
    ])

    res
  end
end
