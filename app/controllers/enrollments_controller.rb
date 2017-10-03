class EnrollmentsController < ApplicationController
  before_action :authenticate!
  before_action :set_enrollment, only: %i[show update trigger destroy]

  # GET /enrollments
  def index
    @enrollments = enrollments_scope

    render json: @enrollments.map { |e| serialize(e) }
  end

  # GET /enrollments/1
  def show
    render json: serialize(@enrollment)
  end

  # POST /enrollments
  def create
    @enrollment = enrollments_scope.new(enrollment_params)

    authorize @enrollment, :create?

    if @enrollment.save
      current_user.add_role(:applicant, @enrollment)
      render json: @enrollment, status: :created, location: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/1
  def update
    authorize @enrollment, :update?
    if @enrollment.update(enrollment_params)
      render json: serialize(@enrollment)
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH /enrollment/1/trigger
  def trigger
    authorize @enrollment, "#{event_param}?".to_sym

    @enrollment.send("#{event_param}!".to_sym)
    render json: serialize(@enrollment)
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

  def event_param
    event = params[:event]
    raise EventNotPermitted unless Enrollment.state_machine.events.map(&:name).include?(event)
    event
  end

  class EventNotPermitted < StandardError; end

  rescue_from EventNotPermitted do
    render status: :bad_request, json: {
      message: ['event not permitted']
    }
  end

  def serialize(enrollment)
    enrollment.as_json(
      include: [{
        documents: { methods: :type }
      }, {
        messages: { include: :user }
      }]
    ).merge(acl: Hash[
      EnrollmentPolicy.acl_methods.map do |method|
        [method.to_s.gsub(/\?/, ''), EnrollmentPolicy.new(current_user, enrollment).send(method)]
      end
    ])
  end
end
