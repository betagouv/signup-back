class ApplicationController < ActionController::API
  class AccessDenied < StandardError
  end

  include Pundit

  rescue_from AccessDenied do |e|
    render status: :unauthorized, json: {
      message: "Vous n'êtes pas autorisé à accéder à cette API",
      detail: e.message,
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
