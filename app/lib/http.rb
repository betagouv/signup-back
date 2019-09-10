module Http
  def self.get(url_as_string, headers = {})
    url = URI(url_as_string)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["content-type"] = "application/json"
    request["cache-control"] = "no-cache"
    headers.each { |k, v| request[k] = v }

    http.request(request)
  end

  def self.post(url_as_string, body, headers = {})
    url = URI(url_as_string)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["cache-control"] = "no-cache"
    headers.each { |k, v| request[k] = v }

    request.body = body

    http.request(request)
  end
end
