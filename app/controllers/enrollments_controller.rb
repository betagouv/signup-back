# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  before_action :authenticate!
  before_action :set_enrollment, only: %i[show convention update trigger destroy]

  # GET /enrollments
  def index
    @enrollments = enrollments_scope

    render json: @enrollments.map { |e| serialize(e) }
  end

  # GET /enrollments/1
  def show
    render json: serialize(@enrollment)
  end

  # GET /enrollments/1/convention
  def convention
    authorize @enrollment, :convention?
    @filename = 'convention.pdf'
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
    @enrollment.attributes = enrollment_params
    authorize @enrollment, :update?
    if @enrollment.save
      render json: serialize(@enrollment)
    else
      render json: @enrollment.errors, status: :unprocessable_entity
    end
  end


  # PATCH /enrollment/1/trigge
  def trigger
    authorize @enrollment, "#{event_param}?".to_sym

    if @enrollment.update(enrollment_params) && @enrollment.send(event_param.to_sym)
      current_user.add_role(event_param.as_event_personified.to_sym, @enrollment)
      render json: serialize(@enrollment)
    else
      render status: :unprocessable_entity, json: @enrollment.errors
    end
  end

  # DELETE /enrollments/1
  def destroy
    authorize @enrollment, :delete?
    @enrollment.destroy
  end

  def serialize(enrollment)
    enrollment.as_json(
      include: [{ documents: { methods: :type } }, { messages: { include: :sender } }],
      methods: [:applicant]
    ).merge('acl' => Hash[
      EnrollmentPolicy.acl_methods.map do |method|
        [method.to_s.delete('?'), EnrollmentPolicy.new(current_user, enrollment).send(method)]
      end
    ])
  end

  private

  def set_enrollment
    @enrollment = enrollments_scope.find(params[:id])
  end

  def enrollments_scope
    EnrollmentPolicy::Scope.new(current_user, Enrollment).resolve
  end

  def enrollment_params
    params.fetch(:enrollment, {}).permit(
      :validation_de_convention,
      :fournisseur_de_service,
      :description_service,
      :fondement_juridique,
      :scope_dgfip_avis_imposition,
      :scope_cnaf_attestation_droits,
      :scope_cnaf_quotient_familial,
      :nombre_demandes_annuelle,
      :pic_demandes_par_heure,
      :nombre_demandes_mensuelles_jan,
      :nombre_demandes_mensuelles_fev,
      :nombre_demandes_mensuelles_mar,
      :nombre_demandes_mensuelles_avr,
      :nombre_demandes_mensuelles_mai,
      :nombre_demandes_mensuelles_jui,
      :nombre_demandes_mensuelles_jul,
      :nombre_demandes_mensuelles_aou,
      :nombre_demandes_mensuelles_sep,
      :nombre_demandes_mensuelles_oct,
      :nombre_demandes_mensuelles_nov,
      :nombre_demandes_mensuelles_dec,
      :autorite_certification_nom,
      :autorite_certification_fonction,
      :date_homologation,
      :date_fin_homologation,
      :delegue_protection_donnees,
      :validation_de_convention,
      :certificat_pub_production,
      :autorite_certification,
      :ips_de_production
    )
  end

  def event_param
    event = params[:event]
    raise EventNotPermitted unless Enrollment.state_machine.events.map(&:name).include?(event.to_sym)
    event
  end

  class EventNotPermitted < StandardError; end

  rescue_from EventNotPermitted do
    render status: :bad_request, json: {
      message: ['event not permitted']
    }
  end
end
