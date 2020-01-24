module Http
  def self.get(url_as_string, api_key, endpoint_label)
    response = HTTP
      .auth("Bearer #{api_key}")
      .headers(accept: "application/json")
      .get(url_as_string)

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        endpoint_label,
        url_as_string,
        response.code,
        response.parse,
      )
    end

    response
  rescue HTTP::Error => e
    raise ApplicationController::BadGateway.new(
      endpoint_label,
      url_as_string,
      nil,
      nil,
    ), e.message
  end

  def self.post(url_as_string, body, api_key, endpoint_label)
    response = HTTP
      .auth("Bearer #{api_key}")
      .headers(accept: "application/json")
      .post(url_as_string, json: body)

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        endpoint_label,
        url_as_string,
        response.code,
        response.parse,
      )
    end

    response
  rescue HTTP::Error => e
    raise ApplicationController::BadGateway.new(
      endpoint_label,
      url_as_string,
      nil,
      nil,
    ), e.message
  end
end
