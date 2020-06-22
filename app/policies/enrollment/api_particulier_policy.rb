class Enrollment::ApiParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_avis_imposition,
        :dgfip_adresse,
        :cnaf_quotient_familial,
        :cnaf_allocataires,
        :cnaf_enfants,
        :cnaf_adresse,
      ],
    ])

    res
  end
end
