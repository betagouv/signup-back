class Enrollment::ApiEntreprisePolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :association,
        :attestation_agefiph,
        :attestation_fiscale,
        :attestation_sociale,
        :bilans_entreprises_bdf,
        :carte_pro_fntp,
        :certificat_cnetp,
        :cotisation_msa,
        :certificat_opqibi,
        :certificat_probtp,
        :certificat_qualibat,
        :certificat_rge_ademe,
        :document_association,
        :exercice,
        :extrait_inpi,
        :extrait_rcs,
        :insee_entreprise,
        :insee_etablissement,
        :liasse_fiscale,
      ]
    ])

    res
  end
end
