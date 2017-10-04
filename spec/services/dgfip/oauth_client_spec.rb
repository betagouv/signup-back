# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dgfip::OauthClient do
  let(:client) { described_class.new }
  let(:token) { 'test' }

  before do
    described_class::OMNIAUTH_CONFIG = {
      'client_options' => {
        'site' => 'http://test.host',
        'me_url' => '/api/v1/me'
      }
    }.freeze
  end

  it 'requests me according to configuration' do
    stub_request(:get, 'http://test.host/api/v1/me')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Bearer #{token}",
          'User-Agent' => 'Faraday v0.12.1'
        }
      ).to_return(status: 200, body: '', headers: {})

    expect(client.me(token)).to be_success
  end

  it 'raises an Dgfip::AccessDenied if fails' do
    stub_request(:get, 'http://test.host/api/v1/me')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => "Bearer #{token}",
          'User-Agent' => 'Faraday v0.12.1'
        }
      ).to_return(status: 401, body: '', headers: {})

    expect do
      client.me(token)
    end.to raise_error(Dgfip::AccessDenied)
  end
end
