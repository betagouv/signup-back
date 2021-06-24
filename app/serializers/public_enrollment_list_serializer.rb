class PublicEnrollmentListSerializer < ActiveModel::Serializer
  attributes :target_api, :siret, :nom_raison_sociale, :updated_at, :intitule,
    :responsable_traitement_family_name, :responsable_traitement_given_name
end
