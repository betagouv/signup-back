class EnrollmentsController < ApplicationController
  before_action :authenticate_user!, except: [:public]
  before_action :set_enrollment, only: %i[show update trigger]

  # GET /enrollments
  def index
    @enrollments = policy_scope(Enrollment)

    @enrollments = @enrollments.where(target_api: params.fetch(:target_api, false)) if params.fetch(:target_api, false)

    has_filter_by_status = false
    begin
      filter = JSON.parse(params.fetch(:filter, "[]"))
      has_filter_by_status = filter.any? { |f| f.key? "status" }
    rescue JSON::ParserError
      # silently fail, if the filter is not formatted properly we assume there is no filter by status
    end

    unless has_filter_by_status
      #  if filter by status is set, it overrides archive and status params (ie. we do not apply archive and status params)
      @enrollments = @enrollments.where(status: %w[validated refused]) if params.fetch(:archived, false)

      @enrollments = @enrollments.where(status: params.fetch(:status, false)) if params.fetch(:status, false)

      if !params.fetch(:archived, false) && !params.fetch(:status, false)
        @enrollments = @enrollments.where.not(status: %w[validated refused])
      end
    end

    begin
      sorted_by = JSON.parse(params.fetch(:sortedBy, "[]"))
      sorted_by.each do |sort_item|
        sort_item.each do |sort_key, sort_direction|
          next unless ["updated_at"].include? sort_key
          next unless %w[asc desc].include? sort_direction

          @enrollments = @enrollments.order("#{sort_key} #{sort_direction.upcase}")
        end
      end
    rescue JSON::ParserError
      # silently fail, if the sort is not formatted properly we do not apply it
    end

    begin
      filter = JSON.parse(params.fetch(:filter, "[]"))
      filter.each do |filter_item|
        filter_item.each do |filter_key, filter_value|
          next unless %w[id nom_raison_sociale target_api status].include? filter_key

          sanitized_filter_value = Enrollment.send(:sanitize_sql_like, filter_value)
          san_fil_val_without_accent = ActiveSupport::Inflector.transliterate(sanitized_filter_value)
          @enrollments = @enrollments.where(
            "LOWER(#{filter_key}::varchar(255)) LIKE ?",
            "%#{san_fil_val_without_accent.downcase}%"
          )
        end
      end
    rescue JSON::ParserError
      # silently fail, if the filter is not formatted properly we do not apply it
    end

    page = params.fetch(:page, "0")
    size = params.fetch(:size, "10")
    @enrollments = @enrollments.page(page.to_i + 1).per(size.to_i)

    serializer = LightEnrollmentSerializer

    if params.fetch(:detailed, false)
      serializer = EnrollmentSerializer
    end

    render json: @enrollments,
           each_serializer: serializer,
           meta: pagination_dict(@enrollments),
           adapter: :json,
           root: "enrollments"
  end

  # GET /enrollments/1
  def show
    authorize @enrollment, :show?
    render json: @enrollment
  end

  # GET /enrollments/public
  def public
    enrollments = Enrollment
      .where(status: "validated")
      .order(updated_at: :desc)

    enrollments = enrollments.where(target_api: params.fetch(:target_api, false)) if params.fetch(:target_api, false)

    render json: enrollments, each_serializer: PublicEnrollmentListSerializer
  end

  # POST /enrollments
  def create
    target_api = params.fetch(:enrollment, {})["target_api"]
    enrollment_class = "Enrollment::#{target_api.underscore.classify}".constantize
    @enrollment = enrollment_class.new

    authorize @enrollment

    @enrollment.assign_attributes(permitted_attributes(@enrollment))
    @enrollment.user = current_user

    if @enrollment.save
      @enrollment.events.create(name: "created", user_id: current_user.id)

      EnrollmentMailer.with(
        to: current_user.email,
        target_api: @enrollment.target_api,
        enrollment_id: @enrollment.id,
        template: "create_application"
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
      @enrollment.events.create(name: "updated", user_id: current_user.id, diff: @enrollment.previous_changes)
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
        message: ["event not permitted"],
      }
    end
    authorize @enrollment, "#{event}?".to_sym

    # We update userinfo when "event" is "send_application"
    # This is convenient when a user submit a new enrollment while is email is not validated:
    # 1. the user submits the enrollment
    # 2. he gets the error "you must validate your email before submitting"
    # 3. he clicks on the validation link
    # 4. since his profile is reloaded here, he can now submit his enrollment
    #   without logging in and out again
    #
    # Note that the functional usefulness of this feature is still to prove, plus, there is
    # to much code for this, and dangerous one, like putting an accesstoken in a clientside
    # sessions. We may prefer to force email validation when the user register.
    if event == "send_application" && !@enrollment.user.email_verified
      # This is a defensive programming test because we must not update an user illegitimately
      if current_user.email == @enrollment.user.email
        begin
          @enrollment.user.email_verified = RefreshUser.call(session[:access_token]).email_verified
        rescue => e
          # If there is an error, we assume that the access token as expired
          # we force the logout so the token can be refreshed.
          # NB: if the error is something else, the user will keep clicking on "soumettre"
          # without any effect. We log this in case some user get stuck into this
          session.delete("access_token")
          session.delete("id_token")
          session.delete("user_organizations")
          sign_out current_user
          puts "#{e.message.inspect} e.message"
          raise ApplicationController::AccessDenied, e.message
        end
      end
    end

    if @enrollment.send(event.to_sym, user_id: current_user.id, comment: params[:comment])
      EnrollmentMailer.with(
        to: @enrollment.user.email,
        target_api: @enrollment.target_api,
        enrollment_id: @enrollment.id,
        template: event,
        message: params[:comment]
      ).notification_email.deliver_later

      if event == "send_application"
        EnrollmentMailer.with(
          to: @enrollment.admins.map(&:email),
          target_api: @enrollment.target_api,
          enrollment_id: @enrollment.id,
          template: "notify_application_sent",
          applicant_email: current_user.email
        ).notification_email.deliver_later
      end
      if event == "validate_application" && @enrollment.responsable_traitement.present?
        EnrollmentMailer.with(
          to: @enrollment.responsable_traitement.email,
          target_api: @enrollment.target_api,
          enrollment_id: @enrollment.id,
          template: "notify_application_validated",
          rgpd_role: "responsable de traitement",
        ).notification_email.deliver_later
      end
      if event == "validate_application" && @enrollment.dpo.present?
        EnrollmentMailer.with(
          to: @enrollment.dpo.email,
          target_api: @enrollment.target_api,
          enrollment_id: @enrollment.id,
          template: "notify_application_validated",
          rgpd_role: "délégué à la protection des données",
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

  def pundit_params_for(_record)
    params.fetch(:enrollment, {})
  end
end
