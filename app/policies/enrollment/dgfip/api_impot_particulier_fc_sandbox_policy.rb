class Enrollment::ApiImpotParticulierFcSandboxPolicy < Enrollment::Dgfip::SandboxPolicy
  def permitted_attributes
    res = super

    res.concat([
      scopes: [
        :dgfip_rfr,
        :dgfip_nbpart,
        :dgfip_aft,
        :dgfip_locaux_th,
        :dgfip_sitfam,
        :dgfip_nbpac,
        :dgfip_annee_n_moins_1,
        :dgfip_annee_n_moins_2,
        :dgfip_annee_n_moins_3
      ],
    ])

    res
  end
end
