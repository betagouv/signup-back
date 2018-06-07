FactoryGirl.define do
  factory :enrollment_dgfip, class: 'Enrollment::Dgfip' do
    fournisseur_de_donnees 'dgfip'
    fournisseur_de_service 'test'
    description_service "test"
    validation_de_convention true

    factory :sent_enrollment_dgfip do
      fondement_juridique "test"
      scope_dgfip_RFR true
      scope_dgfip_adresse_fiscale_taxation true
      nombre_demandes_annuelle 34568
      pic_demandes_par_heure 567
      france_connect true
      administration true
      autorisation_legale true
      nombre_demandes_mensuelles_jan 45
      nombre_demandes_mensuelles_fev 45
      nombre_demandes_mensuelles_mar 45
      nombre_demandes_mensuelles_avr 45
      nombre_demandes_mensuelles_mai 45
      nombre_demandes_mensuelles_jui 45
      nombre_demandes_mensuelles_jul 45
      nombre_demandes_mensuelles_aou 45
      nombre_demandes_mensuelles_sep 45
      nombre_demandes_mensuelles_oct 45
      nombre_demandes_mensuelles_nov 45
      nombre_demandes_mensuelles_dec 45
      autorite_certification_nom "test"
      autorite_certification_fonction "test"
      demarche_cnil true
      date_homologation "2018-06-01"
      date_fin_homologation "2019-06-01"
      delegue_protection_donnees "test"
      certificat_pub_production "test"
      autorite_certification "test"
      state 'sent'

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
