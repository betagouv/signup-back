require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:message) { FactoryGirl.create(:message) }

  it 'should have an enrollment' do
    expect(message.enrollment).to be_present
  end

  it 'should have an user' do
    expect(message.user).to be_present
  end

  it 'should not save with no content' do
    expect { FactoryGirl.create(:message, content: '') }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
