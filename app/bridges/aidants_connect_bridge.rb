class AidantsConnectBridge < ApplicationBridge
  def call
    Http.post(
      "#{ENV.fetch("AIDANTS_CONNECT_HOST")}/datapass_receiver/",
      {
        data_pass_id: @enrollment.id,
        organization_name: @enrollment.intitule,
        organization_siret: @enrollment.siret,
        organization_address: @enrollment.additional_content&.fetch("organization_address", "")
      },
      ENV.fetch("AIDANTS_CONNECT_API_KEY"),
      "Aidants Connect"
    )
  end
end
