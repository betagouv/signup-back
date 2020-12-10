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
        :organization_address,
        :associated_public_organisation,
        :label_pass_numerique,
        :label_france_services,
        :label_fabrique_territoires,
        :membre_reseau,
        :nombre_aidants,
        :utilisation_identifiants_usagers,
        :demandes_par_semaines,
        :teletravail_autorise,
        :adresse_mail_professionnelle,
        :telephone_portable_professionnel,
        :ordinateur_professionnel
      ]
    ])

    res
  end
end
