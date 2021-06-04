class Enrollment::ApiProSanteConnectPolicy < EnrollmentPolicy
  def permitted_attributes
    [
      :cgu_approved,
      :target_api,
      :organization_id,
      :intitule,
      :description,
      contacts: [:id, :email],
      scopes: [:idnat, :donnees_sectorielles]
    ]
  end
end
