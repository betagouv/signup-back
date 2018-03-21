# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { FactoryGirl.create(:enrollment) }

  let(:attributes) do
    JSON.parse(
      <<-EOF
      {
        "fournisseur_de_service": "test",
        "description_service": "test",
        "fondement_juridique": "test",
        "scope_RFR": true,
        "nombre_demandes_annuelle": 34568,
        "pic_demandes_par_heure": 567,
        "nombre_demandes_mensuelles_jan": 45,
        "nombre_demandes_mensuelles_fev": 45,
        "nombre_demandes_mensuelles_mar": 45,
        "nombre_demandes_mensuelles_avr": 45,
        "nombre_demandes_mensuelles_mai": 45,
        "nombre_demandes_mensuelles_jui": 45,
        "nombre_demandes_mensuelles_jul": 45,
        "nombre_demandes_mensuelles_aou": 45,
        "nombre_demandes_mensuelles_sep": 45,
        "nombre_demandes_mensuelles_oct": 45,
        "nombre_demandes_mensuelles_nov": 45,
        "nombre_demandes_mensuelles_dec": 45,
        "autorite_certification_nom": "test",
        "autorite_certification_fonction": "test",
        "date_homologation": "2018-06-01",
        "date_fin_homologation": "2019-06-01",
        "delegue_protection_donnees": "test",
        "validation_de_convention": true,
        "certificat_pub_production": "test",
        "autorite_certification": "test",
        "ip_production": ["test", "test"],
        "mise_en_production": true
      }
      EOF
    )
  end
  after do
    DocumentUploader.new(Enrollment, :attachment).remove!
  end

  it 'can have messages attached to it' do
    expect do
      enrollment.messages.create(content: 'test')
    end.to change { enrollment.messages.count }
  end

  it "has a valid schema" do
    enrollment = Enrollment.create(attributes)

    enrollment_attributes = enrollment.as_json
    enrollment_attributes.delete('created_at')
    enrollment_attributes.delete('updated_at')
    enrollment_attributes.delete('id')
    attributes['state'] = 'pending'
    attributes['date_fin_homologation'] = Date.parse(attributes['date_fin_homologation'])
    attributes['date_homologation'] = Date.parse(attributes['date_homologation'])

    expect(enrollment_attributes).to eq(attributes)
  end

  Enrollment::DOCUMENT_TYPES.each do |document_type|
    describe document_type do
      it 'can have document' do
        expect do
          enrollment.documents.create(
            type: document_type,
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.to(change { enrollment.documents.count })
      end

      it 'can only have a document' do
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect do
          enrollment.documents.create(
            type: document_type,
            attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
          )
        end.not_to(change { enrollment.documents.count })
      end

      it 'overwrites the document' do
        enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        document = enrollment.documents.create(
          type: document_type,
          attachment: Rack::Test::UploadedFile.new(Rails.root.join('spec/resources/test.pdf'), 'application/pdf')
        )

        expect(enrollment.documents.last).to eq(document)
      end
    end
  end
end
