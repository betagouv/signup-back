class UsersController < ApplicationController
  before_action :authenticate_user!
  def index
    users_with_roles_only = params.permit(:users_with_roles_only)[:users_with_roles_only]
    @users = policy_scope(User).order :email

    if users_with_roles_only == "true"
      # get users that have at least one roles
      @users = @users.where("roles <> '{}'")
    end

    render json: @users,
           each_serializer: AdminUserSerializer,
           adapter: :json
  end

  def update
    @user = policy_scope(User).find(params[:id])
    authorize @user

    if @user.update(permitted_attributes(@user))
      render json: @user,
             serializer: AdminUserSerializer
    else
      render json: @user.errors,
             status: :unprocessable_entity
    end
  end

  def create
    @user = User.new
    @user.email = params[:email]
    @user.update_attributes(permitted_attributes(@user))
    authorize @user

    if @user.save
      render json: @user,
             serializer: AdminUserSerializer
    else
      render json: @user.errors,
             status: :unprocessable_entity
    end
  end

  def me
    user = current_user.attributes
    render json: user.as_json
  end

  def join_organization
    # we clear DataPass session here to trigger organization sync with api-auth
    session.delete("access_token")
    session.delete("id_token")
    sign_out current_user
    redirect_to "#{ENV.fetch("OAUTH_HOST")}/users/join-organization"
  end

  def personal_information
    # we clear DataPass session here to trigger organization sync with api-auth
    session.delete("access_token")
    session.delete("id_token")
    sign_out current_user
    redirect_to "#{ENV.fetch("OAUTH_HOST")}/users/personal-information"
  end

  private

  def pundit_params_for(_record)
    params.fetch(:user, {})
  end
end
