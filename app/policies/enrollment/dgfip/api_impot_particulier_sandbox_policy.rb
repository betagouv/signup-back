class Enrollment::ApiImpotParticulierSandboxPolicy < Enrollment::Dgfip::SandboxPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_rfr,
        :dgfip_nbpart,
        :dgfip_aft,
        :dgfip_locaux_th,
        :dgfip_eligibilite_lep,
        :dgfip_annee_n_moins_1,
        :dgfip_annee_n_moins_2,
        :dgfip_acces_spi,
        :dgfip_acces_etat_civil
      ]
    ])

    res
  end
end
