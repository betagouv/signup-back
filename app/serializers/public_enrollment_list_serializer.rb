class PublicEnrollmentListSerializer < ActiveModel::Serializer
  attributes :target_api, :siret, :nom_raison_sociale, :updated_at, :intitule, :responsable_traitement_label
end
