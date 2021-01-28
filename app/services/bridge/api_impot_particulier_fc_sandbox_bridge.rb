class ApiImpotParticulierFcSandboxBridge < BridgeService
  def initialize(enrollment, instructor_id)
    @enrollment = enrollment
    @instructor = User.find(instructor_id)
  end

  def call
    response = HTTP.get("https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/#{@enrollment.siret}")
    siren = response.parse["etablissement"]["siren"]
    code_postal = response.parse["etablissement"]["code_postal"]
    libelle_commune = response.parse["etablissement"]["libelle_commune"]
    geo_l4 = response.parse["etablissement"]["geo_l4"]
    geo_l5 = response.parse["etablissement"]["geo_l5"]

    response = Http.post(
      "http://localhost:34567/sandbox/#{@enrollment.id}",
      {
        identifiantSandboxOld: @enrollment.copied_from_enrollment_id,
        organisation: {
          siren: siren,
          libelle: @enrollment.nom_raison_sociale,
          adresse: {
            ligne1: geo_l4,
            ligne2: geo_l5,
            # TODO non renseigné
            ligne3: nil,
            codePostal: code_postal,
            ville: libelle_commune,
            pays: "FRANCE"
          }
        },
        demande: {
          demandeur: {
            mail: @enrollment.user.email,
            # TODO à venir
            telephone: nil,
            denominationEtatCivil: {
              # TODO à venir
              nom: nil,
              # TODO à venir
              prenom: nil
            },
            # TODO à valider
            denominationService: @enrollment.nom_raison_sociale
          },
          valideur: {
            # @enrollment.events.where(name: "validated").user.email
            mail: @instructor.email,
            # TODO non renseigné
            telephone: nil,
            denominationEtatCivil: {
              # TODO non renseigné
              nom: nil,
              # TODO non renseigné
              prenom: nil
            },
            # TODO non renseigné
            denominationService: nil
          },
          dateCreation: @enrollment.created_at,
          dateSoumission: @enrollment.submitted_at,
          dateValidation: @enrollment.validated_at
        },
        casUsage: {
          libelle: @enrollment.intitule,
          detail: @enrollment.description
        },
        "datas": [
          # TODO besoin de la liste exhaustive des labels, des ressourceCode et des restrictions
          {
            "nom": "Impôt_Particulier",
            "ressources": [
              {
                "ressourceCode": "RessourceIR",
                "restrictions": %w[rfr nbpart AnneeN1 AnneeN]
              },
              {
                "ressourceCode": "RessourceTHPrincipale",
                "restrictions": %w[donneeLocal adresseFisc AnneeN1 AnneeN]
              }
            ],
            "version": "1.0"
          }
        ],
        responsableTechnique: {
          mail: @enrollment.contacts&.find { |e| e["id"] == "technique" }&.fetch("email"),
          telephone: @enrollment.contacts&.find { |e| e["id"] == "technique" }&.fetch("phone_number"),
          denominationEtatCivil: {
            nom: @enrollment.contacts&.find { |e| e["id"] == "technique" }&.fetch("family_name"),
            prenom: @enrollment.contacts&.find { |e| e["id"] == "technique" }&.fetch("given_name")
          },
          # TODO champs non renseigné
          denominationService: nil
        },
        cadreJuridique: {
          nature: @enrollment.fondement_juridique_title,
          texteDocument: {
            # TODO
            fichier: nil,
            # TODO valider les valeurs disponibles ici
            extension: "PDF",
            # TODO
            nom: nil
          },
          texteUrl: @enrollment.fondement_juridique_url
        },
        # TODO validation valeur en dur
        attestationRGPD: true,
        cgu: {
          # TODO valider les valeurs disponibles ici
          libelle: "cgu_api_impot_particulier_bac_a_sable_connexion_fc_septembre2020_v2.6.1.pdf",
          version: "v2.6.1",
          # TODO validation valeur en dur
          attestationCGU: true
        }
      },
      nil,
      "APIM DGFiP",
      "referer"
    )

    raise ApplicationController::NotImplementedError

    EnrollmentMailer.with(
      target_api: "api_impot_particulier_fc_sandbox",
      nom_raison_sociale: @enrollment.nom_raison_sociale,
      enrollment_id: @enrollment.id,
      previous_enrollment_id: @enrollment.previous_enrollment_id,
      scopes: @enrollment[:scopes].reject { |k, v| !v }.keys
    ).add_scopes_in_franceconnect_email.deliver_later

    response.parse["id"]
  end
end
