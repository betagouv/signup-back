class Enrollment::Dgfip < Enrollment
  resourcify

  def as_json(*params)
    super(*params).merge({
      'autorite_certification' => autorite_certification,
      'ips_de_production' => ips_de_production,
      'autorite_certification_nom' => autorite_certification_nom,
      'autorite_certification_fonction' => autorite_certification_fonction,
      'date_homologation' => date_homologation,
      'date_fin_homologation' => date_fin_homologation,
      'nombre_demandes_annuelle' => nombre_demandes_annuelle,
      'pic_demandes_par_seconde' => pic_demandes_par_seconde,
      'nombre_demandes_mensuelles_jan' => nombre_demandes_mensuelles_jan,
      'nombre_demandes_mensuelles_fev' => nombre_demandes_mensuelles_fev,
      'nombre_demandes_mensuelles_mar' => nombre_demandes_mensuelles_mar,
      'nombre_demandes_mensuelles_avr' => nombre_demandes_mensuelles_avr,
      'nombre_demandes_mensuelles_mai' => nombre_demandes_mensuelles_mai,
      'nombre_demandes_mensuelles_jui' => nombre_demandes_mensuelles_jui,
      'nombre_demandes_mensuelles_jul' => nombre_demandes_mensuelles_jul,
      'nombre_demandes_mensuelles_aou' => nombre_demandes_mensuelles_aou,
      'nombre_demandes_mensuelles_sep' => nombre_demandes_mensuelles_sep,
      'nombre_demandes_mensuelles_oct' => nombre_demandes_mensuelles_oct,
      'nombre_demandes_mensuelles_nov' => nombre_demandes_mensuelles_nov,
      'nombre_demandes_mensuelles_dec' => nombre_demandes_mensuelles_dec,
      'recette_fonctionnelle' => recette_fonctionnelle
    })
  end
end
