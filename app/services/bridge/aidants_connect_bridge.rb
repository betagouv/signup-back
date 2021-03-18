class AidantsConnectBridge < BridgeService
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def call
    response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/#{@enrollment.siret}")
    geo_adresse = response.parse["etablissement"]["geo_adresse"]

    Http.post(
      "#{ENV.fetch("AIDANTS_CONNECT_HOST")}/datapass_receiver/",
      {
        data_pass_id: @enrollment.id,
        organization_name: @enrollment.intitule,
        organization_siret: @enrollment.siret,
        organization_address: geo_adresse
      },
      ENV.fetch("AIDANTS_CONNECT_API_KEY"),
      "Aidants Connect"
    )
  end
end
