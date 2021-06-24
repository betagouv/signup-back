class Enrollment::LeTaxiClientsPolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :previous_enrollment_id,
      :organization_id,
      :intitule,
      :description,
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
      contacts: [:id, :email, :phone_number]
    ])

    res
  end
end
