# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :authenticate!
  before_action :set_enrollment
  before_action :set_message, only: %i[show update destroy]

  # GET /messages
  def index
    @messages = messages_scope.all
    res = @messages.map { |e| e.as_json(include: :user) }
    render json: res
  end

  # GET /messages/1
  def show
    render json: @message.as_json(inlcude: :user)
  end

  # POST /messages
  def create
    @message = Message.new(message_params)
    @message.user = current_user
    @message.enrollment = @enrollment

    if @message.save
      render status: :created, json: @message.to_json(inlcude: :user)
    else
      render status: :unprocessable_entity, json: @message.errors
    end
  end

  # PATCH/PUT /messages/1
  def update
    raise NotImplementedError, 'cannot update messages'
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
  end

  private

  def set_enrollment
    @enrollment = Enrollment.find(params[:enrollment_id])
  end

  def messages_scope
    MessagePolicy::Scope
      .new(current_user, Message).resolve
      .where(enrollment_id: @enrollment.id)
  end

  def set_message
    @message = messages_scope.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def message_params
    params.require(:message).permit(:enrollment_id, :content, :user_id)
  end
end
