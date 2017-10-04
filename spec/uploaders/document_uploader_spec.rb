# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentUploader do
  include CarrierWave::Test::Matchers

  let(:document) { FactoryGirl.create(:document) }
  let(:uploader) { DocumentUploader.new(document, :attachment) }

  before do
    File.open(Rails.root.join('spec/resources/test.pdf')) do |f|
      uploader.store!(f)
    end
  end

  after do
    uploader.remove!
  end

  it 'has the correct format' do
    expect(uploader).to be_format('png')
  end
end
