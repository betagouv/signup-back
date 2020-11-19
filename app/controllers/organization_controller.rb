class InseeProxyController < ApplicationController
  # GET /insee-proxy/naf/1
  def naf
    response = File.read("./public/codes_naf.json")
    parsed_response = JSON.parse(response)

    code = params.fetch(:id, "").gsub('.', '')

    if(parsed_response[code].nil?)
      render status: :ok, json: { libelle: "Code inconnu" }
    else
      render status: :ok, json: { libelle: parsed_response[code] }
    end
  end
end
