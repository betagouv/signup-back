class Enrollment::DgfipPolicy < EnrollmentPolicy
  def permitted_attributes
    res = super

    if create? || send_application?
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
          dgfip_data_years: [
            :n_moins_1,
            :n_moins_2
          ]
        ]
      ])
    end

    res
  end
end
