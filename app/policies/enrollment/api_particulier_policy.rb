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
        :pole_emploi_identite,
        :pole_emploi_contact,
        :pole_emploi_adresse,
        :pole_emploi_inscription
      ]
    ])

    res
  end
end
