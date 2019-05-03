class EnrollmentsController < ApplicationController
  before_action :authenticate!, except: [:public]
  before_action :set_enrollment, only: %i[show update update_contacts trigger]

  # GET /enrollments
  def index
    @enrollments = policy_scope(Enrollment)

    if params.fetch(:archived, false)
      @enrollments = @enrollments.where(status: ['validated', 'refused'])
    end

    if params.fetch(:status, false)
      @enrollments = @enrollments.where(status: params.fetch(:status, false))
    end

    if params.fetch(:target_api, false)
      @enrollments = @enrollments.where(target_api: params.fetch(:target_api, false))
    end

    if not params.fetch(:archived, false) and not params.fetch(:status, false)
      @enrollments = @enrollments.where.not(status: ['validated', 'refused'])
    end

    if params.fetch(:detailed, false)
      render json: @enrollments
    else
      render json: @enrollments, each_serializer: LightEnrollmentSerializer
    end
  end

  # GET /enrollments/1
  def show
    authorize @enrollment, :show?
    render json: @enrollment
  end

  # GET /enrollments/public
  def public
    enrollments = Enrollment
      .where(status: 'validated')
      .order(updated_at: :desc)

    if params.fetch(:target_api, false)
      enrollments = enrollments.where(target_api: params.fetch(:target_api, false))
    end

    render json: enrollments, each_serializer: PublicEnrollmentListSerializer
  end

  # POST /enrollments
  def create
    target_api = params.fetch(:enrollment, {})['target_api']
    enrollment_class = "Enrollment::#{target_api.underscore.classify}".constantize
    @enrollment = enrollment_class.new

    authorize @enrollment

    @enrollment.update_attributes(permitted_attributes(@enrollment))
    @enrollment.user = current_user

    if @enrollment.save
      @enrollment.events.create(name: 'created', user_id: current_user.id)

      EnrollmentMailer.with(
        to: current_user.email,
        target_api: @enrollment.target_api,
        enrollment_id: @enrollment.id,
        template: 'create_application',
      ).notification_email.deliver_later

      render json: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /enrollments/1
  def update
    authorize @enrollment

    if @enrollment.update(permitted_attributes(@enrollment))
      @enrollment.events.create(name: 'updated', user_id: current_user.id)
      render json: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH /enrollments/1/update_contacts
  def update_contacts
    authorize @enrollment

    if @enrollment.update(permitted_attributes(@enrollment))
      @enrollment.events.create(name: 'updated_contacts', user_id: current_user.id)
      EnrollmentMailer.with(
          to: @enrollment.admins.map(&:email),
          target_api: @enrollment.target_api,
          enrollment_id: @enrollment.id,
          template: 'update_contacts',
          applicant_email: current_user.email
      ).notification_email.deliver_later

      render json: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH /enrollment/1/trigger
  def trigger
    event = params[:event]
    unless Enrollment.state_machine.events.map(&:name).include?(event.to_sym)
      return render status: :bad_request, json: {
          message: ['event not permitted']
      }
    end
    authorize @enrollment, "#{event}?".to_sym

    state_machine_event_to_event_names = {
        'send_application' => 'submitted',
        'validate_application' => 'validated',
        'review_application' => 'asked_for_modification',
        'refuse_application' => 'refused'
    }
    # here we create the event first to ensure the comment is present when needed
    # a cleaner way of doing this should be to create the event before enrollment transition
    @enrollment.events.create!(name: state_machine_event_to_event_names[event], user_id: current_user.id, comment: params[:comment])

    if @enrollment.send(event.to_sym)
      EnrollmentMailer.with(
        to: @enrollment.user.email,
        target_api: @enrollment.target_api,
        enrollment_id: @enrollment.id,
        template: event,
        message: params[:comment]
      ).notification_email.deliver_later

      if event == 'send_application'
        EnrollmentMailer.with(
          to: @enrollment.admins.map(&:email),
          target_api: @enrollment.target_api,
          enrollment_id: @enrollment.id,
          template: 'notify_application_sent',
          applicant_email: current_user.email
        ).notification_email.deliver_later
      end

      render json: @enrollment
    else
      render status: :unprocessable_entity, json: @enrollment.errors
    end
  end

  private

  def set_enrollment
    @enrollment = policy_scope(Enrollment).find(params[:id])
  end

  def pundit_params_for(record)
    params.fetch(:enrollment, {})
  end
end
