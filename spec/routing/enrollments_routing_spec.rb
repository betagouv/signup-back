# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnrollmentsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/enrollments').to route_to('enrollments#index')
    end

    it 'routes to #show' do
      expect(get: '/api/enrollments/1').to route_to('enrollments#show', id: '1')
    end

    it 'routes to #convention' do
      expect(get: '/api/enrollments/1/convention').to route_to('enrollments#convention', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/enrollments').to route_to('enrollments#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/enrollments/1').to route_to('enrollments#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/enrollments/1').to route_to('enrollments#update', id: '1')
    end

    it 'routes to #trigger via PATCH' do
      expect(patch: '/api/enrollments/1/trigger').to route_to('enrollments#trigger', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/enrollments/1').to route_to('enrollments#destroy', id: '1')
    end
  end
end
