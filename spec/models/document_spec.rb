# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:enrollment) { create(:enrollment) }

  it 'can be a Document::LegalBasis' do
    document = create(:document, type: 'Document::LegalBasis')

    expect(Document.find(document.id)).to be_a(Document::LegalBasis)
  end
end
