RSpec.describe EnrollmentsController, "#create", type: :controller do
  subject(:create_enrollment) do
    post :create, params: {
      enrollment: enrollment_attributes
    }
  end

  let(:user) { create(:user, :with_all_infos) }
  let(:organization_id) { user.organizations[0]["id"] }
  let(:organization_siret) { user.organizations[0]["siret"] }

  before do
    login(user)

    stub_entreprise_data_etablissement_call(organization_siret)
  end

  context "with valid enrollment attributes" do
    let(:enrollment_attributes) { attributes_for(:enrollment, target_api: "franceconnect", organization_id: organization_id) }

    it { is_expected.to have_http_status(:ok) }

    it "creates an enrollment associated to current user, with valid attributes" do
      expect {
        create_enrollment
      }.to change { user.enrollments.count }.by(1)

      latest_user_enrollment = user.enrollments.last

      expect(latest_user_enrollment.intitule).to eq(enrollment_attributes[:intitule])
      expect(latest_user_enrollment.target_api).to eq("franceconnect")
    end

    it "creates an event 'created' associated to this enrollment and user" do
      expect {
        create_enrollment
      }.to change { user.events.count }.by(1)

      latest_user_event = user.events.last
      latest_user_enrollment = user.enrollments.last

      expect(latest_user_event.name).to eq("created")
      expect(latest_user_event.enrollment).to eq(latest_user_enrollment)
    end

    describe "email sent on creation success" do
      let(:create_application_email_sample) do
        File.open(Rails.root.join("app/views/enrollment_mailer/create_application.text.erb")) { |f| f.readline }.chomp
      end

      before do
        ActiveJob::Base.queue_adapter = :inline
      end

      after do
        ActiveJob::Base.queue_adapter = :test
      end

      it "delivers a return receipt email to current user" do
        expect {
          create_enrollment
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

        last_email = ActionMailer::Base.deliveries.last

        expect(last_email.to).to eq([user.email])
        expect(last_email.body).to include(create_application_email_sample)
      end
    end
  end

  context "with invalid target api" do
    let(:enrollment_attributes) { attributes_for(:enrollment, target_api: "does_not_exist") }

    it { is_expected.to have_http_status(:unprocessable_entity) }
  end
end
