# frozen_string_literal: true

RSpec.describe User, type: :model do
  it 'has valid factory' do
    expect(build(:user)).to be_valid
    expect(build(:user, :with_all_infos)).to be_valid
  end
end
