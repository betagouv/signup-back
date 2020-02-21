class Enrollment::ApiImpotParticulierStep2Policy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :target_api,
      :previous_enrollment_id,
      :organization_id,
      :siret,
      documents_attributes: [
        :attachment,
        :type,
      ],
      additional_content: [
        :ips_de_production,
        :autorite_homologation_nom,
        :autorite_homologation_fonction,
        :date_homologation,
        :date_fin_homologation,
        :nombre_demandes_annuelle,
        :pic_demandes_par_heure,
        :recette_fonctionnelle,
        nombre_demandes_mensuelles: [],
      ],
    ])

    res
  end
end
