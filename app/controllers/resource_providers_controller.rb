class ResourceProvidersController < ApplicationController
  before_action :set_resource_provider, only: [:show]

  # GET /resource_providers
  def index
    @resource_providers = ResourceProvider.all
    render json: @resource_providers
  end

  # GET /resource_providers/1
  def show
    render json: @resource_provider
  end

  private

    def set_resource_provider
      @resource_provider = ResourceProvider.find(params[:id])
    end
end
