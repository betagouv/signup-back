require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'with an user' do
    let(:user) { FactoryGirl.create(:user) }

    describe 'with an enrollment' do
      let(:enrollment) { FactoryGirl.create(:enrollment) }

      it 'can have messages' do
        expect do
          user.messages.create(enrollment: enrollment, content: 'test')
        end.to change { user.messages.count}
      end

      it 'user can be applicant to an enrollment' do
        user.add_role(:applicant, enrollment)

        expect(user.has_role?(:applicant, enrollment)).to be_truthy
      end
    end
  end
end
