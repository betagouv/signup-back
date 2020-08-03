class Enrollment::LeTaxiPolicy < EnrollmentPolicy
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
      :dpo_label,
      :dpo_email,
      :dpo_phone_number,
      :responsable_traitement_label,
      :responsable_traitement_email,
      :responsable_traitement_phone_number,
      contacts: [:id, :email, :phone_number],
      scopes: [
        :operator,
        :search_engine,
      ],
    ])

    res
  end
end
