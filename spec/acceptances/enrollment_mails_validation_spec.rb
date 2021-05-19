RSpec.describe "Enrollments mails validation", type: :acceptance do
  let(:instructor) { create(:user) }

  describe "for each target api" do
    it "does have valid templates for review, refuse and validate" do
      ProvidersConfiguration.instance.send(:config_backend).each do |target_api, _|
        next if target_api == "shared"

        expect {
          EnrollmentEmailTemplatesRetriever.new(
            build(:enrollment, target_api: target_api),
            instructor
          ).perform
        }.not_to raise_error
      end
    end
  end
end
