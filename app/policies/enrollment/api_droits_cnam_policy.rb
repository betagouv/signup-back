class Enrollment::ApiDroitsCnamPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :cnam_ayant_droits,
        :cnam_caisse_gestionnaire,
        :cnam_droits,
        :cnam_exonerations,
        :cnam_medecin_traitant,
        :cnam_presence_medecin_traitant,
      ],
    ])

    res
  end
end
