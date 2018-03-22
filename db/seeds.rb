r = ResourceProvider.where(
  short_name: 'DGFIP',
  long_name: 'Direction Générale des Finances Publiques',
  scopes: [
    Scope.create(name: 'scope_1', human_name: 'Scope 1'),
    Scope.create(name: 'scope_2', human_name: 'Scope 2')
  ],
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nulla lorem, maximus vel nisl in, finibus aliquam nunc. Quisque malesuada nisi nec mi interdum rutrum. Maecenas vel magna sit amet nulla volutpat finibus non nec ex. Pellentesque eu lectus tortor. Donec semper malesuada nisl eu elementum. Nulla placerat nisl ut massa luctus consectetur. Praesent varius sit amet sapien at suscipit. Pellentesque bibendum iaculis turpis, at lobortis sem sodales id. Nulla vitae auctor turpis, id tristique elit. Vestibulum euismod dolor dictum nulla maximus, vitae maximus nunc efficitur.'
).first_or_create
r.scopes << Scope.new(
  name: 'dgfip_avis_imposition',
  human_name: "Avis d'imposition",
  description: "Données issues du service svair de la DGFIP",
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
  scopes: [
    Scope.create(name: 'scope_1', human_name: 'Scope 1'),
    Scope.create(name: 'scope_2', human_name: 'Scope 2')
  ],
  description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nulla lorem, maximus vel nisl in, finibus aliquam nunc. Quisque malesuada nisi nec mi interdum rutrum. Maecenas vel magna sit amet nulla volutpat finibus non nec ex. Pellentesque eu lectus tortor. Donec semper malesuada nisl eu elementum. Nulla placerat nisl ut massa luctus consectetur. Praesent varius sit amet sapien at suscipit. Pellentesque bibendum iaculis turpis, at lobortis sem sodales id. Nulla vitae auctor turpis, id tristique elit. Vestibulum euismod dolor dictum nulla maximus, vitae maximus nunc efficitur.'
).first_or_create
r.scopes << Scope.new(
  name: 'cnaf_attestation_droits',
  human_name: 'Attestation de droits',
  description: "Contient le revenu fiscal de référence, le nombre de part et les déclarants"
)
r.scopes << Scope.new(
  name: 'cnaf_quotient_familial',
  human_name: 'Quotient familial',
  description: 'Contient le quotient familial du mois précédent'
)
r.save
