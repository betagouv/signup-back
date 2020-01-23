class ApplicationController < ActionController::API
  class AccessDenied < StandardError
  end

  class BadGateway < StandardError
    attr_reader :endpoint_name
    attr_reader :url
    attr_reader :http_code
    attr_reader :http_body
    def initialize(endpoint_name, url, http_code, http_body)
      @endpoint_name = endpoint_name
      @url = url
      @http_code = http_code
      @http_body = http_body
    end
  end

  include Pundit

  rescue_from AccessDenied do |e|
    render status: :unauthorized, json: {
      message: "Vous n'êtes pas autorisé à accéder à cette API",
      detail: e.message,
    }
  end

  rescue_from BadGateway do |e|
    render status: :bad_gateway, json: {
      message: "Impossible d'envoyer les données à \"#{e.endpoint_name}\".\n\nMerci de communiquer les détails techniques de l'erreur à contact@api.gouv.fr :\n- url: #{e.url}\n- http code: #{e.http_code.to_s}\n- http body: #{e.http_body.to_json}\n- message: #{e.message.to_s}",
    }
  end

  rescue_from Pundit::NotAuthorizedError do |_|
    render status: :forbidden, json: {
      message: ["Vous n'êtes pas autorisé à modifier cette ressource"],
    }
  end

  rescue_from ActiveRecord::RecordNotFound do |_|
    render status: :not_found, json: {
      message: "Record not found",
    }
  end

  rescue_from ActiveRecord::RecordInvalid do |_|
    render status: :unprocessable_entity, json: {
      message: _.message,
    }
  end

  private

  def pagination_dict(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
    }
  end
end
