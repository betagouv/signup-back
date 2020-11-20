class DemarchesController < ApplicationController
  # GET /demarches/target_api
  def index
    response = File.read("./public/demarches.json")

    parsed_response = JSON.parse(response)

    target_api = params.fetch(:target_api, "")
    if !EnrollmentMailer::MAIL_PARAMS.key?(target_api)
      render status: :not_found, json: {}
    elsif parsed_response[target_api].nil?
      render status: :not_found, json: {}
    else
      render status: :ok, json: parsed_response[target_api]
    end
  end
end
