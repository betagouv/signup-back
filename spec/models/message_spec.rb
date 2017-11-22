# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:message) { FactoryGirl.create(:message) }

  it 'should have an enrollment' do
    expect(message.enrollment).to be_present
  end

  it 'should not save with no content' do
    expect { FactoryGirl.create(:message, content: '') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe "an user send the message" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      user.add_role(:sender, message)
    end

    it 'should have a sender' do
      expect(message.sender).to be_present
    end
  end
end
