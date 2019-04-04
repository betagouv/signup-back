class Enrollment::ApiParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    if create? || send_application?
      res.concat([
        scopes: [
          :dgfip_avis_imposition,
          :dgfip_adresse,
          :cnaf_quotient_familial,
          :cnaf_attestation_droits
        ]
      ])
    end

    res
  end
end
