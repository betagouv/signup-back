RSpec.describe WebhookEnrollmentSerializer, type: :serializer do
  subject(:payload) { described_class.new(enrollment).serializable_hash }

  let(:enrollment) { create(:enrollment, :franceconnect, :complete) }

  let!(:created_event) { create(:event, :created, enrollment: enrollment, created_at: 3.hours.ago) }
  let!(:refused_event) { create(:event, :refused, enrollment: enrollment, created_at: 2.hours.ago) }
  let!(:validated_event) { create(:event, :validated, enrollment: enrollment, created_at: 1.hours.ago) }

  it "renders valid data" do
    expect(payload).to have_key(:id)

    %i[
      dpo
      responsable_traitement
      user
    ].each do |user_kind|
      expect(payload).to have_key(user_kind)

      expect(payload[user_kind]).to have_key(:family_name)
      expect(payload[user_kind]).to have_key(:email)
    end

    expect(payload[:user]).to have_key(:uid)

    expect(payload).to have_key(:events)

    expect(payload[:events][0]).to be_present
    expect(payload[:events][0]).not_to have_key(:diff)
    expect(payload[:events][0][:name]).to eq("created")

    expect(payload[:events][0][:user]).to have_key(:email)
    expect(payload[:events][0][:user]).to have_key(:family_name)

    expect(payload[:events][-1][:name]).to eq("validated")
  end
end
