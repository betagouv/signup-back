class InseeController < ApplicationController
  # GET /insee/code_naf/1
  def code_naf
    response = File.read("./public/codes_naf.json")
    parsed_response = JSON.parse(response)

    code = params.fetch(:id, "").delete(".")

    if parsed_response[code].nil?
      render status: :not_found, json: {}
    else
      render status: :ok, json: {message: parsed_response[code]}
    end
  end

  # GET /insee/categorie_juridique/1
  def categorie_juridique
    response = File.read("./public/codes_naf.json")
    parsed_response = JSON.parse(response)

    code = params.fetch(:id, "")

    if parsed_response[code].nil?
      render status: :not_found, json: {}
    else
      render status: :ok, json: {message: parsed_response[code]}
    end
  end
end
