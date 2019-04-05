# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  before_action :authenticate!, except: [:public]
  before_action :set_enrollment, only: %i[show update update_contacts trigger destroy]

  # GET /enrollments
  def index
    @enrollments = enrollments_scope

    if params.fetch(:archived, false)
      @enrollments = @enrollments.archived
    end

    if params.fetch(:status, false)
      @enrollments = @enrollments.status(params.fetch(:status, false))
    end

    if params.fetch(:target_api, false)
      @enrollments = @enrollments.target_api(params.fetch(:target_api, false))
    end

    if not params.fetch(:archived, false) and not params.fetch(:status, false)
      @enrollments = @enrollments.pending
    end

    render json: @enrollments, each_serializer: LightEnrollmentSerializer
  end

  # GET /enrollments/1
  def show
    render json: @enrollment
  end

  # GET /enrollments/public
  def public
    enrollments = Enrollment
      .where("status = ?", 'validated')
      .order(updated_at: :desc)

    if params.fetch(:target_api, false)
      enrollments = enrollments.where("target_api = ?", params.fetch(:target_api, ''))
    end

    render json: enrollments, each_serializer: PublicEnrollmentListSerializer
  end

  # POST /enrollments
  def create
    @enrollment = enrollments_scope.new(enrollment_params)

    authorize @enrollment, :create?

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
    @enrollment.attributes = enrollment_params
    authorize @enrollment, :update?

    if @enrollment.save
      @enrollment.events.create(name: 'updated', user_id: current_user.id)
      render json: @enrollment
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end

  # PATCH /enrollments/1/update_contacts
  def update_contacts
    @enrollment.attributes = enrollment_params
    authorize @enrollment, :update_contacts?

    if @enrollment.save
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
    unless enrollment_class.state_machine.events.map(&:name).include?(event.to_sym)
      return render status: :bad_request, json: {
          message: ['event not permitted']
      }
    end
    authorize @enrollment, "#{event}?".to_sym

    if @enrollment.send(event.to_sym)
      state_machine_event_to_event_names = {
        'send_application' => 'submitted',
        'validate_application' => 'validated',
        'review_application' => 'asked_for_modification',
        'refuse_application' => 'refused'
      }
      @enrollment.events.create!(name: state_machine_event_to_event_names[event], user_id: current_user.id, comment: params[:comment])

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

  # DELETE /enrollments/1
  def destroy
    authorize @enrollment, :delete?
    @enrollment.destroy
  end

  private

  def set_enrollment
    @enrollment = enrollments_scope.find(params[:id])
  end

  def enrollment_class
    type = params.fetch(:enrollment, {})[:target_api]
    type = %w[dgfip api_particulier api_entreprise franceconnect api_droits_cnam api_entreprise].include?(type) ? type : nil
    class_name = type ? "Enrollment::#{type.underscore.classify}" : 'Enrollment'
    class_name.constantize
  end

  def enrollments_scope
    EnrollmentPolicy::Scope.new(current_user, enrollment_class).resolve
  end

  def enrollment_params
    params
      .fetch(:enrollment, {})
      .permit(*policy(enrollment_class.new).permitted_attributes)
  end
end
