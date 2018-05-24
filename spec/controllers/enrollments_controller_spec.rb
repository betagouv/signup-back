# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'api_particulier', email: 'test@test.test') }
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

    stub_request(:get, "https://partenaires.dev.dev-franceconnect.fr/oauth/v1/userinfo").
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer test', 'User-Agent'=>'Faraday v0.12.2'}).
      to_return(status: 200, body: '{"user":{"email":"test@test.test","uid":'+uid.to_s+'}}', headers: { 'Content-Type' => 'application/json' })
  end

  let(:enrollment) { FactoryGirl.create(:enrollment) }
  let(:enrollment_dgfip) { FactoryGirl.create(:enrollment_dgfip) }

  let(:valid_attributes) do
    enrollment.attributes
  end

  let(:dgfip_valid_attributes) do
    enrollment.attributes
  end

  let(:invalid_attributes) do
    { validation_de_convention: false }
  end

  describe 'authentication' do
    it 'redirect to users/access_denied if oauth request fails' do
      stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.2'
          }
        ).to_return(status: 401, body: 'error', headers: {})

      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET #index' do
    describe "I have dgfip api_particulier and api_entreprise enrollments" do
      let(:dgfip_enrollments) { FactoryGirl.create_list(:enrollment_dgfip, 3) }
      let(:api_particulier_enrollments) { FactoryGirl.create_list(:enrollment, 4, fournisseur_de_donnees: 'api-particulier') }
      let(:api_entreprise_enrollments) { FactoryGirl.create_list(:enrollment, 5, fournisseur_de_donnees: 'api-entreprise') }

      describe "I have a dgfip user" do
        let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'dgfip', email: 'test@test.test') }

        it 'returns the dgfip enrollments' do
          dgfip_enrollments
          api_particulier_enrollments
          api_entreprise_enrollments
          get :index

          json = JSON.parse(response.body)
          expect(json.count).to eq(3)
        end
      end

      describe "I have a api_particulier user" do
        let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'api_particulier', email: 'test@test.test') }

        it 'returns api_particulier enrollments' do
          dgfip_enrollments
          api_particulier_enrollments
          api_entreprise_enrollments
          get :index

          json = JSON.parse(response.body)
          expect(json.count).to eq(4)
        end
      end

      describe "I have a api_entreprise user" do
        let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'api_entreprise', email: 'test@test.test') }

        it 'returns the api_entreprise enrollments' do
          dgfip_enrollments
          api_particulier_enrollments
          api_entreprise_enrollments
          get :index

          json = JSON.parse(response.body)
          expect(json.count).to eq(5)
        end
      end
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: enrollment.to_param }

      expect(response).to have_http_status(:success)
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
            'User-Agent' => 'Faraday v0.12.2'
          }
        ).to_return(status: 200, body: "{\"account_type\": \"#{user.provider}\", \"uid\": #{uid}, \"email\": \"#{user.email}\"}", headers: { 'Content-Type' => 'application/json' })
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

  # describe 'GET #convention' do
  #   it 'returns a success response' do
  #     get :convention, params: { id: enrollment.to_param }

  #     expect(response).to have_http_status(:not_found)
  #   end

  #   describe 'with a france_connect user' do
  #     let(:uid) { 1 }
  #     let(:user) { FactoryGirl.create(:user, provider: 'france_connect', uid: uid) }

  #     before do
  #       @request.headers['Authorization'] = 'Bearer test'
  #       stub_request(:get, 'http://test.host/api/v1/me')
  #         .with(
  #           headers: {
  #             'Accept' => '*/*',
  #             'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
  #             'Authorization' => 'Bearer test',
  #             'User-Agent' => 'Faraday v0.12.2'
  #           }
  #         ).to_return(status: 200, body: "{\"account_type\": \"#{user.provider}\", \"uid\": #{uid}, \"email\": \"#{user.email}\"}", headers: { 'Content-Type' => 'application/json' })
  #     end

  #     describe 'user is applicant of enrollment' do
  #       before do
  #         user.add_role(:applicant, enrollment)
  #       end

  #       it 'returns a success response if enrollment can be signed' do
  #         enrollment.update(state: 'application_approved')
  #         get :convention, params: { id: enrollment.to_param, format: :pdf }

  #         expect(response).to be_success
  #       end
  #     end

  #     describe 'user is not applicant of enrollment' do
  #       it 'returns a success response' do
  #         get :convention, params: { id: enrollment.to_param }

  #         expect(response).to have_http_status(:not_found)
  #       end
  #     end
  #   end
  # end

  describe 'POST #create' do
    describe 'without a service_provider user' do
      it 'forbids enrollment creation' do
        post :create, params: { enrollment: valid_attributes }

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'with a service_provider user' do
      let(:uid) { 1 }
      let(:user) { FactoryGirl.create(:user, provider: 'service_provider', uid: uid) }

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

      context 'with valid params' do
        it 'creates a new Enrollment' do
          valid_attributes
          expect do
            post :create, params: { enrollment: valid_attributes }
          end.to change(Enrollment, :count).by(1)
        end

        it 'creates a new DGFIP Enrollment' do
          dgfip_valid_attributes
          expect do
            post :create, params: { enrollment: dgfip_valid_attributes }
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

      describe 'with a valid schema' do
        let(:schema_attributes) do
          JSON.parse(
            <<-EOF
            {
              "demarche": {
              "intitule": "test"
              },
              "contacts": [{"nom": "test"}],
              "scopes": {"dgfip_avis_imposition": "true"},
              "siren": "12345",
              "donnees": {"conservation": "12", "destinataires": {}},
              "fournisseur_de_donnees": "api-particulier",
              "validation_de_convention": true
            }
            EOF
          )
        end

        it "creates an enrollment with good schema" do
          user
          post :create, params: { enrollment: schema_attributes }
          enrollment = Enrollment.last
          enrollment_attributes = enrollment.as_json
          enrollment_attributes.delete('created_at')
          enrollment_attributes.delete('updated_at')
          enrollment_attributes.delete('id')
          enrollment_attributes.delete('applicant')
          enrollment_attributes.delete('documents')
          schema_attributes['state'] = 'pending'

          expect(enrollment_attributes).to eq(schema_attributes)
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { scopes: { dgfip_avis_imposition: true } }
      end

      let(:new_dgfip_attributes) do
        { nombre_demandes_annuelle: 36 }
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
        expect(response).to have_http_status(:forbidden)
      end

      describe 'with a service_provider user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'service_provider', uid: uid) }

        before do
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
            user.add_role(:applicant, enrollment_dgfip)
          end

          it 'updates the requested enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            enrollment.reload
            expect(enrollment.scopes['dgfip_avis_imposition']).to be_truthy
          end

          it 'updates the requested dgfip enrollment' do
            put :update, params: { id: enrollment_dgfip.to_param, enrollment: new_dgfip_attributes }

            enrollment_dgfip.reload
            expect(enrollment_dgfip.nombre_demandes_annuelle).to eq(36)
          end

          it 'updates the requested enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            enrollment.reload
            expect(enrollment.scopes['dgfip_avis_imposition']).to be_truthy
          end

          it 'renders a JSON response with the enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            expect(response).to have_http_status(:ok)
            expect(response.content_type).to eq('application/json')
          end
        end
      end
    end
  end

  describe 'PATCH #trigger' do
    # TODO test other events
    describe 'send_application?' do
      describe 'with a service_provider user' do
        let(:uid) { 1 }
        let(:user) { FactoryGirl.create(:user, provider: 'service_provider', uid: uid) }

        before do
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

        describe 'user is applicant of enrollment' do
          before do
            user.add_role(:applicant, enrollment)
          end

          it 'throw a 400 if not an event' do
            patch :trigger, params: { id: enrollment.id, event: 'boom' }

            expect(response).to have_http_status(400)
          end

          describe 'enrollment can be sent' do
            let(:enrollment) { FactoryGirl.create(:sent_enrollment, state: :pending) }

            it 'triggers an event' do
              patch :trigger, params: { id: enrollment.id, event: 'send_application' }

              expect(enrollment.reload.state).to eq('sent')
            end

            it 'returns the enrollment' do
              patch :trigger, params: { id: enrollment.id, event: 'send_application' }

              res = JSON.parse(response.body)
              res.delete('updated_at')
              res.delete('created_at')
              res.delete('state')
              res.delete('messages')
              res.delete('documents')
              res.delete('acl')
              res.delete('applicant')

              exp = @controller.serialize(enrollment)
              exp.delete('updated_at')
              exp.delete('created_at')
              exp.delete('state')
              exp.delete('messages')
              exp.delete('documents')
              exp.delete('acl')
              exp.delete('applicant')

              expect(res).to eq(exp)
            end

            it 'user has application sender role' do
              patch :trigger, params: { id: enrollment.id, event: 'send_application' }

              expect(user.has_role?(:application_sender, enrollment)).to be_truthy
            end
          end

          describe 'enrollment cannot be completed' do
            # it 'triggers an event' do
            #   patch :trigger, params: { id: enrollment.id, event: 'send_application' }

            #   expect(response).to have_http_status(:unprocessable_entity)
            # end
          end
        end
      end

      # describe 'with a dgfip user' do
      #   let(:uid) { 1 }
      #   let(:user) { FactoryGirl.create(:user, provider: 'resource_provider', uid: uid) }

      #   before do
      #     @request.headers['Authorization'] = 'Bearer test'
      #     @request.headers['X-Oauth-Provider'] = 'resourceProvider'
      #     stub_request(:get, 'http://test.host/api/v1/me')
      #     .with(
      #       headers: {
      #         'Accept' => '*/*',
      #         'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      #         'Authorization' => 'Bearer test',
      #         'User-Agent' => 'Faraday v0.12.2'
      #       }
      #     ).to_return(status: 200, body: "{\"account_type\": \"#{user.provider}\", \"uid\": #{uid}, \"email\": \"#{user.email}\"}", headers: { 'Content-Type' => 'application/json' })
      #   end

      #   it 'is unauthorized' do
      #     patch :trigger, params: { id: enrollment.id, event: 'send_application' }

      #     expect(response).to have_http_status(403)
      #   end
      # end
    end
  end

  describe 'DELETE #destroy' do
    it 'renders a not found' do
      enrollment

      delete :destroy, params: { id: enrollment.to_param }

      expect(response).to have_http_status(:forbidden)
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
            'User-Agent' => 'Faraday v0.12.2'
          }
        ).to_return(status: 200, body: "{\"account_type\": \"#{user.provider}\", \"uid\": #{uid}, \"email\": \"#{user.email}\"}", headers: { 'Content-Type' => 'application/json' })
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
