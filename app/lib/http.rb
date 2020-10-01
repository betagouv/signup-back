module Http
  def self.get(url_as_string, api_key, endpoint_label, auth_header = nil)
    response = if auth_header.nil?
      HTTP
        .auth("Bearer #{api_key}")
        .headers(accept: "application/json")
        .get(url_as_string)
    else
      HTTP
        .headers(auth_header => api_key)
        .headers(accept: "application/json")
        .get(url_as_string)
    end

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        endpoint_label,
        url_as_string,
        response.code,
        response.parse
      )
    end

    response
  rescue HTTP::Error => e
    raise ApplicationController::BadGateway.new(
      endpoint_label,
      url_as_string,
      nil,
      nil
    ), e.message
  end

  def self.request(http_verb, url_as_string, body, api_key, endpoint_label, auth_header)
    response = if auth_header.nil?
      HTTP
        .auth("Bearer #{api_key}")
        .headers(accept: "application/json")
        .send(http_verb, url_as_string, json: body)
    else
      HTTP
        .headers(auth_header => api_key)
        .headers(accept: "application/json")
        .send(http_verb, url_as_string, json: body)
    end

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        endpoint_label,
        url_as_string,
        response.code,
        response.parse
      )
    end

    response
  rescue HTTP::Error => e
    raise ApplicationController::BadGateway.new(
      endpoint_label,
      url_as_string,
      nil,
      nil
    ), e.message
  end

  def self.post(url_as_string, body, api_key, endpoint_label, auth_header = nil)
    request(:post, url_as_string, body, api_key, endpoint_label, auth_header)
  end

  def self.patch(url_as_string, body, api_key, endpoint_label, auth_header = nil)
    request(:patch, url_as_string, body, api_key, endpoint_label, auth_header)
  end
end
