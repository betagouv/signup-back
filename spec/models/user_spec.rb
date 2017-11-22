# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'with an user' do
    let(:user) { FactoryGirl.create(:user) }

    describe 'with an enrollment' do
      let(:enrollment) { FactoryGirl.create(:enrollment) }

      it 'can have messages sent' do
        expect do
          message = Message.create(enrollment: enrollment, content: 'test')
          user.add_role(:sender, message)
        end.to change { user.sent_messages.count }
      end

      it 'user can be applicant to an enrollment' do
        user.add_role(:applicant, enrollment)

        expect(user.has_role?(:applicant, enrollment)).to be_truthy
      end
    end
  end
end
