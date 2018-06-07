# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentsController do
  let(:enrollment) { create(:enrollment) }
  let(:document) { create(:document, enrollment: enrollment) }

  describe "#show" do
    it "return a 401 with a bad user" do
      get_path document.attachment.url

      expect(response).to have_http_status(:unauthorized)
    end

    describe "I have an user" do
      let(:uid) { 1 }
      let(:user) { create(:user, uid: uid, provider: 'service_provider', email: 'test@test.test') }
      before do
        user
        @request.headers['Authorization'] = 'Bearer test'
        stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.2'
          }
        ).to_return(status: 200, body: "{\"account_type\": \"#{user.provider}\", \"uid\": #{uid}, \"email\": \"#{user.email}\"}", headers: { 'Content-Type' => 'application/json' })

      end

      it "renders a 403 " do
        get_path document.attachment.url

        expect(response).to have_http_status(:forbidden)
      end

      describe "the user is applicant of associated enrollment" do
        before do
          user.add_role(:applicant, enrollment)
        end

        it "should return the document" do
          get_path document.attachment.url

          expect(response).to have_http_status(:success)
        end

        it "should reject malicious" do
          get_path "/uploads/%2Fusr/%2Fusr/%2Fusr/#{document.id}/#{Rails.root.join('app/controllers/enrollments_controller.rb').to_s.gsub('/', '%2F')}"

          expect(response).to have_http_status(:forbidden)

        end
      end
    end
  end
end

