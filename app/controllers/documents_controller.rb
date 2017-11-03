# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :authenticate!

  def show
    @document = Document.find(params[:id])
    authorize @document, :show?
    send_file(
      document_path
    )
  end

  def document_path # rubocop:disable Metrics/AbcSize
    Rails
      .root
      .join('public/uploads')
      .join(params[:model]).join(params[:type])
      .join(params[:mounted_as])
      .join(params[:id])
      .join("#{params[:filename]}.#{params[:format]}")
  end
end
