module SpecRoutingHelper
  def get_path(path)
    parsed_params = Rails.application.routes.recognize_path path
    parsed_params.delete(:controller)
    action = parsed_params.delete(:action)
    get(action, params: parsed_params)
  end
end

