class Enrollment::AidantsConnectPolicy < EnrollmentPolicy
  def permitted_attributes
    res = []

    res.concat([
      :cgu_approved,
      :target_api,
      :organization_id,
      :intitule,
      :description,
      contacts: [
        :id,
        :family_name,
        :given_name,
        :email,
        :phone_number
      ],
      documents_attributes: [
        :attachment,
        :type
      ],
      additional_content: [
        :organization_type,
        :organization_address,
        :organization_postal_code,
        :organization_website,
        :participation_reseau,
        :nom_reseau,
        :associated_public_organisation,
        :label_pass_numerique,
        :label_france_services,
        :label_fabrique_territoires,
        :recrutement_conseiller_numerique,
        :utilisation_identifiants_usagers,
        :demandes_par_semaines,
        :adresse_mail_professionnelle
      ]
    ])

    res
  end
end
