require 'rails_helper'

describe CoreAdditions do
  describe String do
    describe "#as_personified_event" do
      Hash[Enrollment.state_machine.events.map(&:name).zip(
        %w[
          application_sender
          application_validater
          application_refuser
          application_reviewer
          technical_inputs_sender
          application_deployer
        ]
      )].each do |event, personified|
        it "should personify event #{event}" do
          expect(event.to_s.as_personified_event).to eq(personified)
        end
      end
    end
  end
end
