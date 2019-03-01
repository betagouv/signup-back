# frozen_string_literal: true

class DocumentsController < ApplicationController
  class BadDocument < StandardError; end
  before_action :authenticate!

  def show
    @document = Document.find(params[:id])
    authorize @document, :show?
    send_file(
      @document.attachment.current_path
    )
  end
end
