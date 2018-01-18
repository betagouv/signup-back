# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enrollments', type: :request do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid) }
  let(:bearer) { 'Bearer test' }
  before do
    user
    stub_request(:get, 'http://test.host/api/v1/me')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => bearer,
          'User-Agent' => 'Faraday v0.12.1'
        }
      ).to_return(status: 200, body: "{\"uid\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
  end

  describe 'GET /enrollments' do
    it 'works!' do
      get enrollments_path, headers: { 'Authorization' => bearer }
      expect(response).to have_http_status(200)
    end
  end
end
