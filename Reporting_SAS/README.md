# Projet SAS

La question de l'impact de l'exposition aux risques environnementaux sur la mortalité, la morbidité et le bien-être économique est un sujet de préoccupation croissant à travers le monde. Les pays les moins avancés (PMA) sont particulièrement exposés aux risques environnementaux, tandis que les pays développés disposent généralement de moyens plus importants pour faire face à ces risques. Cependant, il est important de comprendre les différences et les similitudes dans la manière dont ces deux groupes de pays sont affectés par les risques environnementaux. Pour notre analyse, nous nous sommes focalisés sur les décès prématurés et les coûts engendrés par ces décès.

Pour notre étude nous disposons d’une base de données brute composée de 21 variables et d'un million d'observations pour examiner les impacts de l'exposition aux risques environnementaux sur la mortalité, la morbidité et le bien-être économique entre les pays les moins avancés et les pays développés. Après nettoyage de notre base de données, nous travaillons sur 88 416 observations et 18 variables. Dans un premier temps, nous allons étudier la situation des pays développés en examinant les données sur les risques environnementaux, la mortalité, la morbidité et le bien-être économique.
Dans un second temps, nous analyserons la situation pour les pays les moins avancés. Enfin, dans un troisième temps nous allons comparer ces deux groupes de pays pour mettre en évidence les différences et les similitudes dans les impacts des risques environnementaux sur ces derniers.

Afin de permettre à l'utilisateur d'explorer différents angles d'analyse sur le sujet, nous avons mis en place un code interactif qui lui donne la possibilité de sélectionner différents paramètres tels que :
- Deux pays à analyser
- Âge
- Sexe (MALE, FEMALE, BOTH)
- Deux risques (NHANDW, O3, PB, PM_2_5_OUT, RN, USAN, UWATS)
- Année
- Groupe de pays (PMA, PDV)
  
Par défaut, les paramètres seront :
- pays_choisi = 'FRA'
- pays_choisi2 = 'DJI'
- age_choisi= 'ALL'
- sexe_choisi='BOTH'
- risk_choisi='PM_2_5_OUT'
- risk_choisi2='O3'
- annee_choisi='2019'
  
Pour finir, le PDF "Notice_projet" regroupe une présentation de la base de données (procédure contents) et une explication détaillée du code SAS réalisé, incluant les parties PDF, HTML et PowerPoint. Il rassemble tout le travail effectué et facilite l'utilisation du code.
