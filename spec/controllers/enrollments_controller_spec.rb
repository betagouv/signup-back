# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid) }
  before do
    user
    @request.headers['Authorization'] = 'Bearer test'
    @request.headers['X-Oauth-Provider'] = 'franceConnect'
    stub_request(:get, 'http://test.host/api/v1/me')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer test',
          'User-Agent' => 'Faraday v0.12.1'
        }
      ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://partenaires.dev.dev-franceconnect.fr/oauth/v1/userinfo").
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer test', 'User-Agent'=>'Faraday v0.12.1'}).
        to_return(status: 200, body: '{"user":{"email":"test@test.test","uid":1}}', headers: { 'Content-Type' => 'application/json' })
  end

  let(:enrollment) { FactoryGirl.create(:enrollment) }

  let(:valid_attributes) do
    enrollment.attributes
  end

  let(:invalid_attributes) do
    { agreement: false }
  end

  describe 'authentication' do
    it 'redirect to users/access_denied if oauth request fails' do
      stub_request(:get, "https://partenaires.dev.dev-franceconnect.fr/oauth/v1/userinfo").
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer test', 'User-Agent'=>'Faraday v0.12.1'}).
        to_return(status: 401, body: 'error', headers: {})

      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: enrollment.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
        @request.headers['Authorization'] = 'Bearer test'
        stub_request(:get, 'http://test.host/api/v1/me')
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer test',
              'User-Agent' => 'Faraday v0.12.1'
            }
          ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
      end

      describe 'user is applicant of enrollment' do
        before do
          user.add_role(:applicant, enrollment)
        end

        it 'returns a success response' do
          get :show, params: { id: enrollment.to_param }

          expect(response).to be_success
        end
      end

      describe 'user is not applicant of enrollment' do
        it 'returns a success response' do
          get :show, params: { id: enrollment.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'GET #convention' do
    it 'returns a success response' do
      get :convention, params: { id: enrollment.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
        @request.headers['Authorization'] = 'Bearer test'
        stub_request(:get, 'http://test.host/api/v1/me')
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer test',
              'User-Agent' => 'Faraday v0.12.1'
            }
          ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
      end

      describe 'user is applicant of enrollment' do
        before do
          user.add_role(:applicant, enrollment)
        end

        it 'returns a success response if enrollment can be signed' do
          enrollment.update(state: 'application_approved')
          get :convention, params: { id: enrollment.to_param, format: :pdf }

          expect(response).to be_success
        end
      end

      describe 'user is not applicant of enrollment' do
        it 'returns a success response' do
          get :convention, params: { id: enrollment.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'forbids enrollment creation' do
        post :create, params: { enrollment: valid_attributes }

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
        user
        @request.headers['Authorization'] = 'Bearer test'
        stub_request(:get, 'http://test.host/api/v1/me')
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer test',
              'User-Agent' => 'Faraday v0.12.1'
            }
          ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
      end

      context 'with valid params' do
        it 'creates a new Enrollment' do
          valid_attributes
          expect do
            post :create, params: { enrollment: valid_attributes }
          end.to change(Enrollment, :count).by(1)
        end

        it 'renders a JSON response with the new enrollment' do
          post :create, params: { enrollment: valid_attributes }

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
          expect(response.location).to eq(enrollment_url(Enrollment.last))
        end

        it 'user id applicant of enrollment' do
          post :create, params: { enrollment: valid_attributes }

          expect(user.has_role?(:applicant, Enrollment.last)).to be_truthy
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new enrollment' do
          post :create, params: { enrollment: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { scopes: { tax_adress: true } }
      end

      let(:documents_attributes) do
        [{
          type: 'Document::LegalBasis',
          attachment: fixture_file_upload(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        }]
      end

      after do
        DocumentUploader.new(Document, :attachment).remove!
      end

      it 'renders a not found' do
        put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

        enrollment.reload
        expect(response).to have_http_status(:not_found)
      end

      describe 'with a france_connect user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

        before do
          @request.headers['Authorization'] = 'Bearer test'
          stub_request(:get, 'http://test.host/api/v1/me')
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Bearer test',
                'User-Agent' => 'Faraday v0.12.1'
              }
            ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
        end

        describe 'user is not applicant of enrollment' do
          it 'renders a not found' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            enrollment.reload
            expect(response).to have_http_status(:not_found)
          end
        end

        describe 'user is applicant of enrollment' do
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'updates the requested enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            enrollment.reload
            expect(enrollment.scopes['tax_adress']).to be_truthy
          end

          it 'renders a JSON response with the enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: valid_attributes }

            expect(response).to have_http_status(:ok)
            expect(response.content_type).to eq('application/json')
          end

          it 'creates an attached legal basis' do
            expect do
              put :update, params: {
                id: enrollment.to_param,
                enrollment: { documents_attributes: documents_attributes }
              }
            end.to(change { enrollment.documents.count })
          end
        end
      end
    end
  end

  describe 'PATCH #trigger' do
    # TODO test other events
    describe 'complete_application?' do
      describe 'with a france_connect user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

        before do
          @request.headers['Authorization'] = 'Bearer test'
          stub_request(:get, 'http://test.host/api/v1/me')
            .with(
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization' => 'Bearer test',
                'User-Agent' => 'Faraday v0.12.1'
              }
            ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
        end

        describe 'user is applicant of enrollment' do
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'throw a 400 if not an event' do
            patch :trigger, params: { id: enrollment.id, event: 'boom' }

            expect(response).to have_http_status(400)
          end

          describe 'enrollment can be completed' do
            before do
              Enrollment::DOCUMENT_TYPES.each do |document_type|
                enrollment.documents.create(
                  type: document_type,
                  attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
                )
              end
              enrollment.update(cnil_voucher_detail: {
                reference: 'test',
                formality: 'test'
              })
              enrollment.update(certification_results_detail: {
                name: 'test',
                position: 'test',
                start: 'test',
                duration: 'test'
              })
            end

            it 'triggers an event' do
              patch :trigger, params: { id: enrollment.id, event: 'complete_application' }

              expect(enrollment.reload.state).to eq('waiting_for_approval')
            end

            it 'returns the enrollment' do
              patch :trigger, params: { id: enrollment.id, event: 'complete_application' }

              res = JSON.parse(response.body)
              res.delete('updated_at')
              res.delete('created_at')
              res.delete('state')
              res.delete('messages')
              res.delete('documents')
              res.delete('acl')

              exp = @controller.serialize(enrollment)
              exp.delete('updated_at')
              exp.delete('created_at')
              exp.delete('state')
              exp.delete('messages')
              exp.delete('documents')
              exp.delete('acl')

              expect(res).to eq(exp)
            end

            it 'user has application completer role' do
              patch :trigger, params: { id: enrollment.id, event: 'complete_application' }

              expect(user.has_role?(:application_completer, enrollment)).to be_truthy
            end
          end

          describe 'enrollment cannot be completed' do
            it 'triggers an event' do
              patch :trigger, params: { id: enrollment.id, event: 'complete_application' }

              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end
      end

      describe 'with a dgfip user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'resource_provider', uid: uid) }

        before do
          @request.headers['Authorization'] = 'Bearer test'
          @request.headers['X-Oauth-Provider'] = 'resourceProvider'
          stub_request(:get, 'http://test.host/api/v1/me')
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer test',
              'User-Agent' => 'Faraday v0.12.1'
            }
          ).to_return(status: 200, body: "{\"uid\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
        end

        it 'is unauthorized' do
          patch :trigger, params: { id: enrollment.id, event: 'complete_application' }

          expect(response).to have_http_status(403)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'renders a not found' do
      enrollment

      delete :destroy, params: { id: enrollment.to_param }

      expect(response).to have_http_status(:not_found)
    end

    describe 'with a france_connect user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

      before do
        @request.headers['Authorization'] = 'Bearer test'
        stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.1'
          }
        ).to_return(status: 200, body: "{\"id\": #{uid}}", headers: { 'Content-Type' => 'application/json' })
      end

      describe 'user is not applicant of enrollment' do
        it 'renders a not found' do
          enrollment

          delete :destroy, params: { id: enrollment.to_param }

          expect(response).to have_http_status(:not_found)
        end
      end

      describe 'user is applicant of enrollment' do
        before do
          user.add_role(:applicant, enrollment)
        end

        it 'destroys the requested enrollment' do
          enrollment

          expect do
            delete :destroy, params: { id: enrollment.to_param }
          end.to change(Enrollment, :count).by(-1)
        end
      end
    end
  end
end
