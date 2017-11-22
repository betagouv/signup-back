require 'rails_helper'

describe CoreAdditions do
  describe String do
    describe "#as_event_personified" do
      Hash[Enrollment.state_machine.events.map(&:name).zip(
        %w[
          application_completer
          application_sender
          application_refuser
          application_approver
          convention_signer
          deployer
        ]
      )].each do |event, personified|
        it "should personify event #{event}" do
          expect(event.as_event_personified).to eq(personified)
        end
      end
    end
  end
end
