# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrollmentsController, type: :controller do
  let(:uid) { 1 }
  let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'dgfip', email: 'test@test.test') }
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
      to_return(status: 200, body: '{"user":{"email":"test@test.test","uid":1}}', headers: { 'Content-Type' => 'application/json' })
  end

  let(:enrollment) { FactoryGirl.create(:enrollment) }

  let(:valid_attributes) do
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
            "fournisseur_de_service": "test",
            "description_service": "test",
            "fondement_juridique": "test",
            "scope_dgfip_avis_imposition": true,
            "scope_cnaf_attestation_droits": true,
            "scope_cnaf_quotient_familial": true,
            "nombre_demandes_annuelle": 34568,
            "pic_demandes_par_heure": 567,
            "nombre_demandes_mensuelles_jan": 45,
            "nombre_demandes_mensuelles_fev": 45,
            "nombre_demandes_mensuelles_mar": 45,
            "nombre_demandes_mensuelles_avr": 45,
            "nombre_demandes_mensuelles_mai": 45,
            "nombre_demandes_mensuelles_jui": 45,
            "nombre_demandes_mensuelles_jul": 45,
            "nombre_demandes_mensuelles_aou": 45,
            "nombre_demandes_mensuelles_sep": 45,
            "nombre_demandes_mensuelles_oct": 45,
            "nombre_demandes_mensuelles_nov": 45,
            "nombre_demandes_mensuelles_dec": 45,
            "autorite_certification_nom": "test",
            "ips_de_production": "test",
            "recette_fonctionnelle": true,
            "autorite_certification_fonction": "test",
            "date_homologation": "2018-06-01",
            "date_fin_homologation": "2019-06-01",
            "delegue_protection_donnees": "test",
            "validation_de_convention": true,
            "certificat_pub_production": "test",
            "autorite_certification": "test"
          }
            EOF
          )
        end

        it "creates an enrollment with all data" do
          user
          post :create, params: { enrollment: schema_attributes }

          enrollment = Enrollment.last
          enrollment_attributes = enrollment.as_json
          enrollment_attributes.delete('created_at')
          enrollment_attributes.delete('updated_at')
          enrollment_attributes.delete('id')
          schema_attributes['state'] = 'pending'
          schema_attributes['date_fin_homologation'] = Date.parse(schema_attributes['date_fin_homologation'])
          schema_attributes['date_homologation'] = Date.parse(schema_attributes['date_homologation'])

          expect(enrollment_attributes).to eq(schema_attributes)
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { scope_dgfip_avis_imposition: true }
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
          end

          it 'updates the requested enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: new_attributes }

            enrollment.reload
            expect(enrollment.scope_dgfip_avis_imposition).to be_truthy
          end

          it 'renders a JSON response with the enrollment' do
            put :update, params: { id: enrollment.to_param, enrollment: valid_attributes }

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
              res['date_fin_homologation'] = Date.parse(res['date_fin_homologation'])
              res['date_homologation'] = Date.parse(res['date_homologation'])
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
            it 'triggers an event' do
              patch :trigger, params: { id: enrollment.id, event: 'send_application' }

              expect(response).to have_http_status(:unprocessable_entity)
            end
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
