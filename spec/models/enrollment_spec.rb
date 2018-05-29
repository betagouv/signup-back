# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }
  let(:enrollment_dgfip) { FactoryGirl.create(:enrollment_dgfip) }

  describe '#self.with_role' do
    let(:user) { FactoryGirl.create(:user) }
    let(:result) { described_class.with_role(:applicant, user) }

    it 'returns an ActiveRecord::Relation' do
      expect(result).to match_array([])
    end

    it 'result is empty' do
      expect(result).to be_empty
    end

    describe 'user is applicant of enrollment and enrollment_dgfip' do
      before do
        user.add_role(:applicant, enrollment)
        user.add_role(:applicant, enrollment_dgfip)
      end

      it 'return enrollment and enrollment_dgfip with user as applicant' do
        expect(result.include?(enrollment)).to be_truthy
        expect(result.include?(enrollment_dgfip)).to be_truthy
      end
    end
  end

  describe '#self.absract?' do
    it 'is abstract' do
      expect(described_class.abstract?).to be_truthy
    end

    it 'has subclasses that are not abstract' do
      described_class.subclasses.each do |subclass|
        expect(subclass.abstract?).to be_falsey
      end
    end
  end
end
