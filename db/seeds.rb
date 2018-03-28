r = ResourceProvider.where(
  short_name: 'DGFIP',
  long_name: 'Direction Générale des Finances Publiques',
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nulla lorem, maximus vel nisl in, finibus aliquam nunc. Quisque malesuada nisi nec mi interdum rutrum. Maecenas vel magna sit amet nulla volutpat finibus non nec ex. Pellentesque eu lectus tortor. Donec semper malesuada nisl eu elementum. Nulla placerat nisl ut massa luctus consectetur. Praesent varius sit amet sapien at suscipit. Pellentesque bibendum iaculis turpis, at lobortis sem sodales id. Nulla vitae auctor turpis, id tristique elit. Vestibulum euismod dolor dictum nulla maximus, vitae maximus nunc efficitur.'
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
  short_name: 'CNAF',
  long_name: 'Caisse Nationale des Allocation Familliales',
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nulla lorem, maximus vel nisl in, finibus aliquam nunc. Quisque malesuada nisi nec mi interdum rutrum. Maecenas vel magna sit amet nulla volutpat finibus non nec ex. Pellentesque eu lectus tortor. Donec semper malesuada nisl eu elementum. Nulla placerat nisl ut massa luctus consectetur. Praesent varius sit amet sapien at suscipit. Pellentesque bibendum iaculis turpis, at lobortis sem sodales id. Nulla vitae auctor turpis, id tristique elit. Vestibulum euismod dolor dictum nulla maximus, vitae maximus nunc efficitur.'
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
