class DemarchesController < ApplicationController
  # GET /demarches/target_api
  def index
    response = HTTP
      .headers(accept: "application/json")
      .get(
        "https://demarches-api-gouv.app.etalab.studio"
      )

    parsed_response = response.parse

    target_api = params.fetch(:target_api, "")
    if !EnrollmentMailer::MAIL_PARAMS.key?(target_api)
      render status: :not_found, json: {}
    elsif parsed_response[target_api.tr("_", "-")].nil?
      render status: :not_found, json: {}
    else
      render status: :ok, json: parsed_response[target_api.tr("_", "-")]
    end
  end
end
