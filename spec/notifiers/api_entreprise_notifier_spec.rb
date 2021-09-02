RSpec.describe ApiEntrepriseNotifier, type: :notifier do
  let(:instance) { described_class.new(enrollment) }

  let(:enrollment) { create(:enrollment, :api_entreprise) }
  let(:user) { create(:user) }

  describe "webhook events" do
    shared_examples "notifier webhook delivery" do
      it "calls webhook" do
        expect(DeliverEnrollmentWebhookWorker).to receive(:perform_async).with(
          enrollment.target_api,
          WebhookSerializer.new(
            enrollment,
            event
          ).serializable_hash,
          enrollment.id
        )

        subject
      end
    end

    describe "#created" do
      subject { instance.created }

      include_examples "notifier webhook delivery" do
        let(:event) { "created" }
      end
    end

    describe "#updated" do
      subject { instance.updated(diff: "diff", user_id: user.id) }

      include_examples "notifier webhook delivery" do
        let(:event) { "updated" }
      end
    end

    describe "#notify" do
      subject { instance.notify(comment: "comment", current_user: user) }

      include_examples "notifier webhook delivery" do
        let(:event) { "notify" }
      end
    end

    describe "#review_application" do
      subject { instance.review_application(comment: "comment", current_user: user) }

      include_examples "notifier webhook delivery" do
        let(:event) { "review_application" }
      end
    end

    describe "#refuse_application" do
      subject { instance.refuse_application(comment: "comment", current_user: user) }

      include_examples "notifier webhook delivery" do
        let(:event) { "refuse_application" }
      end
    end

    describe "#validate_application" do
      subject { instance.validate_application(comment: "comment", current_user: user) }

      include_examples "notifier webhook delivery" do
        let(:event) { "validate_application" }
      end
    end
  end

  describe "emails events" do
    describe "#rgpd_contact_updated" do
      let(:enrollment) { create(:enrollment, :api_entreprise, :with_delegue_protection_donnees) }

      subject { instance.rgpd_contact_updated(diff: "diff", user_id: user.id, dpo_email: user.email, responsable_traitement_email: nil) }

      it "delivers an email" do
        expect {
          subject
        }.to have_enqueued_job.on_queue("mailers")
      end
    end
  end

  describe "#owner_updated" do
    subject { instance.owner_updated(diff: "diff", user_id: user.id) }

    it "does nothing" do
      expect(DeliverEnrollmentWebhookWorker).not_to receive(:perform_async)

      expect {
        subject
      }.not_to have_enqueued_job.on_queue("mailers")
    end
  end
end
