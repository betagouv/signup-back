class EnrollmentsEmailTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :extract_enrollment

  def index
    render json: email_templates,
           each_serializer: EnrollmentEmailTemplateSerializer,
           adapter: :json,
           root: "email_templates",
           status: :ok
  end

  private

  def email_templates
    EnrollmentEmailTemplatesRetriever.new(@enrollment, current_user).perform
  end

  def extract_enrollment
    @enrollment = policy_scope(Enrollment).find(params[:id])
  end
end
