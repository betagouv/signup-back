# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe 'with fc user' do
    let(:uid) { 1 }
    let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'france_connect') }
    let(:enrollment) { FactoryGirl.create(:enrollment) }
    before do
      user.add_role(:applicant, enrollment)
      @request.headers['Authorization'] = 'Bearer test'
      stub_request(:get, 'http://test.host/api/v1/me')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer test',
            'User-Agent' => 'Faraday v0.12.1'
          }
        ).to_return(status: 200, body: "{\"uid\": #{uid}}", headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://partenaires.dev.dev-franceconnect.fr/oauth/v1/userinfo").
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer test', 'User-Agent'=>'Faraday v0.12.1'}).
          to_return(status: 200, body: '{"user":{"email":"test@test.test","uid":1}}', headers: { 'Content-Type' => 'application/json' })
    end

    let(:message) { FactoryGirl.create(:message, enrollment: enrollment) }
    let(:valid_attributes) do
      { content: 'test' }
    end

    let(:invalid_attributes) do
      { content: '' }
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index, params: { enrollment_id: enrollment.id }
        expect(response).to be_success
      end
    end

    describe 'GET #show' do
      describe 'the user owns the message' do
        it 'returns a success response' do
          get :show, params: { id: message.to_param, enrollment_id: enrollment.id }
          expect(response).to be_success
        end
      end

      describe 'the user do not own the message' do
        let(:message) { FactoryGirl.create(:message) }
        it 'returns an error' do
          get :show, params: { id: message.to_param, enrollment_id: enrollment.id }
          expect(response).not_to be_success
        end
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Message' do
          expect do
            post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          end.to change(Message, :count).by(1)
        end

        it 'is a success' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(response).to be_success
        end

        it 'current user own the message' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(Message.last.sender).to eq(user)
        end

        it 'the message is linked to enrollment' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(Message.last.enrollment).to eq(enrollment)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { message: invalid_attributes, enrollment_id: enrollment.id }
          expect(response).not_to be_success
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested message' do
        message
        expect do
          delete :destroy, params: { id: message.to_param, enrollment_id: enrollment.id }
        end.to change(Message, :count).by(-1)
      end

      it 'is a success' do
        delete :destroy, params: { id: message.to_param, enrollment_id: enrollment.id }
        expect(response).to be_success
      end
    end
  end

  describe 'with dgfip user' do
    let(:uid) { 1 }
    let(:user) { FactoryGirl.create(:user, uid: uid, provider: 'resource_provider') }
    let(:enrollment) { FactoryGirl.create(:enrollment) }
    before do
      user.add_role(:applicant, enrollment)
      @request.headers['Authorization'] = 'Bearer test'
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

    let(:message) { FactoryGirl.create(:message, enrollment: enrollment) }
    let(:valid_attributes) do
      { content: 'test' }
    end

    let(:invalid_attributes) do
      { content: '' }
    end

    describe 'GET #index' do
      it 'returns a success response' do
        get :index, params: { enrollment_id: enrollment.id }
        expect(response).to be_success
      end
    end

    describe 'GET #show' do
      describe 'the user owns the message' do
        it 'returns a success response' do
          get :show, params: { id: message.to_param, enrollment_id: enrollment.id }
          expect(response).to be_success
        end
      end

      describe 'the user do not own the message' do
        let(:message) { FactoryGirl.create(:message, enrollment: enrollment) }
        it 'returns an error' do
          get :show, params: { id: message.to_param, enrollment_id: enrollment.id }
          expect(response).to be_success
        end
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Message' do
          expect do
            post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          end.to change(Message, :count).by(1)
        end

        it 'is a success' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(response).to be_success
        end

        it 'current user own the message' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(Message.last.sender).to eq(user)
        end

        it 'the message is linked to enrollment' do
          post :create, params: { message: valid_attributes, enrollment_id: enrollment.id }
          expect(Message.last.enrollment).to eq(enrollment)
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { message: invalid_attributes, enrollment_id: enrollment.id }
          expect(response).not_to be_success
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested message' do
        message
        expect do
          delete :destroy, params: { id: message.to_param, enrollment_id: enrollment.id }
        end.to change(Message, :count).by(-1)
      end

      it 'is a success' do
        delete :destroy, params: { id: message.to_param, enrollment_id: enrollment.id }
        expect(response).to be_success
      end
    end
  end
end
