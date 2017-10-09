prawn_document do |pdf|
  pdf.font_size 10

  pdf.text "Article 6. Rôle et engagements  du fournisseur de services (FS)", size: 14, style: :bold
  pdf.text "Le fournisseur de service met en œuvre : #{@enrollment.service_description['main']}"
  pdf.move_down 10

  pdf.text "Dans le cadre du téléservice, le FS susmentionné s’engage à s’assurer :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- que l’affichage explicite du consentement prenne en compte le périmètre ainsi que le libellé des offres de service transmises par la DGFiP ; l’origine des données fiscales devra aussi être indiquée sur cette page ;"
    pdf.text "- de la bonne utilisation des données personnelles ;"
    pdf.text "- du respect de la confidentialité des données ;"
    pdf.text "- de la mise en œuvre de tous les moyens nécessaires à leur garantie ;"
    pdf.text "- de l’accompagnement de l’usager, par la possibilité dans chaque écran d’accéder aux mentions légales précisant les possibilités de rectification des données, de permettre la mise en relation de l’usager avec un interlocuteur (adresse courriel), et d'indiquer une rubrique contact accessible dans tous les menus."
  end
  pdf.move_down 10

  pdf.text "Le fournisseur de services est responsable des informations traitées dans le cadre du service, et à ce titre s’engage à respecter la réglementation relative à la protection des données personnelles sur :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    @enrollment.scopes.each do |k, v|
      pdf.text "- #{t("enrollment.scopes.#{k}")}" if v
    end
  end
  pdf.text "Il est responsable du respect et de la bonne mise en œuvre de la réglementation édictée par l'Agence Nationale de la sécurité des systèmes d'information (ANSSI) que ce soit sur les domaines de la protection des systèmes d'informations, de la confiance numérique (RGS, eIDAS), de la réglementation technique et cryptographique."
  pdf.move_down 10

  pdf.text "Le FS s'engage à prendre toutes les mesures utiles décrites dans l'annexe xxx pour assurer lors de l’exécution de la convention, la protection des informations qui peuvent être détenues ou échangées par les parties, notamment au travers :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- de la conduite d'une démarche de prise en compte des risques, validée par une décision d'homologation de sécurité du téléservice concerné ;"
    pdf.text "- de la sécurisation des développements, prenant en compte les spécificités du protocole utilisé, ainsi que de l'environnement technique du téléservice ;"
    pdf.text "- de la mise en œuvre des systèmes de détection d'événements de sécurité"
  end
  pdf.move_down 10

  pdf.text "Des vérifications pourront être réalisées à tout moment par les autorités de contrôle compétentes (ANSSI, SGMAP ou entités mandataires) pour s'assurer de la mise en œuvre des engagements pris par le fournisseur de services en matière de sécurité des systèmes d'information. Ces vérifications incluent la possibilité de mener des audits de sécurité sur le téléservice."
  pdf.move_down 10

  pdf.text "En cas de manquement aux engagements de sécurité pris en application de la présente convention et décrits dans l'annexe xxx, la transmission des données de la DGFiP via France Connect pourra être coupée sur décision de la DGFiP ou du SGMAP."
  pdf.move_down 10

  pdf.text "Le téléservice #{@enrollment.service_provider['name']} utilise des données de la DGFiP de niveau X."
  pdf.text "En conséquence, le fournisseur de services se conformera aux obligations de sécurité exigées par le niveau des données exposées (Cf annexe xxx)."
  pdf.move_down 10

  pdf.text "Le fournisseur de service s'engage à produire à la DGFiP et au SGMAP :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- les récépissés de l'avis CNIL"
    pdf.text "- une copie de l'attestation d'homologation de sécurité du service concerné, signée par l'autorité d'homologation désignée par le FS."
  end
  pdf.move_down 10

  pdf.text "Cette attestation doit a minima contenir les informations suivantes :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- identité de l’autorité signataire ;"
    pdf.text "- fonction et nom du signataire ;"
    pdf.text "- date de l’homologation ;"
    pdf.text "- durée de l’homologation."
  end
  pdf.move_down 10

  pdf.text "La présente convention pourra faire l'objet d'un avenant pour intégration de nouvelles exigences de sécurité."

  pdf.start_new_page

  pdf.text "Annexe xxx. Sécurité du téléservice", size: 22, style: :bold
  pdf.move_down 20

  pdf.text "Afin de sécuriser le téléservice qu'il propose aux usagers et assurer la protection des informations échangées avec le fournisseur de données, le fournisseur de service s'engage à mettre en œuvre les dispositions présentées ci-après."
  pdf.move_down 10

  pdf.text "Le fournisseur de données détermine un niveau de sensibilité pour chaque « pack » de données proposé par France Connect, en fonction de la nature des informations contenues."
  pdf.text "A chacun des trois niveaux définis correspond un niveau d'exigences attendu du fournisseur de service sur la sécurisation des échanges et du système d'information qui les manipule."
  pdf.move_down 10

  pdf.text "1. Organisation SSI", size: 16, style: :bold
  pdf.text "Le fournisseur de service veille à mettre en place une organisation dédiée à la sécurité des systèmes d'information."
  pdf.text "Cette organisation définit les responsabilités internes et à l'égard des tiers, les modalités de coordination avec les autorités externes ainsi que les modalités d'application des mesures de protection."
  pdf.text "Dans ce cadre, le fournisseur de service s'appuie sur un ou plusieurs responsables de la sécurité des systèmes d'information (RSSI)."
  pdf.text "Le fournisseur de service établit une politique de sécurité des systèmes d'information (PSSI)."
  pdf.text "Les informations relatives à l'organisation SSI, notamment celles nécessaires à l'établissement des canaux de communication avec le fournisseur de données doivent être transmises à la DGFiP et au SGMAP, préalablement à l'ouverture du service."
  pdf.move_down 10

  pdf.text "2. Homologation de sécurité", size: 16, style: :bold
  pdf.text "Dans le cadre du RGS (Référentiel Général de Sécurité), le fournisseur de services veillera à procéder à l’homologation de sécurité de son téléservice (ordonnance n°2005-1516 du 8 décembre 2005, décret n°2010-112 du 2 février 2010)."
  pdf.text "L’homologation de sécurité du téléservice devra avoir été réalisée avant l'ouverture du flux de données avec la DGFiP."
  pdf.text "L'homologation du téléservice, formalisée par une attestation d'homologation de sécurité, doit s'appuyer sur le dossier de sécurité du projet."
  pdf.move_down 10

  pdf.text "Le dossier de sécurité comprend a minima une analyse de risques et le plan d'actions en découlant ainsi que la politique de sécurité appliquée. Parmi les scénarii de risque envisagés, doivent être inclus ceux concernant une compromission de l'intégrité ou de la confidentialité sur les données issues du fournisseur de données DGFiP."
  pdf.text "Le fournisseur de service s'engage à couvrir les risques portant sur le téléservice concerné et à mettre en œuvre un suivi des risques résiduels."
  pdf.move_down 10

  pdf.text "Le dossier de sécurité comporte également les rapports d'audits de sécurité (audits statiques / dynamiques), qui doivent être réalisés régulièrement. Les rapports d'audits réalisés seront, le cas échéant, fournis à l'ANSSI sur demande de sa part."
  pdf.text "Dans le cas où le FS passe par un éditeur, il peut déléguer à cet éditeur l'obligation de réalisation des audits de sécurité  Néanmoins la vérification du respect de cette obligation par l'éditeur ressort de la responsabilité du fournisseur de service."
  pdf.move_down 10

  pdf.text "Les exigences suivantes devront être respectées pour les audits de sécurité :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- d'un point de vue méthodologique, ils doivent prendre en compte les spécifications du protocole OpenID Connect. En particulier, les tests d'intrusion réalisés dans ce cadre intégreront les modèles de menaces présentés dans les RFC 6819 et 7636, ainsi que dans Open ID specs 1.0 Security Considerations : https://tools.ietf.org/html/rfc6819"
    pdf.text "- les vulnérabilités détectées doivent être évaluées selon le standard international CVSS, dans sa version 3."
  end
  pdf.move_down 10

  pdf.text "En cas de prestation externalisée, le fournisseur de services s'assurera que le cahier des charges de la prestation d'audit intègre bien ces points."
  pdf.move_down 10

  pdf.text "Le fournisseur de service s'engage à corriger, avant raccordement avec le fournisseur de données, les vulnérabilités les plus critiques. Le niveau de criticité acceptable dépend du niveau de sensibilité des données, et est précisé au §7."
  pdf.move_down 10

  pdf.text "Le renouvellement de l'homologation doit être conforme au référentiel général de sécurité :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- la durée de validité d'une homologation de sécurité ne peut excéder 5 ans. En fonction du niveau de sensibilité des données échangées, une durée d'homologation plus courte pourra être requise (voir §7)."
    pdf.text "- L'homologation doit être renouvelée au terme de sa durée de validité, mais également en cas de changement affectant le téléservice : évolution fonctionnelle ou technique majeure, changement dans l'environnement technique, ou tout élément relatif à la sécurité du système d'information considéré, par exemple la survenance d'un incident de sécurité2."
    pdf.text "- Le renouvellement s'appuie sur un dossier de sécurité constitué avec les mêmes éléments que le dossier de l'homologation initiale."
  end
  pdf.text "En cas de dépassement de la date de validité de l'homologation, la transmission des données pourra être désactivée, à l'initiative de la DGFiP ou du SGMAP."
  pdf.move_down 10

  pdf.text "3. Exigences de sécurité pour le téléservice", size: 16, style: :bold
  pdf.text "Les exigences de sécurité listées ci-après sont requises pour le fournisseur de service en préalable à  tout échange de données. Le dossier de sécurité prévu au §2 confirmera la prise en compte de chacune de ces exigences :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- S'agissant des développements, respecter les spécifications de sécurité du protocole OpenID Connect dans l’implémentation des différentes briques du dispositif : http://openid.net/specs/openid-connect-core-1_0.html#Security."
    pdf.text "- mettre en œuvre toutes les dispositions nécessaires pour assurer la confidentialité et l'intégrité des données échangées. Notamment, celles-ci seront stockées de façon sécurisée, par exemple en utilisant un algorithme de chiffrement conforme à l'état de l'art."
    pdf.text "- Réaliser la conservation et la purge des données échangées conformément au contenu de la déclaration faite à la CNIL pour le téléservice. Le fournisseur de services se conformera à l'acte réglementaire unique RU-048 (https://www.cnil.fr/fr/declaration/ru-048-franceconnect). Les données utilisées dans le cadre du téléservice ne devront pas être conservées au-delà de la durée nécessaire à la procédure en cours."
    pdf.text "- Mettre en œuvre un dispositif de traces techniques (logs) à même de permettre les investigations en cas d'événement de sécurité. Ces traces doivent être conservées de manière sûre, sur une durée de 3 ans."
    pdf.text "- Mettre en œuvre de certificats avec authentification mutuelle et assurer l’implémentation rigoureuse des règles d’appels telles que définies dans l’annexe « Processus d'implémentation de FC par FS » des conditions générales d’utilisation de FranceConnect en conformité avec le Référentiel Général de Sécurité (RGS)."
    pdf.text "- Installer des logiciels de protection contre les codes malveillants sur l'ensemble des serveurs d'interconnexion, des serveurs applicatifs et des postes de travail de l'entité. Ces logiciels de protection doivent être distincts pour ces trois catégories au moins."
    pdf.text "- Inclure, lors de la recette du système d'information considéré, des contrôles de sécurité, à réaliser avant toute mise en production. Des outils de tests pourront notamment être utilisés pour vérifier la bonne implémentation du protocole OpenID Connect3."
    pdf.text "- Maintenir le niveau de sécurité de son système d'information notamment en appliquant régulièrement les correctifs mis à disposition par les éditeurs logiciels."
  end
  pdf.move_down 20

  pdf.text "4. Gestion des incidents de sécurité", size: 16, style: :bold
  pdf.text "Les différentes parties s'engagent à mettre en place un processus de gestion des incidents de sécurité, avec les phases suivantes :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- Mesures de réponses immédiates : ex. isolation, coupure du service"
    pdf.text "- Traitement :"
    pdf.bounding_box [20, pdf.cursor], width: 480 do
      pdf.text "- le cas échéant, activation d'une cellule de crise ;"
      pdf.text "- restrictions temporaires d'accès ;"
      pdf.text "- actions d'alerte (RSSI) réciproques et de communication (Cf §1 de la présente annexe)."
    end
    pdf.text "- Investigations :"
    pdf.bounding_box [20, pdf.cursor], width: 480 do
      pdf.text "- rassemblement et préservation de toutes les informations disponibles pour permettre les investigations, notamment obtention des journaux couvrant la période d’investigation ; à cet effet, le fournisseur de service s'engage à fournir à ses partenaires toute information utile"
      pdf.text "- détermination du périmètre ;"
      pdf.text "- qualification de l'incident, identification du fait générateur et analyse d'impact."
    end
    pdf.text "- Résolution de l'incident :"
    pdf.bounding_box [20, pdf.cursor], width: 480 do
      pdf.text "- analyse de l'incident de sécurité pour détermination de la cause, correction ;"
      pdf.text "- vérification avant remise en service que l'élément malveillant a été supprimé et que les éventuelles vulnérabilités sont corrigées ;"
      pdf.text "- le cas échéant : suites judiciaires (dépôt de plainte)."
    end
  end
  pdf.move_down 10

  pdf.text "La mise en place d’un tel processus implique au préalable :"
  pdf.bounding_box [20, pdf.cursor], width: 500 do
    pdf.text "- la mise en place de dispositifs permettant la détection d’intrusions, la corrélation d’événements de sécurité, la surveillance du SI (comportements anormaux) ;"
    pdf.text "- une revue des incidents faite régulièrement pour quantifier et surveiller les différents types d’incidents ;"
    pdf.text "- la mise en place d'une politique de journalisation ;"
    pdf.text "- la définition des acteurs, des circuits d'alerte, la sensibilisation des différents acteurs (utilisateurs, des exploitants …) ;"
    pdf.text "- des tests des processus d'alerte."
  end
  pdf.move_down 10

  pdf.text "Tous ces éléments doivent être formalisés dans un document d'exploitation qui sera transmis au SGMAP préalablement à l'ouverture du service."
  pdf.move_down 20

  pdf.text "5. Contrôles externes", size: 16, style: :bold
  pdf.text "Les engagements en termes de sécurité, pris par le FS aux termes de la présente convention, pourront être vérifiés par l'ANSSI, e SGMAP et la DGFiP ; les livrables des audits et le suivi de ces audits doivent être fournis sur la demande de l'une de ces deux entités, ainsi que l'ensemble du dossier de sécurité du téléservice."
  pdf.text "L'ANSSI et le SGMAP pourront également faire réaliser un audit de sécurité du téléservice ; à cet effet, un environnement permettant de faire des tests d'intrusion sera mis à sa disposition par le fournisseur de services ; d'autres types d'audits - audits de site, de code, des contrats de sous-traitance, … -  pourront être inclus dans le périmètre de l’audit de sécurité."
  pdf.text "Par ailleurs, avant d'accepter le raccordement d'un nouveau FS à l'API de fourniture de données, des tests d'intrusion automatisés de sécurité pourront être effectués par le SGMAP."
  pdf.move_down 20

  pdf.text "6. Prestataires externes", size: 16, style: :bold
  pdf.text "Toute prestation réalisée par tout organisme externe au fournisseur de service est encadrée par des clauses de sécurité. Ces clauses spécifient les mesures SSI que le prestataire doit respecter. Ces clauses doivent au minimum être du même niveau que celles imposées au fournisseur de service."
  pdf.text "L'hébergement et l'exploitation informatique des données de l'Administration doivent être réalisés sur le territoire français. Les dispositions relatives à la sécurité des systèmes d'information doivent être détaillées et portées à la connaissance de l’ANSSI, du SGMAP et de la DGFiP."
  pdf.move_down 20

  pdf.text "7. Niveaux de sensibilité de données", size: 16, style: :bold
  pdf.text "Plusieurs niveaux de sensibilité des données sont envisageables. En fonction de ce niveau, les exigences attendues d'un téléservice consommateur de ces données doivent être ajustées."
  pdf.text "Le fournisseur de données détermine seul le niveau de sensibilité de ses données. Celui-ci est précisé dans la convention de partenariat."
  pdf.move_down 10

  pdf.text "Selon ce niveau de sensibilité, les engagements suivants sont attendus du FS :"
  pdf.table([
    [
      "",
      "Niveau 1",
      "Niveau 2",
      "Niveau 3"
    ], [
      "Conditions préalables à la mise en production",
      "Ne pas avoir de vulnérabilité résiduelle de niveau CVSS v34 supérieur ou égal à 9 (critique)",
      "Ne pas avoir de vulnérabilité résiduelle de niveau CVSS v3 supérieur ou égal à 7 (haut)",
      "Ne pas avoir de vulnérabilité résiduelle de niveau CVSS v3 supérieur ou égal à 4 (moyen)"
    ], [
      "Renouvellement de l'homologation de sécurité (durée maximale)",
      "5 ans",
      "5 ans",
      "3 ans"
    ]
  ])
end
