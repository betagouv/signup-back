class Enrollment::ApiImpotParticulierFcSandbox < Enrollment::Dgfip::SandboxEnrollment
  protected

  def sent_validation
    super

    unless scopes.any? { |k, v| v && %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2 dgfip_annee_n_moins_3].include?(k) }
      errors[:scopes] << "Vous devez cocher au moins une année de revenus souhaitée avant de continuer"
    end
  end
end
