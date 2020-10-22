class InseeProxyController < ApplicationController
  # GET /insee-proxy/naf/1
  def naf
    response = HTTP
      .headers(accept: "application/json")
      .post(
        "https://www.insee.fr/fr/metadonnees/nafr2/consultation",
        json: {q: params[:id]}
      )

    parsed_response = response.parse

    if parsed_response["documents"].nil? || parsed_response["documents"][0].nil?
      render status: :not_found, json: {}
    else
      render status: :ok, json: parsed_response["documents"][0]
    end
  end
end
