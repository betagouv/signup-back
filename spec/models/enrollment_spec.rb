RSpec.describe Enrollment, type: :model do
  it "has valid factories" do
    %i[
      franceconnect
      api_entreprise
    ].each do |target_api_trait|
      expect(build(:enrollment, target_api_trait)).to be_valid
      expect(build(:enrollment, target_api_trait, :sent)).to be_valid
      expect(build(:enrollment, target_api_trait, :validated)).to be_valid
    end
  end
end
