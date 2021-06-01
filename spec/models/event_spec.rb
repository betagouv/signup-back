RSpec.describe Event, type: :model do
  it "has valid factory" do
    expect(build(:event)).to be_valid

    %i[
      created
      updated
      validated
      refused
      asked_for_modification
    ].each do |trait|
      expect(build(:event, trait)).to be_valid
    end
  end
end
