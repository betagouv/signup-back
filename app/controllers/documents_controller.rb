class DocumentsController < ApplicationController
  before_action :authenticate!

  def show
    @document = Document.find(params[:id])
    authorize @document, :show?
    send_file(
      Rails
        .root.join('public/uploads')
        .join(params[:model]).join(params[:type])
        .join(params[:mounted_as]).join(params[:id]).join(params[:filename])
    )
  end
end
