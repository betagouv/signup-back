# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'resource_provider') }
  let(:bearer) { 'Bearer test' }
  let(:enrollment) { FactoryGirl.create(:enrollment) }
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

  describe 'GET /messages' do
    it 'works! (now write some real specs)' do
      get enrollment_messages_path(enrollment_id: enrollment.id), headers: { 'Authorization' => bearer, 'X-Oauth-Provider' => 'resourceProvider' }
      expect(response).to have_http_status(200)
    end
  end
end
