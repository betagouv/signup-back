RSpec.describe Enrollment, type: :model do
  it 'has valid factories' do
    expect(build(:enrollment, :franceconnect)).to be_valid
    expect(build(:enrollment, :franceconnect, :sent)).to be_valid
  end
end
