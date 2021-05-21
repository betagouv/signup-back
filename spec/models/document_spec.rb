RSpec.describe Document, type: :model do
  it "has valid factories" do
    expect(build(:document)).to be_valid
  end
end
