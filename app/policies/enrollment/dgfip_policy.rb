class Enrollment::DgfipPolicy < EnrollmentPolicy
  # def convention?
  #   false
  # end

  def permitted_attributes
    res = super

    if create? || send_application?
      res.concat([
         :autorite_certification,
         :ips_de_production,
         :autorite_homologation_nom,
         :autorite_homologation_fonction,
         :date_homologation,
         :date_fin_homologation,
         :nombre_demandes_annuelle,
         :pic_demandes_par_seconde,
         :nombre_demandes_mensuelles_jan,
         :nombre_demandes_mensuelles_fev,
         :nombre_demandes_mensuelles_mar,
         :nombre_demandes_mensuelles_avr,
         :nombre_demandes_mensuelles_mai,
         :nombre_demandes_mensuelles_jui,
         :nombre_demandes_mensuelles_jul,
         :nombre_demandes_mensuelles_aou,
         :nombre_demandes_mensuelles_sep,
         :nombre_demandes_mensuelles_oct,
         :nombre_demandes_mensuelles_nov,
         :nombre_demandes_mensuelles_dec,
         :recette_fonctionnelle,
         documents_attributes: [
             :attachment,
             :type
         ]
     ])
    end

    res
  end
end
