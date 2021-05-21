# frozen_string_literal: true

RSpec.describe EnrollmentsController, "review", type: :controller do
  subject(:review_application) do
    patch :trigger, params: {
      id: enrollment.id,
      event: "review_application",
      comment: comment,
      commentFullEditMode: comment_full_edit_mode
    }.compact
  end

  let(:instructor) { create(:user, roles: ["franceconnect:instructor", "franceconnect:reporter"]) }
  let(:enrollment) { create(:enrollment, :sent, :franceconnect) }

  let(:comment) { "Votre application n'est pas valide" }

  before do
    login(instructor)

    ActiveJob::Base.queue_adapter = :inline
  end

  after do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "when admin sends only a comment" do
    let(:comment_full_edit_mode) { nil }

    let(:template_sample) do
      File.open(Rails.root.join("app/views/layouts/enrollment_mailer.text.erb")) { |f| f.readline }.chomp
    end

    let(:template_footer_sample) { "FranceConnect" }

    it { expect(response).to have_http_status(:ok) }

    it "sends an email to enrollment's user with comment only as body" do
      expect {
        review_application
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      last_mail = ActionMailer::Base.deliveries.last

      expect(last_mail.body).to eq(comment)
    end
  end

  context "when admin sends a comment in full edit mode" do
    let(:comment_full_edit_mode) { true }

    it { expect(response).to have_http_status(:ok) }

    it "sends an email to enrollment's user with comment only as body" do
      expect {
        review_application
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      last_mail = ActionMailer::Base.deliveries.last

      expect(last_mail.body).to eq(comment)
    end
  end
end
