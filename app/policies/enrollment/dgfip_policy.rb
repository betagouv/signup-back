class Enrollment::DgfipPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    res.concat([
      additional_content: [
        :autorite_certification,
        :ips_de_production,
        :autorite_homologation_nom,
        :autorite_homologation_fonction,
        :date_homologation,
        :date_fin_homologation,
        :nombre_demandes_annuelle,
        :pic_demandes_par_seconde,
        :recette_fonctionnelle,
        :rgpd_general_agreement,
        :nombre_demandes_mensuelles => [],
        scopes: [
          :dgfip_rfr,
          :dgfip_nbpart,
          :dgfip_sitfam,
          :dgfip_pac,
          :dgfip_aft
        ],
        dgfip_data_years: [
          :n_moins_1,
          :n_moins_2
        ]
      ]
    ])

    res
  end
end
