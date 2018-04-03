r = ResourceProvider.where(
  resource_provider_type: 'franceConnect',
  short_name: 'DGFIP',
  long_name: 'Direction Générale des Finances Publiques',
  description: "La Direction générale des Finances publiques (DGFiP) est une direction de l'administration publique centrale française qui dépend du ministère de l'Économie et des Finances."
).first_or_create
r.scopes << Scope.new(
  name: "dgfip_fc_rfr",
  human_name: "Revenu Fiscal de Référence (RFR) et nombre de parts fiscales du foyer",
  description: "",
  node_example: "",
  services: [
    {
      name: 'Calcul du quotient familial de la ville de Lyon',
      url: 'https://www.lyon.fr/demarche/loisirs/calcul-du-quotient-familial-municipal'
    }
  ]
)
r.scopes << Scope.new(
  name: "dgfip_fc_taxe_ir",
  human_name: "Adresse fiscale de taxation au 1er janvier",
  description: "Ces données peuvent être utilisées, par exemple, pour la délivrance des cartes de stationnement résidentiel",
  node_example: "",
  services: []
)
r.save

r = ResourceProvider.where(
  resource_provider_type: 'apiParticulier',
  short_name: 'DGFIP',
  long_name: 'Direction Générale des Finances Publiques',
  description: "La Direction générale des Finances publiques (DGFiP) est une direction de l'administration publique centrale française qui dépend du ministère de l'Économie et des Finances."
).first_or_create
r.scopes << Scope.new(
  name: 'dgfip_avis_imposition',
  human_name: "Avis d'imposition",
  description: "Données issues du service svair de la DGFIP",
  node_example: "const fetch = require('node-fetch')\nconst queryString = require('query-string')\n\nconst params = queryString.stringify({\n    numeroFiscal: '1562456789521',\n    referenceAvis: '1512456789521'\n})\n\nawait fetch('http://particulier-sandbox.api.gouv.fr/api/impots/svair?' + params, {\n    headers: {'X-API-Key': 'test-token'}\n}).then(res => res.json())",
  services: [
    {
      name: 'BourseSCO',
      url: 'https://api.gouv.fr/service/bourse.html'
    }, {
      name: 'Lyon : Mon compte',
      url: 'https://api.gouv.fr/service/calcul-quotient-familial.html'
    }
  ]
)
r.save

r = ResourceProvider.where(
  resource_provider_type: 'apiParticulier',
  short_name: 'CNAF',
  long_name: 'Caisse Nationale des Allocation Familliales',
  description: "La Caisse nationale des allocations familiales (CNAF) forme la branche «famille» de la Sécurité sociale française, qu'elle gère au travers le réseau formé par les 102 caisses d'allocations familiales (CAF) réparties sur tout le territoire."
).first_or_create
r.scopes << Scope.new(
  name: 'cnaf_attestation_droits',
  human_name: 'Attestation de droits',
  node_example: "const fetch = require('node-fetch')\nconst queryString = require('query-string')\n\nconst params = queryString.stringify({\n    numeroAllocataire: '0000354',\n    codePostal: '99148'\n})\n\nawait fetch('http://particulier-sandbox.api.gouv.fr/api/caf/famille?' + params, {\n    headers: {'X-API-Key': 'test-token'}\n}).then(res => res.json())",
  description: "Contient le revenu fiscal de référence, le nombre de part et les déclarants"
)
r.scopes << Scope.new(
  name: 'cnaf_quotient_familial',
  human_name: 'Quotient familial',
  node_example: "const fetch = require('node-fetch')\nconst queryString = require('query-string')\n\nconst params = queryString.stringify({\n    numeroAllocataire: '0000354',\n    codePostal: '99148'\n})\n\nawait fetch('http://particulier-sandbox.api.gouv.fr/api/caf/famille?' + params, {\n    headers: {'X-API-Key': 'test-token'}\n}).then(res => res.json())",
  description: 'Contient le quotient familial du mois précédent'
)
r.save
