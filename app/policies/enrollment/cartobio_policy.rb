class Enrollment::CartobioPolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :organization_id,
      :intitule,
      :description,
      contacts: [:id, :email],
      documents_attributes: [
        :attachment,
        :type
      ],
      additional_content: [
        :location_scopes,
        :secret_statistique_agreement,
        :partage_agreement,
        :protection_agreement,
        :exhaustivite_agreement,
        :information_agreement
      ]
    ])

    res
  end
end
