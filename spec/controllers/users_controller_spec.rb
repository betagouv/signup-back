# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #access_denied' do
    it 'returns http success' do
      get :access_denied
      expect(response).to have_http_status(401)
    end
  end
end
