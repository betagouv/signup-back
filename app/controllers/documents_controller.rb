# frozen_string_literal: true

class DocumentsController < ApplicationController
  class BadDocument < StandardError; end
  acts_as_token_authentication_handler_for User

  def show
    @document = Document.find(params[:id])
    authorize @document, :show?
    send_file(
      @document.attachment.current_path
    )
  end
end
