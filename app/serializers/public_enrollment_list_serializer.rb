class PublicEnrollmentListSerializer < ActiveModel::Serializer
  attributes :fournisseur_de_donnees, :siret, :nom_raison_sociale, :updated_at, :intitule
  attribute :email_responsable_traitement do
    object.contacts.select { |contact| contact['id'] == 'responsable_traitement' }.first['nom']
  end
end
