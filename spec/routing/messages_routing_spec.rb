# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessagesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/enrollments/1/messages').to route_to('messages#index', enrollment_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/api/enrollments/1/messages/new').to route_to('messages#new', enrollment_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/api/enrollments/1/messages/1').to route_to('messages#show', id: '1', enrollment_id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/api/enrollments/1/messages/1/edit').to route_to('messages#edit', id: '1', enrollment_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/enrollments/1/messages').to route_to('messages#create', enrollment_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/enrollments/1/messages/1').to route_to('messages#update', id: '1', enrollment_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/enrollments/1/messages/1').to route_to('messages#update', id: '1', enrollment_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/enrollments/1/messages/1').to route_to('messages#destroy', id: '1', enrollment_id: '1')
    end
  end
end
