# frozen_string_literal: true

class DocumentsController < ApplicationController
  class BadDocument < StandardError; end
  before_action :authenticate!

  def show
    @document = Document.find(params[:id])
    authorize @document, :show?
    send_file(
      document_path
    )
  end

  def document_path # rubocop:disable Metrics/AbcSize
    res = Rails
      .root
      .join('public/uploads')
      .join(params[:model]).join(params[:type])
      .join(params[:mounted_as])
      .join(params[:id])
      .join("#{params[:filename]}.#{params[:format]}")

    raise BadDocument unless res.to_s == @document.attachment.current_path
    res
  end

  rescue_from BadDocument do |e|
    render json: { message: 'document url do not match stored path' }, status: :forbidden
  end
end
