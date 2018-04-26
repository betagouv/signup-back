class Enrollment::DgfipsController < EnrollmentsController
  private

  def enrollments_scope
    Enrollment::DgfipPolicy::Scope.new(current_user, Enrollment::Dgfip).resolve
  end

  def enrollment_params
    params.fetch(:enrollment, {}).permit(*policy(@enrollment || Enrollment::Dgfip.new).permitted_attributes)
  end

  def event_param
    event = params[:event]
    raise EventNotPermitted unless Enrollment::Dgfip.state_machine.events.map(&:name).include?(event.to_sym)
    event
  end
end
