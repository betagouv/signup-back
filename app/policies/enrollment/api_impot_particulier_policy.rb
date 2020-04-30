class Enrollment::ApiImpotParticulierPolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :previous_enrollment_id,
      :organization_id,
      :intitule,
      :description,
      contacts: [:id, :given_name, :family_name, :email, :phone_number],
      scopes: [
        :dgfip_rfr,
        :dgfip_nbpart,
        :dgfip_aft,
        :dgfip_locaux_th,
        :dgfip_annee_n_moins_1,
        :dgfip_annee_n_moins_2
      ],
      additional_content: [
        :rgpd_general_agreement,
        :volumetrie_appels_par_minute
      ]
    ])

    res
  end
end
