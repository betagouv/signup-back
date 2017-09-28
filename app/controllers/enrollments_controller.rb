class EnrollmentsController < ApplicationController
  before_action :authenticate!
  before_action :set_enrollment, only: %i[show update destroy]

  # GET /enrollments
  def index
    @enrollments = enrollments_scope

    render json: @enrollments.to_json(include: {
                                        documents: { methods: :type }
                                      })
  end

  # GET /enrollments/1
  def show
    render json: @enrollment.to_json(include: [{
                                       documents: { methods: :type }
                                     }, { messages: { include: :user } }])
  end

  # POST /enrollments
  def create
    @enrollment = enrollments_scope.new(enrollment_params)
    current_user.add_role(:applicant, @enrollment)

    authorize @enrollment, :create?

    if @enrollment.save
      render json: @enrollment, status: :created, location: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/1
  def update
    authorize @enrollment, :update?
    if @enrollment.update(enrollment_params)
      render json: @enrollment.to_json(include: {
                                         documents: { methods: :type }
                                       })
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /enrollments/1
  def destroy
    @enrollment.destroy
  end

  private

  def set_enrollment
    @enrollment = enrollments_scope.find(params[:id])
  end

  def enrollments_scope
    EnrollmentPolicy::Scope.new(current_user, Enrollment).resolve
  end

  def enrollment_params
    params.require(:enrollment).permit(:agreement, service_provider: {}, scopes: {}, legal_basis: {}, service_description: {}, documents_attributes: %i[type attachment], applicant: {})
  end
end
