class Enrollment::ApiParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_avis_imposition,
        :dgfip_adresse,
        :cnaf_quotient_familial,
        :cnaf_attestation_droits
      ]
    ])

    res
  end
end
