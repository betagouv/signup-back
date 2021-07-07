RSpec.describe Enrollment, type: :model do
  it "has valid factories" do
    %i[
      franceconnect
      api_entreprise
      api_particulier
    ].each do |target_api_trait|
      expect(build(:enrollment, target_api_trait)).to be_valid
      expect(build(:enrollment, target_api_trait, :sent)).to be_valid
      expect(build(:enrollment, target_api_trait, :validated)).to be_valid

      begin
        create(:enrollment, target_api_trait, :sent)
      rescue ActiveRecord::RecordInvalid
        RSpec::Expectations.fail_with("#{target_api_trait} is not a valid trait factory for sent status")
      end
    end
  end
end
