require 'rails_helper'

RSpec.describe Scope, type: :model do
  let(:resource_provider) { create(:resource_provider) }
  let(:scope) { build(:scope) }

  it 'validates service schema' do
    scope.services = ['boom']

    scope.save

    expect(scope.persisted?).to be_falsey
  end

  it 'saves with the good schema' do
    scope.services = [{
      name: 'test',
      url: 'http://test.test'
    }]

    scope.save

    expect(scope.persisted?).to be_truthy
  end
end
