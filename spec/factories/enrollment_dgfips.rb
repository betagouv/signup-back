FactoryGirl.define do
  factory :enrollment_dgfip, class: 'Enrollment::Dgfip' do
    fournisseur_de_donnees 'dgfip'
    demarche "intitule" => "test", "description" => "test", "fondement_juridique" => "test"
    validation_de_convention true

    factory :sent_enrollment_dgfip do
      siret '12345'
      state 'sent'
      donnees "conservation" => 12, "destinataires" => { "dgfip_avis_imposition" => "Destinaires des données"}
      scopes dgfip_avis_imposition: true
      contacts [
        {"id"=>"dpo", "heading"=>"Délégué à la protection des données", "nom" => "test", "email" => "test"},
        {"id"=>"responsable_traitement", "heading"=>"Responsable de traitement", "nom" => "test", "email" => "test"},
        {"id"=>"technique", "heading"=>"Responsable technique", "nom" => "test", "email" => "test"},
      ]


      factory :refused_enrollment_dgfip do
        state 'refused'
      end

      factory :validated_enrollment_dgfip do
        state 'validated'

        factory :technical_inputs_enrollment_dgfip do
          state 'technical_inputs'
          ips_de_production 'test'

          factory :deployed_enrollment_dgfip do
            state 'deployed'
          end
        end
      end
    end
  end
end
