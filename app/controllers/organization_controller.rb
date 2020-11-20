class InseeController < ApplicationController
  # GET /insee/naf/1
  def naf
    response = File.read("./public/codes_naf.json")
    parsed_response = JSON.parse(response)

    code = params.fetch(:id, "").gsub('.', '')

    if(parsed_response[code].nil?)
      render status: :not_found, json: {}
    else
      render status: :ok, json: { message: parsed_response[code] }
    end
  end
end
