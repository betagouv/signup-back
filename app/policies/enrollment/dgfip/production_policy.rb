class Enrollment::Dgfip::ProductionPolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :previous_enrollment_id,
      :fondement_juridique_title,
      :fondement_juridique_url,
      :data_recipients,
      :data_retention_period,
      :data_retention_comment,
      :dpo_family_name,
      :dpo_given_name,
      :dpo_email,
      :dpo_phone_number,
      :dpo_job,
      :responsable_traitement_family_name,
      :responsable_traitement_given_name,
      :responsable_traitement_email,
      :responsable_traitement_phone_number,
      :responsable_traitement_job,
      documents_attributes: [
        :attachment,
        :type
      ],
      additional_content: [
        :autorite_homologation_nom,
        :autorite_homologation_fonction,
        :date_homologation,
        :date_fin_homologation,
        :recette_fonctionnelle,
        :volumetrie_appels_par_minute
      ]
    ])

    res
  end
end
