
/*-----PROJET SAS-----*/			

/*-Macro-variables-*/

/*Chemins*/
/*lien de la base de données*/
%let chemin = "/home/u57945759/sasuser.v94/M2 TIDE/Études de cas SAS/EXP_MORSC_10112022100543813.csv";
/*lien du dossier de sortis outputs (SAS Studio)*/
%let outlink = /home/u57945759/sasuser.v94/M2 TIDE/PROJET_SAS_3 ;


/*Choix de l'utilisateur */

%let pays_choisi = 'FRA' ;
%let pays_choisi2 = 'COD';
%let age_choisi= 'ALL';
%let sexe_choisi='BOTH';
%let risk_choisi='PM_2_5_OUT';
%let risk_choisi2='O3';
%let stylereport = 	split = '@'
	style(header)= {background = lavender verticalalign=middle}  
	style(column)={background = white} ;
%let stylefootnote = height = 3 justify = left ;
%let annee_choisi='2019';

/* Création de macro-variable pays_developpe et PMA. */
data _null_;
  length pays $1024;
  pays = "AFG AGO ALB AND ARG ARM ASM ATG AUS AUT AZE BDI BEL BEN BFA BGD BGR BHR BHS BIH BLR BLZ BMU BOL BRA BRB BRN BTN BWA CAF CAN CHL CHN CIV CMR COD COG COL COM CPV CRI CUB CYP CZE DJI DMA DNK DOM DZA ECU EGY ERI EST ETH FIN FJI FRA GHA GNB GNQ GRC GRD HRV KHM PRK SLV TCD";
  call symput("pays",pays);
run;

%let PMA = 'AFG' 'AGO' 'BEN' 'BFA' 'BDI' 'KHM' 'COM' 'DJI' 'ERI' 'ETH' 'GNB' 'CAF' 'COD' 'TCD';
%let pays_developpe = 'ALB' 'AND' 'ARG' 'ARM' 'ASM' 'ATG' 'AUS' 'AUT' 'AZE' 'BEL' 'BGD' 'BGR' 'BHR' 'BHS' 'BIH' 'BLR' 'BLZ' 'BMU' 'BOL' 'BRA' 'BRB' 'BRN' 'BTN' 'BWA' 'CAN' 'CHL' 'CHN' 'CIV' 'CMR' 'COG' 'COL' 'CPV' 'CRI' 'CUB' 'CYP' 'CZE' 'DMA' 'DNK' 'DOM' 'DZA' 'ECU' 'EGY' 'EST' 'FIN' 'FJI' 'FRA' 'GHA' 'GNQ' 'GRC' 'GRD' 'HRV' 'PRK' 'SLV';

/*	 Chargement de la base de donnees	*/

/* Import de la base */
proc import out=my_data datafile= &chemin. 
	DBMS=csv replace;
	*guessingrows=max;
	getnames=YES;
run;

/* On a des colonnes répétées donc on garde seulement la version anglaise*/
data my_data;
    set my_data (keep= cou var risk sex age yea value);
run;
/* Data set réarrangé */
proc sort data=my_data (keep= cou var risk sex age yea value) out=my_data;
   by cou yea sex risk age;
run;

proc transpose data=my_data out=my_data (drop = _NAME_);
    by cou yea sex risk age;
    id var;
    var value;
run;

/* Creation d'une colonne PMA (pays les moins avancés) et PDV (pays en développement) */
DATA my_data;
    SET my_data;
 	IF COU IN ('AFG', 'AGO', 'BEN', 'BFA', 'BDI', 'KHM', 'COM', 'DJI', 'ERI', 'ETH', 'GNB', 'CAF', 'COD', 'TCD') THEN  COU_TYPE = "PMA" ;								
						ELSE   COU_TYPE = "PDV"  ;
RUN;

/* Formats */
proc format ;
	value $cou
	"AFG"="Afghanistan"
	"AGO"="Angola"
	"ALB"="Albanie"
	"AND"="Andorre"
	"ARG"="Argentine"
	"ARM"="Arménie"
	"ASM"="Samoa américaines"
	"ATG"="Antigua-et-Barbuda"
	"AUS"="Australie"
	"AUT"="Autriche"
	"AZE"="Azerbaïdjan"
	"BDI"="Burundi"
	"BEL"="Belgique"
	"BEN"="Benin"
	"BFA"="Burkina Faso"
	"BGD"="Bangladesh"
	"BGR"="Bulgarie"
	"BHR"="Bahreïn"
	"BHS"="Bahamas"
	"BIH"="Bosnie-Herzégovine"
	"BLR"="Biélorussie"
	"BLZ"="Belize"
	"BMU"="Bermudes"
	"BOL"="Bolivie"
	"BRA"="Brésil"
	"BRB"="Barbade"
	"BRN"="Brunei"
	"BTN"="Bhoutan"
	"BWA"="Botswana"
	"CAF"="République centrafricaine"
	"CAN"="Canada"
	"CHL"="Chili"
	"CHN"="Chine"
	"CIV"="Côte Ivoire"
	"CMR"="Cameroun"
	"COD"="République démocratique du Congo"
	"COG"="Congo"
	"COL"="Colombie"
	"COM"="Comores"
	"CPV"="Cap-Vert"
	"CRI"="Costa Rica"
	"CUB"="Cuba"
	"CYP"="Chypre"
	"CZE"="République tchèque"
	"DJI"="Djibouti"
	"DMA"="Dominique"
	"DNK"="Danemark"
	"DOM"="République Dominicaine"
	"DZA"="Algérie"
	"ECU"="Équateur"
	"EGY"="Egypte"
	"ERI"="Érythrée"
	"EST"="Estonie"
	"ETH"="Ethiopie"
	"FIN"="Finlande"
	"FJI"="Fidji"
	"FRA"="France"
	"GHA"="Ghana"
	"GNB"="Guinée-Bissau"
	"GNQ"="Guinée équatoriale"
	"GRC"="Grèce"
	"GRD"="Grenade"
	"HRV"="Croatie"
	"KHM"="Cambodge"
	"PRK"="Corée du Nord"
	"SLV"="El Salvador"
	"TCD"="Tchad";
	value $age 
		"LESSTHAN15"="Moins de 15 ans"
		"MORETHAN64"="Plus de 64 ans"
		"15TO64"="Entre 15 et 64 ans"
		"ALL"="Tout âge confondu";
	value $agegroup 
		"LESST"="Moins de 15 ans"
		"15TO6"="Entre 15 et 64 ans"
		"MORET"="Plus de 64 ans"
		"ALL"="Tout âge confondu";
	value $risk
	"NHANDW"="Pas accès pour le lavage des mains"
	"O3"="Exposition à lozone"
	"PB"="Exposition au plomb"
	"PM_2_5_OUT"="Exposition aux particules fines"
	"RN"="Exposition au radon residentiel"
	"USAN"="Assainissement insalubre"
	"UWATS"="Source d'eau non-potables";
	value $riskgroup
	"NHANDW"="Eau, assainissement et lavage des mains insalubres"
	"O3"="Pollution de l'air"
	"PB"="Autre risque environnemental"
	"PM_2_5_OUT"="Pollution de l'air"
	"RN"="Autre risque environnemental"
	"USAN"="Eau assainissement et lavage des mains insalubres"
	"UWATS"="Eau assainissement et lavage des mains insalubres";
	value $COU_TYPE
	"PMA"="Pays les moins avancés"
	"PDV"="Pays développés";
	value PDV_PMA_encoding
	2="Pays les moins avancés"
	1="Pays développées";	
run;



/* - - - - - - - - - - - - - - - - - - - - PDF- - - - - - - - - - - - - - - - - - - - */
options papersize=A4 
leftmargin=2.5cm 
rightmargin=2.5cm 
topmargin=2.5cm 
bottommargin=2.5cm 
nodate;

ods pdf file="&outlink.Notice_projet.pdf"
	style=Sapphire contents=YES notoc startpage=no;
	title color=crimson "ETUDE DE CAS SAS - Présentation Projet (PDF)";
	title2 color=lilac "Réalisé par Marie-Lou Baudrin, Claire Gefflot, Romain Pénichon";
	footnote justify=right color=navy height=10pt "Master TIDE - 2022/2023";

ods proclabel "1. Introduction";
proc odstext;
	h1 "1. Introduction" / style=systemtitle;
proc odstext;
	p "								La question de l'impact de l'exposition aux risques environnementaux sur la mortalité, la morbidité et le bien-être économique est un sujet de préoccupation croissant à travers le monde. 
	Les pays les moins avancés (PMA) sont particulièrement exposés aux risques environnementaux, tandis que les pays développés disposent généralement de moyens plus importants pour faire face à ces risques. 
	Cependant, il est important de comprendre les différences et les similitudes dans la manière dont ces deux groupes de pays sont affectés par les risques environnementaux. Pour notre analyse, nous nous sommes focalisés sur les décès prématurés et les coûts engendrés par ces décès." /style = {FONT_SIZE=10pt};
	p "								Pour notre étude nous disposons d’une base de données brute composée de 21 variables et d'un million d'observations pour examiner les impacts de l'exposition aux risques environnementaux sur la mortalité, la morbidité et le bien-être économique entre les pays les moins avancés et les pays développés. 
	Après nettoyage de notre base de données, nous travaillons sur 88 416 observations et 18 variables." /style = {FONT_SIZE=10pt};
	p "								Dans un premier temps, nous allons étudier la situation des pays développés en examinant les données sur les risques environnementaux, la mortalité, la morbidité et le bien-être économique." /style = {FONT_SIZE=10pt};
	p "								Dans un second temps, nous analyserons la situation pour les pays les moins avancés." /style = {FONT_SIZE=10pt}; 
	p "								Enfin, dans un troisième temps nous allons comparer ces deux groupes de pays pour mettre en évidence les différences et les similitudes dans les impacts des risques environnementaux sur ces derniers." /style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;
proc odstext;
	p "								Afin de permettre à l'utilisateur d'explorer différents angles d'analyse sur le sujet, nous avons mis en place un code interactif qui lui donne la possibilité de sélectionner différents paramètres tels que :" /style = {FONT_SIZE=10pt};
	p "- Deux pays à analyser" /style = {FONT_SIZE=10pt};
	p "- Âge" /style = {FONT_SIZE=10pt};
	p "- Sexe (MALE, FEMALE, BOTH)" /style = {FONT_SIZE=10pt};
	p "- Deux risques (NHANDW, O3, PB, PM_2_5_OUT, RN, USAN, UWATS)" /style = {FONT_SIZE=10pt};
	p "- Année" /style = {FONT_SIZE=10pt};
	p "- Groupe de pays (PMA, PDV)" /style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;
proc odstext;
	p "Par défaut, les paramètres seront :"/style = {FONT_SIZE=10pt};
	p "- pays_choisi = 'FRA'" /style = {FONT_SIZE=10pt};
	p "- pays_choisi2 = 'DJI'" /style = {FONT_SIZE=10pt};
	p "- age_choisi= 'ALL'" /style = {FONT_SIZE=10pt};
	p "- sexe_choisi='BOTH'" /style = {FONT_SIZE=10pt};
	p "- risk_choisi='PM_2_5_OUT'" /style = {FONT_SIZE=10pt};
	p "- risk_choisi2='O3'" /style = {FONT_SIZE=10pt};
	p "- annee_choisi='2019'" /style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;
proc odstext;
	p "Pour finir, ce PDF regroupe une présentation de la base de données (procédure contents) et une explication détaillée du code SAS réalisé, incluant les parties PDF, HTML et PowerPoint. 
	Il rassemble tout le travail effectué et facilite l'utilisation du code."/style = {FONT_SIZE=10pt};
run;

title;
title2;
ods pdf startpage=now;
ods proclabel "2. Description de la base de données";
proc odstext;
	h1 "2. Description de la base de données" / style=systemtitle;
run;
proc odstext;
	p "Notre base de données nettoyée MY_DATA contient 88 416 observations et 18 variables. Les variables sont :" /style = {FONT_SIZE=10pt};
	p "- AGE (Texte), la tranche d'âge"/style = {FONT_SIZE=10pt}; 
	p "- COU (Texte), le code pays"/style = {FONT_SIZE=10pt}; 
	p "- COU_TYPE (Texte), le type de pays : pays les moins avancés (PMA) ou pays développés (PDV)"/style = {FONT_SIZE=10pt}; 
	p "- DALY_CAP (Numérique), AVCI (Annualized Value of a Statistical Life-year) par milliers d'habitants"/style = {FONT_SIZE=10pt}; 
	p "- DALY_ST (Numérique), pourcentage des AVCI totales"/style = {FONT_SIZE=10pt}; 
	p "- DALY_V (Numérique), AVCI" /style = {FONT_SIZE=10pt}; 
	p "- MOR_CAP (Numérique), décès prématurés par million d'habitants "/style = {FONT_SIZE=10pt}; 
	p "- MOR_ST (Numérique), pourcentage des décès prématurés totales "/style = {FONT_SIZE=10pt}; 
	p "- MOR_V (Numérique), décès prématurés"/style = {FONT_SIZE=10pt}; 
	p "- RISK (Texte), risques environnementaux"/style = {FONT_SIZE=10pt}; 
	p "- SC_CAP (Numérique), coûts en bien-être des décès prématurés en USD par habitant "/style = {FONT_SIZE=10pt}; 
	p "- SC_GDP (Numérique), coûts en bien-être des décès prématurés en pourcentage équivalent au PIB"/style = {FONT_SIZE=10pt}; 
	p "- SC_ST (Numérique), pourcentage coûts totales en bien-être des décès prématurés"/style = {FONT_SIZE=10pt}; 
	p "- SC_V (Numérique), coûts en bien-être des décès prématurés en million 2015 USD PPP"/style = {FONT_SIZE=10pt}; 
	p "- SEX (Texte), le sexe"/style = {FONT_SIZE=10pt}; 
	p "- VSL_NC (Numérique), value of a statistical life en million national currency current price"/style = {FONT_SIZE=10pt}; 
	p "- VSL_USD (Numérique), value of a statistical life en million 2015 USD PPP "/style = {FONT_SIZE=10pt}; 
	p "- YEA (Texte)."/style = {FONT_SIZE=10pt};
run;


proc contents data=work.my_data;
	format cou $cou. age $age. risk $risk.;
run;


ods pdf startpage=now;
ods proclabel "3. Le script SAS ";
proc odstext;
	h1 "3. Le script SAS" / style=systemtitle;
run;

ods proclabel "     3.1. Macro-variables et formats";
proc odstext;
	h2 "3.1. Macro-variables et formats" / style={fontweight=bold color=cornflowerblue};
	p"Les macro-variables sous SAS servent à stocker des valeurs qui peuvent être réutilisées plusieurs fois dans un programme SAS. Ces valeurs peuvent être des textes, des nombres, des dates, etc.
	Cela rend le code interactif. Comme expliqué précedemment, nous avons mis en place un code dynamique qui donne la possibilité à l'utilisateur de sélectionner différents paramètres." /style = {FONT_SIZE=10pt}; 
proc odstext;
	p" ";
run;
proc odstext;
	p "Pour modifier ces paramètres, vous devez modifier la partie du code nommé 'Macro-variables'.
	Par exemple, si vous souhaitez étudier le Canada vous avez juste à modifier ce code : let pays_choisi = 'CAN' ; en remplaçant 'FRA' par 'CAN'." /style = {FONT_SIZE=10pt};
	p "Les macro-variables pouvant être modifiées sont :"/style = {FONT_SIZE=10pt};
	p "- chemin : lien qui mène a la base de données EXP_MORSC_10112022100543813.csv" /style = {FONT_SIZE=10pt};
	p "- outlink : lien du dossier de sortie des outputs" /style = {FONT_SIZE=10pt};
	p "- pays_choisi et pays_choisi2 : Choix de deux pays à analyser" /style = {FONT_SIZE=10pt};
	p "- age_choisi : Classe d'âge choisie" /style = {FONT_SIZE=10pt};
	p "- sexe_choisi : Choix du sexe (MALE, FEMALE, BOTH)" /style = {FONT_SIZE=10pt};
	p "- risk_choisi et risk_choisi2 : Choix de deux risques (NHANDW, O3, PB, PM_2_5_OUT, RN, USAN, UWATS)" /style = {FONT_SIZE=10pt};
	p "- annee_choisi : Choix de l'année" /style = {FONT_SIZE=10pt};
	p "- Groupe de pays (PMA, PDV) => Ce n'est pas une macro-variable mais une colonne créée dans le dataframe. On peut donc choisir un groupe de pays à étudier en incluant une fonction : WHERE COU_TYPE = 'PMA'; ou WHERE COU_TYPE = 'PDV';" /style = {FONT_SIZE=10pt};
	p "Les macro-variables peuvent être modifiées à chaque fois que le script est relancé et vous permettront de réaliser une infinité de combinaisons différentes." /style = {FONT_SIZE=10pt};
	p "L'entièreté des choix possibles pour chaque macro-variables sera disponible en annexe." /style = {FONT_SIZE=10pt fontweight=bold color=red};
run;
proc odstext;
	p" ";
run;
proc odstext;
	p "Par défaut, les paramètres choisis sont :"/style = {FONT_SIZE=10pt};
	p "- pays_choisi = 'FRA'" /style = {FONT_SIZE=10pt};
	p "- pays_choisi2 = 'DJI'" /style = {FONT_SIZE=10pt};
	p "- age_choisi= 'ALL'" /style = {FONT_SIZE=10pt};
	p "- sexe_choisi='BOTH'" /style = {FONT_SIZE=10pt};
	p "- risk_choisi='PM_2_5_OUT'" /style = {FONT_SIZE=10pt};
	p "- risk_choisi2='O3'" /style = {FONT_SIZE=10pt};
	p "- annee_choisi='2019'" /style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;
proc odstext;
	p "Enfin pour améliorer la lisibilité des classes, nous avons utilisé divers formats sur la base de données." /style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;

ods proclabel "     3.2. Partie PDF";
proc odstext;
	h2 "3.2. Partie PDF" / style={fontweight=bold color=cornflowerblue};
	p "Le script PDF est la notice qui explique l'entièreté du code. 
	C'est dans cette partie du script où se trouve le code qui a permis de générer cette notice. 
	Il est important de noter que le fichier PDF sera créé à l'emplacement spécifié précédemment dans la macro-variable 'outlink'."/style = {FONT_SIZE=10pt};
run;
proc odstext;
	p" ";
run;

ods pdf startpage=now;
ods proclabel "     3.3. Partie HTML";
proc odstext;
	h2 "3.3. Partie HTML" / style={fontweight=bold color=cornflowerblue};
	p "Dans cette section se trouve le code qui permet de créer les tableaux et les graphiques utilisés pour notre analyse."/style = {FONT_SIZE=10pt};
run;
proc odstext;
	p"La partie HTML est divisée en trois parties : "/style = {FONT_SIZE=10pt fontweight=bold};
run;
proc odstext;
	p"I. Exposition aux risques environnementaux dans les pays développés"/style = {FONT_SIZE=10pt};
	p"II. Analyse des risques environnementaux pour les pays les moins avancés (PMA)"/style = {FONT_SIZE=10pt};
	p"III. Comparaison entre les pays développés et les PMA"/style = {FONT_SIZE=10pt};
run;

proc odstext;
	p" ";
run;

ods proclabel "     3.4. Partie PPT";
proc odstext;
	h2 "3.4. Partie PPT" / style={fontweight=bold color=cornflowerblue};
	p "Cette dernière partie comporte le code qui génère le document powerpoint affichant les différentes cartes, tableaux et descriptions que nous présenterons à l'oral. "/style = {FONT_SIZE=10pt};
	p "Le script du PPT comporte les mêmes macro-variables que le script du PDF et du HTML."/style = {FONT_SIZE=10pt};
	p " La partie PPT est divisée en 5 parties : "/style = {FONT_SIZE=10pt fontweight=bold};
	p "I. Introduction"/style = {FONT_SIZE=10pt};
	p "II. Exposition aux risques environnementaux dans les pays développés" /style = {FONT_SIZE=10pt};
	p "III. Analyse des risques environnementaux pour les pays les moins avancés (PMA)" /style = {FONT_SIZE=10pt};
	p "IV. Comparaison entre les pays développés et les PMA" /style = {FONT_SIZE=10pt};
	p "V. Conclusion" /style = {FONT_SIZE=10pt};
run;


ods pdf startpage=now;
ods proclabel "4. Annexes";
proc odstext;
	h1 "4. Annexes" / style=systemtitle;
run;
ods proclabel "     4.1. Valeurs uniques pour chaque macro-variable";
proc odstext;
	h2 "4.1. Valeurs uniques pour chaque macro-variable" / style={fontweight=bold color=cornflowerblue};
	p "pays_choisi et pays_choisi2"/ style={FONT_SIZE=10pt fontweight=bold};
run;

proc sql;
  create table work.my_data1 as
  select COU as Code_Pays, COU
  from work.my_data;
quit;

proc datasets lib=work noprint;
    modify my_data1;
    rename COU = Pays;
run;

proc sql;
select distinct Code_Pays,Pays format=$cou.
from work.my_data1;
quit;

proc odstext;
	p "age_choisi"/ style={FONT_SIZE=10pt fontweight=bold};
run;

proc sql;
  create table work.my_data2 as
  select AGE as Tranche_âge, AGE
  from work.my_data;
quit;

proc datasets lib=work noprint;
    modify my_data2;
    rename AGE = Libellé_âge;
run;

proc sql;
select distinct Tranche_âge,Libellé_âge format=$agegroup.
from work.my_data2;
quit;






proc odstext;
	p "sexe_choisi"/ style={FONT_SIZE=10pt fontweight=bold};
run;
proc sql;
select distinct SEX
from work.my_data;
quit;

proc odstext;
	p "risk_choisi et risk_choisi2"/ style={FONT_SIZE=10pt fontweight=bold};
run;

proc sql;
  create table work.my_data3 as
  select risk as Risque, risk
  from work.my_data;
quit;

proc datasets lib=work noprint;
    modify my_data3;
    rename risk = Libellé_risque;
run;

proc sql;
select distinct Risque,Libellé_risque format=$risk.
from work.my_data3;
quit;


proc odstext;
	p "annee_choisi"/ style={FONT_SIZE=10pt fontweight=bold};
run;
proc sql;
select distinct YEA
from work.my_data;
quit;

ods pdf close;


/* - - - - - - - - - - - - - - - - - - - - HTML- - - - - - - - - - - - - - - - - - - - */


ods noproctitle ; * Enlève le nom des procédures ; 

filename output "/home/u57945759/sasuser.v94/M2 TIDE/PROJET_SAS_3"; 
ods html body="/sortie_finale.html" path=output;


proc odstext ;
     p 'PROJET ETUDES DE CAS (HTML)' / style=[fontsize=10pt color=crimson font_face='Arial Black' just=c];
     p 'Réalisé par: Marie-Lou Baudrin, Claire Gefflot, Romain Pénichon.' / style=[fontsize=10pt color=lilac font_face='Arial Black' just=c];
run;
proc odstext;
	p" ";
run;
proc odstext;
     p 'SOMMAIRE' / style=[fontsize=12pt color=lilac font_face='Arial Black' just=l];
run;
proc odstext;
     p 'I. Exposition aux risques environnementaux dans les pays développés' / style=[fontsize=10pt color=cornflowerblue font_face='Arial Black' just=l];
     p 'II. Analyse des risques environnementaux pour les pays les moins avancés (PMA)' / style=[fontsize=10pt color=cornflowerblue font_face='Arial Black' just=l];
     p 'III. Comparaison entre les pays développés et les PMA' / style=[fontsize=10pt color=cornflowerblue font_face='Arial Black' just=l];
run;

proc odstext;
	p" ";
run;
proc odstext;
	p"I. Exposition aux risques environnementaux dans les pays développés" / style=[fontsize=12pt color=cornflowerblue fontweight=bold font_face='Arial Black' just=c];
run;
					
					
					/* ANALYSE DESCRIPTIVE PAYS DEVELOPPE*/ ;

/* Tableau représentant la somme des décès prématurés pour chaque PMA et risque. */
PROC TABULATE DATA=my_data F=9.;
	WHERE COU_TYPE = "PDV";
	CLASS COU RISK / STYLE = [just=c background=LightGreen] ;
	classlev COU / s={background=LightGreen};
	classlev RISK / s={background=LightGreen};
	VAR MOR_V / STYLE = [just=c background=LightGreen] ;
	TABLES COU="Pays",RISK="Risques"*(MOR_V=""*(SUM=""*F=NLNUM15.)) ;
	FORMAT cou $cou. risk $risk. ;
	TITLE "Tableau représentant la somme des décès prématurés pour chaque pays développé et risque.";
RUN;

					
/*PROC REPORT pour un pays choisi développé pour tout sexe, age, pour tout risque pour la var MOR_V depuis 2005*/
ods proclabel "Report des décès prématurés du pays développé choisi " ;
%macro P_C_PDV(cou_type=, color=, pays__choisi=, descriptif=);
PROC REPORT DATA=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays__choisi.) & AGE in ('ALL'))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN YEA RISK MOR_V VSL_USD Cout MOR_V=MOR_V2;
  DEFINE YEA/ "Année" DISPLAY;
  DEFINE  RISK/ "Risque" GROUP;
  DEFINE  MOR_V/ SUM "Nombre de décès prématurés ";
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  DEFINE MOR_V2 / analysis median noprint;
  
  break before risk / summarize;
  compute before risk;
  MOR_V_median = median(MOR_V2);
		extra=catx('',risk,'a engendré ',put(MOR_V.SUM,8.), 'décès prématurés depuis 2005 dans le ', &cou_type.,' choisi : '&pays__choisi.);
		line extra $150.;
  endcomp;
  
  break after risk / style={Font_style=italic Backgroundcolor=&color.};
  compute after risk;
  line '';
  endcomp;
 
  compute after;
  		Risk='Total';
  endcomp;
  
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_median THEN CALL DEFINE('_C1_','STYLE','STYLE={color=red}');
  ENDCOMP;
  
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
  compute Cout;
	Cout=MOR_V.SUM*VSL_USD.MEDIAN;
  endcomp;
 
  rbreak after/ summarize style={Font_style=italic Backgroundcolor=lightgoldenrodyellow};
  
  format cou $cou. age $age. risk $risk.;
  title "Reporting général sur le pays en &cou_type. : &pays__choisi.";
		ods text= "Le tableau ci-dessous représente les décès prématurés de chaque risque pour le &cou_type. choisi: &pays__choisi.. Les années dont la part de décès est supérieur au nombre de décès médian par risque étudié sont marqués en rouge. &descriptif. ";

RUN;
%mend P_C_PDV;
%P_C_PDV(cou_type='PDV', color=LightGreen, pays__choisi=&pays_choisi.)


ods proclabel "Graphique 1.1: Nombre de décés prématurés par risque pour le pays développé: &pays_choisi." ;

/*HISTOGRAMME du nb de décés par risque depuis 2005 pour un pays choisi développé pour tout sexe, age,;*/
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays_choisi.) & AGE in ('ALL')));
   vbar risk / response=MOR_V;
   yaxis grid;
   xaxis grid;
   xaxis label='Risques';
   yaxis label='Nombre de décès prématurés';
   title 'Nombre de décés prématurés par risque pour le pays développé: '&pays_choisi. ' depuis 2005';
   format risk $risk.;
   run;		
					

/* Evolution des décés prématurés pour tous les risques dans le pays développé choisi*/
ods proclabel "Graphique 1.2 : Evolution des décès prématurés par risque pour le pays développé: &pays_choisi" ;
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=( YEA > '2004' & SEX in ('BOTH') & COU in (&pays_choisi.) & risk in ('O3','NHANDW','PB','PM_2_5_OUT','RN','USAN','UWATS')& AGE in ('ALL')));
  series x=YEA y=MOR_V / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Nombre de décès prématurés';
  title "Evolution des décès prématurés pour les différents risques du pays développé : &pays_choisi.";
		ods text= "Le graphique ci-dessous représente les décès prématurés de chaque risque pour le pays développé choisi: &pays_choisi..";
  format risk $risk.;
run;



%macro e_v_d_type_country(cou__type=, color=, total=, descriptif=);
PROC REPORT DATA=my_data (where=(YEA>'2004' & SEX in ('BOTH') & AGE in ('ALL') & cou_type in (&cou__type.))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN  RISK YEA MOR_V ratio_deces_par_pays VSL_USD CoutM ;
  DEFINE  YEA/ group "Année";
  DEFINE  RISK/ GROUP "Risques" style={background=&color.};
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';

  define ratio_deces_par_pays/computed f=10. "Nombre de décès / moyen par pays";
  compute ratio_deces_par_pays;
  if &cou__type.= 'PMA' then ratio_deces_par_pays= ROUND(MOR_V.sum/14);
  else if  &cou__type.= 'PDV' then ratio_deces_par_pays= ROUND(MOR_V.sum/(67-14));
  endcomp;
  
  compute after risk;
		extra=catx('',risk,'a engendré ', put(MOR_V.SUM , 10.), 'décès prématurés, soit', put((MOR_V.SUM/&total.)*100,10.2), '% des décès prématurés entre 2005 et 2019 parmi les risques environnementaux étudiés.');
		line extra $1500.;
  endcomp;
  
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  define CoutM / COMPUTED format=dollar12. 'Coût moyen par pays des/ décès prématurés en/millions de dollars';
  compute CoutM;
	CoutM=ratio_deces_par_pays*VSL_USD.MEDIAN;
  endcomp;
  
  rbreak after / summarize style={Font_style=italic Backgroundcolor=lightgoldenrodyellow};
  compute after;
  		Risk='Total' ;
  endcomp;

  title "Nombre de décès moyen et coût moyen de ces décès par risque de 2005 à 2019 pour les &cou__type.";
  ods text= "Le tableau ci-dessous représente les décès prématurés et le nombre de décès moyen pour les &cou__type. par risque environnemental. Ces données concernent tout les sexes et tranches d'âges entre 2005 et 2019. / &descriptif. "; 
  format cou $cou. cou_type $cou_type. age $age. risk $risk.;
RUN;
%mend e_v_d_type_country;
%e_v_d_type_country(cou__type='PDV', color=LightGreen, total=34980291, descriptif='On peut voir ici que le risque premier pour les pays développés est l exposition aux particules fines. En effet, l exposition aux particules fines est un problème de santé publique majeur dans les pays développés. Les particules fines sont des particules de diamètre inférieur à 2,5 micromètres, qui peuvent pénétrer profondément dans les poumons. Les sources principales de particules fines dans les pays développés incluent les émissions de véhicules, les centrales électriques à combustion, les activités industrielles et les incendies de forêt. Toutes ces causes étant intrinsèquement liées à la surpopulation et la surconsommation présentes dans les pays développés.  Les études montrent que l exposition aux particules fines est liée à une augmentation du risque de maladies cardiaques, d accidents vasculaires cérébraux, de cancer du poumon et de mortalité prématurée. Entre 2005 et 2019, on a recensé plus de 23,8 millions de décès prématurés imputés à ce risque dans les pays développés, soit environ 1,6 millions par an. Si on regarde le coût financier de ces décès, pour les pays développés, cela est estimé à environ 50 milliards de dollars par an.
En seconde position, on retrouve l exposition au plomb qui, même si son exposition a considérablement diminué ces dernières décennies en raison de la réglementation des produits contenant du plomb, reste un problème de santé publique majeur dans les pays développés.
L exposition au plomb dans les pays développés se fait par l air, l eau potable, les aliments, le sol et les matériaux de construction. Les études montrent que l exposition au plomb est liée à des effets négatifs sur la santé tels que les troubles neurodéveloppementaux chez les enfants, les troubles de la cognition chez les adultes et les maladies cardiaques.');


/* Graphique comparatif de l'évolution des décès par risque pour le type de pays choisi*/
%macro graph_e_v_d_by_risk_type_country(cou_type=, color=, out=, descriptif=);
ods select none;
PROC REPORT DATA=my_data (where=(YEA>='2005' & SEX in ('BOTH') & AGE in ('ALL'))) STYLE(HEADER)=[BACKGROUND=&color.] out=&out.;
  where cou_type=&cou_type.;
  COLUMN  RISK YEA MOR_V ratio_deces_par_pays country_type;
  DEFINE YEA/ group "Année";
  DEFINE  RISK/ GROUP "Risques" style={background=&color.};
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  
  DEFINE  country_type/ computed WIDTH=16 CENTER;
  compute country_type;
  if &cou_type.='PDV' then country_type = 1;
  else country_type = 2;
  endcomp;
  
  define ratio_deces_par_pays/computed f=10.2 "Nombre de décès moyen par pays";
  compute ratio_deces_par_pays ;
  if &cou_type.= 'PMA' then ratio_deces_par_pays= MOR_V.sum/14;
  else ratio_deces_par_pays= MOR_V.sum/(67-14);
  endcomp;
  
  format cou $cou. cou_type $cou_type. age $age. risk $risk.;
RUN;
ods select all;

ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=&out. ;
  series x=YEA y=ratio_deces_par_pays / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès moyens par pays, par risque pour les &cou_type.." ;
  ods text= "Ce graphique compare l'évolution des décès moyens par pays, par risque parmis les &cou_type., pour tout âge et sexe entre 2005 et 2019./ &descriptif. ";
run;
%mend graph_e_v_d_by_risk_type_country;
%graph_e_v_d_by_risk_type_country(cou_type='PDV', color=LightGreen, out=ratio_deces_par_pays, descriptif= 'On peut observer que les données montrent une tendance à la hausse du nombre de décès prématurés dû à l exposition aux particules fines. Cependant on peut voir un stagnation ou une lègère baisse des décès prématurés dû aux autres risques. Ilfaut noter que des fluctuations annuelles peuvent varier entre chaque risque.');


/*Tableau intéractif Nombre de décès prématurés par PDV selon année, sexe et âge*/  
%macro P_M_by_r_for_c(cou_type=, color=, descriptif=);
PROC REPORT DATA=my_data (where=(YEA in (&annee_choisi.) & SEX in (&sexe_choisi.) & AGE in (&age_choisi.) & RISK in (&risk_choisi.))) STYLE(HEADER)=[BACKGROUND=&color.];
  where cou_type=&cou_type.;
  COLUMN COU  MOR_V  VSL_USD COUT;
  DEFINE COU / GROUP "Pays";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés' ;
  
  compute after cou;
  call define(_ROW_,'STYLE','style={background=&color.}');
  line ' ';
  endcomp;
  DEFINE VSL_USD/ MEDIAN noprint;
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
  compute Cout;
	Cout=MOR_V.SUM*VSL_USD.MEDIAN;
  endcomp;

  compute after / style={Font_style=italic Backgroundcolor=&color.};
  cou='Total';
  extra=catx("","En ", &annee_choisi., "on a recensé ",put(MOR_V.SUM,8.), " décès prématurés dans les ", &cou_type., "dus au risque", &risk_choisi.,".");
		line extra $150.;
  endcomp;
  
  format cou $cou. cou_type $cou_type. age $age. ;
  title "Nombre de décès prématurés et coût associé en &annee_choisi. pour chaque &cou_type. et pour le risque &risk_choisi.. ";
    	ods text="Ce tableau recense le nombre de décès prématurés par &cou_type. pour le risque choisi &risk_choisi., selon la classe d'âge sélectionnée: &age_choisi., le sexe choisi: &sexe_choisi. ainsi que l'année choisie &annee_choisi. / &descriptif.."; 
RUN;
%mend P_M_by_r_for_c;
%P_M_by_r_for_c(cou_type='PDV', color=LightGreen);


								/*----COMPARAISONS PDV-----*/

/*Comparaison sexe - décès prématurés pour tous les pays développés;*/
ods proclabel "Comparaison des décès prématurés selon les classes d'âge pour les pays développés " ;
%macro P_M_by_r_sex_for_c(cou_type=, color=, descriptif=);
PROC REPORT DATA=my_data (where=((YEA >='2005') & SEX in ('FEMALE','MALE'))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN RISK SEX MOR_V rapport VSL_USD COUT ;
  where age ^= "ALL" and cou_type=&cou_type.;
  DEFINE risk/ group "Risques";
  DEFINE sex/ group "Sexe";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';

  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;
  compute after risk;
  extra=catx('',risk,' a engendré ',put(MOR_V.SUM,8.), 'décès prématurés dans les', &cou_type., ' entre 2005 et 2019.');
		line extra $150.;
  risk = ' ';
  line ' ' ;
  endcomp;
  
  break after risk / style={Font_style=italic Backgroundcolor=&color.};
  
  define rapport / computed format=percent8.2 "Proportion de décès prématurés"; 
  compute rapport;
  rapport = MOR_V.sum/MOR_V_sum_by_year ;
  endcomp;
DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/1.8 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
	compute Cout;
		Cout=MOR_V.SUM*VSL_USD.MEDIAN;
	endcomp;
 rbreak after / summarize;
  compute after;
  risk='Total';
  extra=catx('','De 2005 à 2019, on a recensé ',put(MOR_V.SUM,8.), ' décès prématurés dans les ',&cou_type.,' dus aux risques environnementaux énoncés.');
		line extra $150.;
  endcomp;
  
  title "Comparaison des décès prématurés selon le sexe pour les &cou_type.. " ;
  format cou $cou. cou_type $cou_type. risk $risk. age $agegroup.;
  	ods text= "L'objectif est de représenter les décès prématurés par risque selon le sexe. Cela nous permet d'effectuer une comparaison sur l'impact qu'à un certain risque sur une population en particulier. Les données sont prises sur l'ensemble des &cou_type. entre 2005 et 2019 et pour les populations de tout âge. Les catégories de sexe dont la part de décès est significativement plus élevés (> 55%) par risque étudié sont marqués en rouge. / &descriptif."; 
RUN;
%mend P_M_by_r_sex_for_c;
%P_M_by_r_sex_for_c(cou_type='PDV', color=LightGreen, descriptif='Il est important de noter que le coût d une vie humaine est estimé à 1,59 million de dollars pour chaque risque environnemental. Le nombre total de décès prématurés recensés entre 2005 et 2019 est de 33 976 760 dus aux risques environnementaux énoncés.');



/* Comparaison H/F par pays */
/*Pourcentage de mort par risque, par sexe pour chaque pays;*/
%macro P_M_by_r_s_for_c(cou_type=, color=, descriptif=);
PROC REPORT DATA=my_data STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN COU sex MOR_V rapport ;
  where sex ^= "BOTH" and age ^= "ALL" and YEA >= "2005" and cou_type=&cou_type.;
  DEFINE COU/ GROUP "Pays" style={background=&color.};
  DEFINE sex/ group "Sexe";
  DEFINE  MOR_V/ sum noprint;
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/1.8 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;
    
  compute before cou;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;
  compute after cou;
  line '';
  endcomp;
  define rapport / computed format=percent8.2 "Proportion de décès prématurés par pays"; 
  compute rapport;
  rapport = MOR_V.sum/MOR_V_sum_by_year ;
  endcomp;
  
  title "Comparaison du nombre de décès prématurés selon le sexe pour chaque " &cou_type.;
  ods text= "L'objectif ici est de comparer le nombre décès prématurés entre les femmes et les hommes et ce, par pays. Les données sont prises sur les populations de tout âge des &cou_type. entre 2005 et 2019. /
  Lorsqu'il y a un des deux sexes a plus de 55 pourcent de décès, alors il sera désigné en rouge / &descriptif.";
  format cou $cou. age $age.;
RUN;
%mend P_M_by_r_s_for_c;
%P_M_by_r_s_for_c(cou_type='PDV', color=LightGreen, descriptif='Il montre également que les hommes sont généralement plus touchés que les femmes pour la plupart des risques énoncés. Il est important de noter que les données peuvent varier considérablement entre les pays et que les coûts associés aux décès peuvent être incomplètes ou inexactes pour certains pays.');


/*Comparaison de l'impact du risque choisi sur les hommes et les femmes pour le pays développé choisi.*/
ods proclabel "Inegalités- Graphique" ;
	title " Comparaison de l'impact du risque &risk_choisi. sur les hommes et les femmes pour le pays développé: &pays_choisi..";	
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=( SEX in ('MALE','FEMALE') & COU in (&pays_choisi.) & risk in (&risk_choisi.)& AGE in ('ALL')));
	     series x=YEA y=MOR_V/ lineattrs=(thickness=2) group=sex;
		xaxis label='Année';
  		yaxis label='Nombre de décès prématurés';
		ods text= "Le graphique ci-dessous compare l'évolution du nombre de décès prématurés pour le pays &pays_choisi. selon le sexe.";
	format risk $risk. cou $cou.;
   	run;
	title;

/*Comparaison classe d'âge - décès prématurés pour tous les pays développés;*/
ods proclabel "Comparaison des décès prématurés selon les classes d'âge pour les pays développés " ;
%macro P_M_by_r_a_for_c(cou_type=, color=, descriptif=);
PROC REPORT DATA=my_data (where=((YEA >='2005') & SEX in ('BOTH'))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN RISK age MOR_V rapport VSL_USD COUT ;
  where age ^= "ALL" and cou_type=&cou_type.;
  DEFINE risk/ group "Risques";
  DEFINE age/ group "Age";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';

  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;
  
  compute after risk;
  extra=catx('',risk,' a engendré ',put(MOR_V.SUM,8.), 'décès prématurés dans les ', &cou_type.,' entre 2005 et 2019.');
		line extra $150.;
  risk = ' ';
  line ' ' ;
  endcomp;
  
  break after risk / style={Font_style=italic Backgroundcolor=&color.};
  
  define rapport / computed format=percent8.2 "Proportion de décès prématurés"; 
  compute rapport;
  rapport = MOR_V.sum/MOR_V_sum_by_year ;
  endcomp;
  
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
  compute Cout;
	Cout=MOR_V.SUM*VSL_USD.MEDIAN;
  endcomp;
  
  rbreak after / summarize;
  compute after;
  risk='Total';
  extra=catx('','De 2005 à 2019, on a recensé ',put(MOR_V.SUM,8.), ' décès prématurés dans les ', &cou_type.,' dus aux risques environnementaux énoncés.');
		line extra $150.;
  endcomp;
  
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/2.5 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;
  
  title "Comparaison des décès prématurés selon les classes d'âge pour les &cou_type.. " ;
  format cou $cou. cou_type $cou_type. risk $risk. age $agegroup.;
  	ods text= "L'objectif est de représenter les décès prématurés par risque selon chaque classe d'âge. Cela nous permet d'effectuer une comparaison sur l'impact qu'à un certain risque sur une population en particulier. Les données sont prises sur l'ensemble des &cou_type. entre 2005 et 2019. Les tranches d'âge dont la part de décès est supérieur à 40% par risque étudié sont marqués en rouge. / &descriptif."; 
RUN;
%mend P_M_by_r_a_for_c;
%P_M_by_r_a_for_c(cou_type='PDV', color=LightGreen, descriptif='Le tableau montre également le coût des décès en millions de dollars. Au total, 34020667 décès prématurés ont été recensés dans les PDV entre 2005 et 2019. De plus, le coût total des décès prématurés dus à ces risques environnementaux est évalué à 53,786,675 millions de dollars.');


proc odstext;
	p"II. Analyse des risques environnementaux pour les pays les moins avancés (PMA)" / style=[fontsize=12pt color=cornflowerblue fontweight=bold font_face='Arial Black' just=c];
run;


 /*----------ANALYSE DESCRIPTIVE PAYS LES MOINS AVANCÉS-----------*/

/* Tableau représentant la somme des décès prématurés pour chaque PMA et risque. */
PROC TABULATE DATA=my_data F=9.;
	WHERE COU_TYPE = "PMA";
	CLASS COU RISK / STYLE = [just=c background=LightOrange] ;
	classlev COU / s={background=LightOrange};
	classlev RISK / s={background=LightOrange};
	VAR MOR_V / STYLE = [just=c background=LightOrange] ;
	TABLES COU="Pays",RISK="Risques"*(MOR_V=""*(SUM=""*F=NLNUM15.)) ;
	FORMAT cou $cou. risk $risk. ;
	TITLE "Tableau représentant la somme des décès prématurés pour chaque PMA et risque.";
RUN;

ods proclabel "Report 2 " ;
%P_C_PDV(cou_type='PMA', color=LightOrange, pays__choisi=&pays_choisi2.);


/*HISTOGRAMME du nb de décés par risque depuis 2005 pour un pays choisi en developpement pour tout sexe, age,*/
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=(YEA>'2005' & SEX in ('BOTH')& COU in (&pays_choisi2.) & AGE in ('ALL')));
   vbar risk / response=MOR_V;
   yaxis grid;
   xaxis grid;
   xaxis label='Risques';
   yaxis label='Nombre de décès prématurés';
   title 'Nombre de décés prématurés par risque pour le pays en développement: '&pays_choisi2. ' depuis 2005';
   format risk $risk.;
   run;
  
  
/*Graphique comparatif des décés prématurés pour tous les risques dans le pays en développement choisi;*/
ods proclabel "Graphique 1 " ;
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=( SEX in ('BOTH') & COU in (&pays_choisi2.) & AGE in ('ALL')));
  series x=YEA y=MOR_V / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Nombre de décès prématurés';
  title "Evolution des décès prématurés au fil du temps pour les différents risques du pays en développement : &pays_choisi2.";
		ods text= "Le graphique ci-dessous représente les décès prématurés de chaque risque pour le pays en développement choisi: &pays_choisi2..";
format risk $risk.;
run;


/* évolution des décès par risque pour le type de pays choisi;*/
%e_v_d_type_country(cou__type='PMA', color=LightOrange, total=7760233, descriptif='On peut voir ici que le risque premier pour les PMA est le manque d eau potables et l assainissement insalubre. Entre 2005 et 2019, on a recensé plus de 2,86 millions de décès prématurés dû au manque d eau potable et plus de 2,13 millions de décès prématurés dû à l assainissement insalubre, soit environ 1,8 millions par an pour les eaux non-potable et 1,3 millions pour l assainissement insalubre. Si on regarde le coût financier de ces décès, cela est estimé à environ 1 à 2 milliards de dollars par an.');



/*Graphique comparatif de l'évolution des décès par risque pour le type de pays choisi;*/
%graph_e_v_d_by_risk_type_country(cou_type='PMA', color=LightOrange, out=ratio_deces_par_pays3);


/*Graphique comparatif de l'évolution des décès par type de pays pour un risque choisi*/
ods select none;
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
PROC REPORT DATA=my_data (where=(YEA>'2005' & SEX in ('BOTH') & AGE in ('ALL'))) out=ratio_deces_par_pays2;
  where cou_type = 'PMA';
  COLUMN cou RISK YEA MOR_V ;
  DEFINE cou/GROUP;
  DEFINE YEA/ group;
  DEFINE  RISK/ GROUP;
  DEFINE  MOR_V/ sum;
  format cou $cou. cou_type $cou_type. age $age. risk $risk.;
RUN;
ods select all;

ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=ratio_deces_par_pays2;
  where risk= &risk_choisi.;
  series x=YEA y= MOR_V  / markerattrs=(color=red) lineattrs=(thickness=2) group=cou;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès prématurés dû à l'exposition au " &risk_choisi. " pour les PMA."  ;
run;


/*Tableau intéractif nb décès + Coût*/
%P_M_by_r_for_c(cou_type='PMA', color=LightOrange);

								/*-----COMPARAISONS PMA -----*/

/* Comparaison H/F */

%P_M_by_r_sex_for_c(cou_type='PMA', color=LightOrange, descriptif='Il y a eu un total de 6749246 décès prématurés, répartis entre les sexes et les différents risques environnementaux. Les risques les plus importants sont l assainissement insalubre, l exposition au plomb et l accès insuffisant à l eau potable. Le coût total de ces décès est estimé à 1,241,861 millions de dollars.');

/*Pourcentage de mort par risque, par sex pour chaque pays;*/
%P_M_by_r_s_for_c(cou_type='PMA', color=LightOrange, descriptif='On peut remarquer que les proportions des décès prématurer sont généralement plus élevés chez les hommes.');

/*Comparaison H/F des décès prématurés pour le risque &risk_choisi. du pays en développement &pays_choisi2."*/
ods proclabel "Inegalités- Graphique" ;
	title " Comparaison de l'impact du risque &risk_choisi. sur les hommes et les femmes pour le pays en développement: &pays_choisi2..";	   	
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=( SEX in ('MALE','FEMALE') & COU in (&pays_choisi2.) & risk in (&risk_choisi.)& AGE in ('ALL')));
	     series x=YEA y=MOR_V/ lineattrs=(thickness=2) group=sex;
		xaxis label='Année';
  		yaxis label='Nombre de décès prématurés';
		ods text= "Le graphique ci-dessous compare l'évolution du nombre de décès prématurés pour le pays en dévloppement &pays_choisi2. selon le sexe.";
	format risk $risk. cou $cou.;
   	run;
	title;


/*Comparaison des décès prématurés selon les classes d'âge pour les 'PMA'.*/
%P_M_by_r_a_for_c(cou_type='PMA', color=LightOrange, descriptif=' Il y a eu un total de 6749283 décès prématurés, répartis entre les différents risques environnementaux et les différents groupes d âges. Les risques les plus importants sont l assainissement insalubre, l exposition au plomb et l accès insuffisant à l eau potable. Les personnes les plus touchées sont les enfants et les personnes les moins touchées sont les adultes en âge de travailler. Le coût total de ces décès est estimé à 1,241,868 millions de dollars. Il est important de noter que ces données ne prennent pas en compte les différences de coût de la vie entre les pays.');



proc odstext;
	p"III. Comparaison entre les pays développés et les PMA" / style=[fontsize=12pt color=cornflowerblue fontweight=bold font_face='Arial Black' just=c];
run;



/*----------COMPARAISON PAYS DEVELOPPE ET PAYS EN DEVELOPPEMENT-------*/


ods proclabel "Graphique 5 " ;
/*Graphique pour comparer l'évolution des décès prématurés entre le pays développé et le PMA*/
ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=my_data (where=( YEA>'2004' & SEX in ('BOTH') & COU in (&pays_choisi2.,&pays_choisi.) & AGE in ('ALL')));
   format risk $risk. cou $cou.;
   hbar risk / response=MOR_V 
   group=COU groupdisplay=cluster;
  xaxis label='Nombre de décès prématurés';
  yaxis label='Risques';
  title " Comparaison du nombre de décès prématurés selon les risques entre le pays développé &pays_choisi. et le pays développement &pays_choisi2. entre 2005 et 2019";
		ods text= "Le graphique ci-dessous représente les décès prématurés de chaque risque pour le pays développé &pays_choisi. et le pays en développement &pays_choisi2..";
format risk $risk. cou $cou.;
run;



/*Graphique comparatif l'évolution des décès prématurés moyen par pays entre les PDV ET les PMA*/
DATA comparaison_PDV_PMA;
SET ratio_deces_par_pays ratio_deces_par_pays3;
RUN;

ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=comparaison_PDV_PMA ;
   hbar risk / response=ratio_deces_par_pays 
   group=country_type groupdisplay=cluster;
  xaxis label='Nombre de décès prématurés';
  yaxis label='Risques';
  title " Comparaison du nombre total de décès prématurés moyen par pays selon les risques entre les PMA et les PDV entre 2005 et 2019";
		ods text= "Le graphique ci-dessous représente les décès prématurés de chaque risque pour les pays développés et les pays les moins avancés. Les risques qui provoque le plus de décès pématurés dans les PDV sont les particules fines, le plomb, et l'ozone. Tandis que, les risques qui provoque le plus de décès pématurés dans les PMA sont le manque d'eaux potable, l'assaininement insalubre, et le manque d'accès pour le lavage des mains.";
format risk $risk. country_type PDV_PMA_encoding.;
run;


/* Graphique comparatif de l'évolution du nombre de décè prématuré moyen par pays type de pays pour un risque choisi*/ 
ODS GRAPHICS / WIDTH=600 HEIGHT=500 ;
proc sgplot data=comparaison_PDV_PMA ;
  where risk= &risk_choisi.;
  series x=YEA y= ratio_deces_par_pays  / markerattrs=(color=red) lineattrs=(thickness=2) group=country_type;
  xaxis label='Année';
  yaxis label='Décès prématurés moyen par pays';
  title "Graphique comparatif de l'évolution des décès prématuré moyen par pays total dû à l'exposition au " &risk_choisi. " entre les pays développés et les pays les moins avancés"  ;
  format risk $risk. country_type PDV_PMA_encoding.;
run;


/* Graphique comparatif de l'évolution des décès total par type de pays pour un risque choisi*/ 
ods select none;
PROC REPORT DATA=my_data (where=(YEA>='2005' & SEX in (&sexe_choisi.) & AGE in (&age_choisi.))) out=ratio_deces_par_type_pays;
  COLUMN  RISK cou_type YEA MOR_V ratio_deces_par_pays;
  DEFINE  cou_type/ GROUP "Type de pays"; 
  DEFINE YEA/ group "Année";
  DEFINE  RISK/ GROUP "Risques";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  
  define ratio_deces_par_pays/computed format=BEST12. "Nombre de décès moyen par pays";
  compute ratio_deces_par_pays;
  if cou_type= 'PMA' then ratio_deces_par_pays= MOR_V.sum/14;
  else ratio_deces_par_pays= MOR_V.sum/(67-14);
  endcomp;
RUN;
ods select all;

ODS GRAPHICS / WIDTH=950 HEIGHT=950 MAXLEGENDAREA=60 ;
proc sgplot data=ratio_deces_par_type_pays ;
  where risk= &risk_choisi.;
  series x=YEA y= MOR_V  / markerattrs=(color=red) lineattrs=(thickness=2) group=cou_type;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès prématuré total dû à l'exposition au " &risk_choisi. " entre les pays développés et les pays les moins avancés"  ;
run;



/*Nombre de décès prématuré total et moyen par type de pays et par risques. Pour tout age sexe et age*/
PROC REPORT DATA=my_data (where=(YEA>='2005' & SEX in (&sexe_choisi.) & AGE in (&age_choisi.))) STYLE(HEADER)=[BACKGROUND=LightBlue] ;
  COLUMN  RISK cou_type MOR_V ratio_deces_par_pays;
  DEFINE  cou_type/ GROUP "Type de pays"; 
  DEFINE  RISK/ GROUP "Risques";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  DEFINE ratio_deces_par_pays/computed format=8. "Nombre de décès moyen par pays";
  compute ratio_deces_par_pays;
  if cou_type= 'PMA' then ratio_deces_par_pays= MOR_V.sum/14;
  else ratio_deces_par_pays= MOR_V.sum/(67-14);
  endcomp;

  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;

  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/2 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;

  compute after risk;
  line ' ' ;
  endcomp;
 
  title "Nombre de décès prématurés total et moyen par type de pays et par risque.";
  ods text= "Le but est de visualiser le nombre de décès prématurés total dû à l'exposition aux différents risques environnementaux, entre les pays les moins avancés et les pays développés. Les données sont prises entre 2005 et 2019 sur les populations de &sexe_choisi. et &age_choisi.";
  format cou $cou. cou_type $cou_type. age $age. risk $risk.;
RUN;


ODS HTML CLOSE;




/* - - - - - - - - - - - - - - - - - - - - POWER POINT- - - - - - - - - - - - - - - - - - - - */
proc template;
define style styles.calib;
parent=styles.powerpointlight;
style systemtitle from systemtitle / backgroundcolor=lightblue fontsize=12pt verticalalign=middle;

class body / textalign=center verticalalign=middle fontsize=8pt color=darkblue transparency=20 ;
class headersandfooters / backgroundcolor=lilac color= darkblue bordercolor = goldenrod textalign=center verticalalign=middle;
class data, table /  bodysize=150% bordercolor = lavender textalign=center verticalalign=middle color= darkblue fontsize=7pt;
class title1, title / backgroundcolor=lilac color=darkblue fontsize=11pt verticalalign=middle;
class header / backgroundcolor=lilac color=darkblue fontsize=11pt verticalalign=middle;
class rowheader / backgroundcolor=lilac color=darkblue fontsize=11pt verticalalign=middle;
class proctitle / backgroundcolor=lilac color=darkblue fontsize=11pt verticalalign=middle;
end;
run;

ods powerpoint file = "&outlink./Présentation_Finale.pptx" style = styles.calib
	layout =  titleslide;
ods escapechar='~';

/* SORTIE POWER POINT */

/*Sommaire*/
proc odstext;
p 'Projet - Étude de cas en SAS' / style = [fontsize=36pt color=BIGB fontweight=BOLD textalign=CENTER verticalalign=middle];
P ' ';
p "Impacts de l'exposition aux risques environnementaux sur la mortalité, la morbidité et le bien-être économique entre les pays les moins avancés et les pays développés ?" / style = [fontsize=22pt color=BIGB fontweight=MEDIUM textalign=CENTER verticalalign=middle];
P ' ';
p 'Réalisé par Marie-Lou Baudrin, Claire Gefflot, Romain Pénichon' / style = [fontsize=20pt fontweight = MEDIUM fontstyle = ITALIC textalign = CENTER verticalalign=middle];
p "";
run;


proc odstext;
p 'SOMMAIRE' / style = [fontsize=36pt fontweight=BOLD textalign=CENTER color=BIGB verticalalign=middle] ;
p 'I. Introduction' / style = [fontsize=20pt fontweight=MEDIUM textalign=Left color=BIGB Background=white verticalalign=middle] ;
p 'II. Exposition aux risques environnementaux dans les pays développés' / style = [fontsize=20pt fontweight=MEDIUM textalign=Left color=BIGB Background=white verticalalign=middle] ;
p 'III. Analyse des risques environnementaux pour les pays les moins avancés (PMA)' / style = [fontsize=20pt fontweight=MEDIUM textalign=Left color=BIGB Background=white verticalalign=middle] ;
p 'IV. Comparaison entre les pays développés et les PMA' / style = [fontsize=20pt fontweight=MEDIUM textalign=Left color=BIGB Background=white verticalalign=middle] ;
p 'V. Conclusion' / style = [fontsize=20pt fontweight=MEDIUM textalign=Left color=BIGB Background=white verticalalign=middle] ;
run;

/*------ Part I. INTRODUCTION -----*/

ods powerpoint 
layout=titleslide ;

proc odstext ;
p 'I. Introduction' / style = [fontsize=36pt fontweight = MEDIUM textalign = CENTER color=white BACKGROUND=BIGB verticalalign=middle] ;
run ;

/*------ Part II. PAYS DEVELOPPES -----*/
ods powerpoint 
layout=titleslide ;

proc odstext ;
p 'II. Exposition aux risques environnementaux dans les pays développés' / style = [fontsize=36pt fontweight = MEDIUM textalign = CENTER color=white BACKGROUND=BIGB verticalalign=middle] ;
run ;

/*Nouvelle page:*/
ods powerpoint
layout=titleandcontent;
 title "Reporting général sur le nombre de décès prématurés par risque dans le pays développé : &pays_choisi.";
PROC REPORT DATA=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays_choisi.) & AGE in ('ALL'))) STYLE(HEADER)=[BACKGROUND=LightGreen];
  COLUMN RISK MOR_V VSL_USD Cout ;
  DEFINE  RISK/ "Risque" GROUP;
  DEFINE  MOR_V/ SUM "Nombre de décès prématurés ";
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  COMPUTE MOR_V;
  IF _C2_ > 50000 THEN CALL DEFINE('_C1_','STYLE','STYLE={BACKGROUND=RED}');
  ENDCOMP;
  /* 50 000 car nb de décès en france/ 7risques */
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
	compute Cout;
		Cout=MOR_V.SUM*VSL_USD.MEDIAN;
	endcomp;

  rbreak after / summarize;
  compute after;
  		Risk='Total';
  		extra=catx('','Les risques environnementaux précédents ont engendré',put(MOR_V.SUM,8.), 'décès prématurés entre 2005 et 2019 dans le pays développé ',&pays_choisi.);
		line extra $150.  ;
  endcomp;
  
  format cou $cou. age $age. risk $risk.;

RUN;


ods powerpoint
layout=titleandcontent;
title "Reporting général sur le nombre de décès prématurés par risque dans le pays développé : &pays_choisi.";
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1000 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays_choisi.) & AGE in ('ALL')));
   vbar risk / response=MOR_V;
   yaxis grid;
   xaxis grid;
   xaxis label='Risques';
   yaxis label='Nombre de décès prématurés';
   format risk $risk.;
run;


ods powerpoint 
layout = titleandcontent ;
  title "Evolution des décès prématurés pour les différents risques du pays développé : &pays_choisi. entre 2005 et 2019";

ODS GRAPHICS /  WIDTH=3000 HEIGHT=1500 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=( YEA > '2004' & SEX in ('BOTH') & COU in (&pays_choisi.) & risk in ('O3','NHANDW','PB','PM_2_5_OUT','RN','USAN','UWATS')& AGE in ('ALL')));
  series x=YEA y=MOR_V / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Nombre de décès prématurés';
  format risk $risk.;
run;


ods powerpoint
layout=titleandcontent;
title"Graphique comparatif de l'évolution des décès par risque pour les pays développés";
ODS GRAPHICS /  WIDTH=3000 HEIGHT=1500 MAXLEGENDAREA=60   ;
proc sgplot data=ratio_deces_par_pays ;
  series x=YEA y=ratio_deces_par_pays / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès moyens par pays, par risque pour les pays développés, pour tout âge et sexe entre 2005 et 2019." ;
run;



/* COMPARAISONS PDV */
ods powerpoint
layout=titleandcontent;
title "Comparaison des décès prématurés selon le sexe pour les pays développés " ;
%macro HF1(cou_type=, color=);
PROC REPORT DATA=my_data (where=((YEA >='2005') & SEX in ('FEMALE','MALE') & RISK in ('PM_2_5_OUT','O3','UWATS','USAN'))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN RISK SEX MOR_V rapport VSL_USD COUT ;
  where age ^= "ALL" and cou_type=&cou_type.;
  DEFINE risk/ group "Risques";
  DEFINE sex/ group "Sexe";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;
  compute after risk;
  extra=catx('',risk,' a engendré ',put(MOR_V.SUM,8.), 'décès prématurés dans les', &cou_type., ' entre 2005 et 2019.');
		line extra $150.;
  risk = ' ';
  line ' ' ;
  endcomp;
  
  break after risk / style={Font_style=italic Backgroundcolor=&color.};
  
  define rapport / computed format=percent8.2 "Proportion de décès prématurés"; 
  compute rapport;
  rapport = MOR_V.sum/MOR_V_sum_by_year ;
  endcomp;
DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/1.8 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
	compute Cout;
		Cout=MOR_V.SUM*VSL_USD.MEDIAN;
	endcomp;
 rbreak after / summarize;
  compute after;
  risk='Total';
  extra=catx('','De 2005 à 2019, on a recensé ',put(MOR_V.SUM,8.), ' décès prématurés dans les ',&cou_type.,' dus aux risques environnementaux énoncés.');
		line extra $150.;
  endcomp;
  format cou $cou. cou_type $cou_type. risk $risk. age $agegroup.;
RUN;
%mend HF1;
%HF1(cou_type='PDV', color=LightGreen);

/*Comparaison H/F des décès prématurés pour le risque &risk_choisi. du pays développé &pays_choisi.";*/
ods powerpoint 
layout = titleandcontent ;

	title " Comparaison de l'impact du risque &risk_choisi. sur les hommes et les femmes pour le pays développé: &pays_choisi..";	   	
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1000 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=( SEX in ('MALE','FEMALE') & COU in (&pays_choisi.) & risk in (&risk_choisi.)& AGE in ('ALL')));
	     series x=YEA y=MOR_V/ lineattrs=(thickness=2) group=sex;
		xaxis label='Année';
  		yaxis label='Nombre de décès prématurés';
	format risk $risk. cou $cou.;
   	run;

ods powerpoint 
layout=titleandcontent;
title "Comparaison des décès prématurés selon les classes d'âge pour les pays développés";
%macro AGE1(cou_type=, color=);
PROC REPORT DATA=my_data (where=((YEA >='2005') & SEX in ('BOTH') & RISK in ('PM_2_5_OUT','O3','UWATS'))) STYLE(HEADER)=[BACKGROUND=&color.];
  COLUMN RISK age MOR_V rapport VSL_USD COUT ;
  where age ^= "ALL" and cou_type=&cou_type.;
  DEFINE risk/ group "Risques";
  DEFINE age/ group "Age";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;
  
  compute after risk;
  extra=catx('',risk,' a engendré ',put(MOR_V.SUM,8.), 'décès prématurés dans les ', &cou_type.,' entre 2005 et 2019.');
		line extra $150.;
  risk = ' ';
  line ' ' ;
  endcomp;
  
  break after risk / style={Font_style=italic Backgroundcolor=&color.};
  
  define rapport / computed format=percent8.2 "Proportion de décès prématurés"; 
  compute rapport;
  rapport = MOR_V.sum/MOR_V_sum_by_year ;
  endcomp;
  
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';  
  compute Cout;
	Cout=MOR_V.SUM*VSL_USD.MEDIAN;
  endcomp;
  
  rbreak after / summarize;
  compute after;
  risk='Total';
  extra=catx('','De 2005 à 2019, on a recensé ',put(MOR_V.SUM,8.), ' décès prématurés dans les ', &cou_type.,' dus aux risques environnementaux énoncés.');
		line extra $150.;
  endcomp;
  
  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/2.5 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;
  format cou $cou. cou_type $cou_type. risk $risk. age $agegroup.;
RUN;
%mend AGE1;
%AGE1(cou_type='PDV', color=LightGreen);


/*------Part III. PAYS LES MOINS AVANCES -----*/
ods powerpoint 
layout=titleslide;

proc odstext ;
p 'III. Analyse des risques environnementaux pour les pays les moins avancés (PMA)' / style = [fontsize=36pt fontweight = MEDIUM textalign = CENTER color=white BACKGROUND=BIGB verticalalign=middle] ;
run ;

ods powerpoint
layout=titleandcontent;
 title "Reporting général sur le nombre de décès prématurés par risque dans le pays en développement : &pays_choisi2.";
PROC REPORT DATA=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays_choisi2.) & AGE in ('ALL'))) STYLE(HEADER)=[BACKGROUND=LightOrange];
  COLUMN RISK MOR_V VSL_USD Cout ;
  DEFINE  RISK/ "Risque" GROUP;
  DEFINE  MOR_V/ SUM "Nombre de décès prématurés ";
  DEFINE VSL_USD/ MEDIAN "Coût d'une vie humaine /en million de dollars";
  COMPUTE MOR_V;
  IF _C2_ > 50000 THEN CALL DEFINE('_C1_','STYLE','STYLE={BACKGROUND=RED}');
  ENDCOMP;
  /* 50 000 car nb de décès en france/ 7risques */
  define Cout / COMPUTED format=dollar12. 'Coût des décès/ en millions de dollars';
	compute Cout;
		Cout=MOR_V.SUM*VSL_USD.MEDIAN;
	endcomp;

  rbreak after / summarize;
  compute after;
  		Risk='Total';
  		extra=catx('','Les risques environnementaux précédents ont engendré',put(MOR_V.SUM,8.), 'décès prématurés entre 2005 et 2019 dans le pays en développement ',&pays_choisi2.);
		line extra $150.;
  endcomp;
  
  format cou $cou. age $age. risk $risk.;
RUN;


ods powerpoint
layout=titleandcontent;
 title "Reporting général sur le nombre de décès prématurés par risque dans le pays en développement : &pays_choisi2.";
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1000 MAXLEGENDAREA=60;
proc sgplot data=my_data (where=(YEA>'2004' & SEX in ('BOTH')& COU in (&pays_choisi2.) & AGE in ('ALL')));
   vbar risk / response=MOR_V;
   yaxis grid;
   xaxis grid;
   xaxis label='Risques';
   yaxis label='Nombre de décès prématurés';
   format risk $risk.;
run;	


ods powerpoint 
layout = titleandcontent ;
/*Graphique comparatif des décés prématurés pour tous les risques dans le pays en développement choisi;*/
ods proclabel "Graphique 1 " ;
ODS GRAPHICS /  WIDTH=3000 HEIGHT=1500 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=( SEX in ('BOTH') & COU in (&pays_choisi2.) & AGE in ('ALL')));
  series x=YEA y=MOR_V / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Nombre de décès prématurés';
  title "Evolution des décès prématurés au fil du temps pour les différents risques du pays en développement : &pays_choisi2.";
format risk $risk.;
run;

ods powerpoint 
layout = titleandcontent ;
title "Graphique comparatif de l'évolution des décès par risque pour les PMA";
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1500 MAXLEGENDAREA=60   ;
proc sgplot data=ratio_deces_par_pays3 ;
  series x=YEA y=ratio_deces_par_pays / markerattrs=(color=red) lineattrs=(thickness=2) group=risk;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès moyens par pays, par risque pour les PMA." ;
run;

ods powerpoint
layout=titleandcontent image_dpi=500  ;

title "Graphique comparatif de l'évolution des décès prématurés dû à l'exposition au &risk_choisi. pour les PMA";

ODS GRAPHICS /  WIDTH=3000 HEIGHT=1500 MAXLEGENDAREA=60   ;
proc sgplot data=ratio_deces_par_pays2 ;
  where risk= &risk_choisi.;
  series x=YEA y= MOR_V  / markerattrs=(color=red) lineattrs=(thickness=2) group=cou ;
  xaxis label='Année';
  yaxis label='Décès prématurés';
  title "Graphique comparatif de l'évolution des décès prématurés dû à l'exposition au " &risk_choisi. " pour les PMA."  ;
  keylegend / position=right;
run;


/*COMPARAISONS PMA*/
ods powerpoint
layout=titleandcontent;
title "Comparaison des décès prématurés selon le sexe pour les PMA " ;
%HF1(cou_type='PMA', color=LightOrange);

ods powerpoint 
layout = titleandcontent ;
title " Comparaison de l'impact du risque &risk_choisi. sur les hommes et les femmes pour le pays en développement: &pays_choisi2..";	   	
proc sgplot data=my_data (where=( SEX in ('MALE','FEMALE') & COU in (&pays_choisi2.) & risk in (&risk_choisi.)& AGE in ('ALL')));
	     series x=YEA y=MOR_V/ lineattrs=(thickness=2) group=sex;
		xaxis label='Année';
  		yaxis label='Nombre de décès prématurés';
		/*ods text= "Le graphique ci-dessous compare l'évolution du nombre de décès prématurés pour le pays en dévloppement &pays_choisi2. selon le sexe.";*/
	format risk $risk. cou $cou.;
run;


ods powerpoint 
layout=titleandcontent;
title "Comparaison des décès prématurés selon les classes d'âge pour les PMA";
%AGE1(cou_type='PMA', color=LightOrange);

/*------ Part IV. COMPARAISON PDV PMA -----*/

ods powerpoint
layout=titleslide;

proc odstext ;
p 'IV. Comparaison entre les pays développés et les PMA' / style = [fontsize=36pt fontweight = MEDIUM textalign = CENTER color=white BACKGROUND=BIGB verticalalign=middle] ;
run ;  
ods powerpoint 
layout = titleandcontent ;   
  title "Comparaison du nombres de décès prématurés par risque dans les pays développés et les pays en développement"; 

/*Nombre de décès prématuré total et moyen par type de pays et par risques. Pour tout age sexe et age*/
PROC REPORT DATA=my_data (where=(YEA>='2005' & SEX in ('BOTH') & AGE in ('ALL') & risk in ('O3','PM_2_5_OUT','PB','UWATS','USAN'))) STYLE(HEADER)=[BACKGROUND=LightBlue] ;
  COLUMN  RISK cou_type MOR_V ratio_deces_par_pays;
  DEFINE  cou_type/ GROUP "Type de pays"; 
  DEFINE  RISK/ GROUP "Risques";
  DEFINE  MOR_V/ sum 'Nombre de décès prématurés';
  DEFINE ratio_deces_par_pays/computed format=8. "Nombre de décès moyen par pays";
  compute ratio_deces_par_pays;
  if cou_type= 'PMA' then ratio_deces_par_pays= MOR_V.sum/14;
  else ratio_deces_par_pays= MOR_V.sum/(67-14);
  endcomp;

  compute before risk ;
  MOR_V_sum_by_year = MOR_V.sum;
  endcomp;

  COMPUTE MOR_V;
  IF _C3_ > MOR_V_sum_by_year/2 THEN CALL DEFINE('_C2_','STYLE','STYLE={color=red}');
  ENDCOMP;

  compute after risk;
  line ' ' ;
  endcomp;
 
  format cou $cou. cou_type $cou_type. age $age. risk $risk.;
RUN;

ods powerpoint 
layout = titleandcontent image_dpi=800 ;
  title " Comparaison du nombre de décès prématurés selon les risques entre le pays développé &pays_choisi. et le pays développement &pays_choisi2. entre 2005 et 2019";
ods graphics on / height=7in width=7in;
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1000 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=( YEA>'2004' & SEX in ('BOTH') & COU in (&pays_choisi2.,&pays_choisi.) & AGE in ('ALL')));
   format risk $risk. cou $cou.;
   hbar risk / response=MOR_V 
   group=COU groupdisplay=cluster;
  xaxis label='Nombre de décès prématurés';
  yaxis label='Risques';
  keylegend / position=bottom;
format risk $risk. cou $cou.;
run;

/* Comparaison du nombre de décès prématurés selon les risques entre les PDV et PMA entre 2005 et 2019*/
ods powerpoint 
layout = titleandcontent image_dpi=800 ;
  title " Comparaison du nombre de décès prématurés selon les risques entre les PDV et PMA entre 2005 et 2019";
ods graphics on / height=7in width=7in;
ODS GRAPHICS /  WIDTH=2500 HEIGHT=1000 MAXLEGENDAREA=60   ;
proc sgplot data=my_data (where=( YEA>'2004' & SEX in ('BOTH') & AGE in ('ALL')));
   format risk $risk. cou $cou.;
   hbar risk / response=MOR_V 
   group=COU_TYPE groupdisplay=cluster;
  xaxis label='Nombre de décès prématurés';
  yaxis label='Risques';
  keylegend / position=bottom;
format risk $risk. cou $cou.;
run;

/*------ Part V. CONCLUSION -----*/
ods powerpoint
layout=titleslide;

proc odstext ;
p 'V. Conclusion' / style = [fontsize=36pt fontweight = MEDIUM textalign = CENTER color=white BACKGROUND=BIGB verticalalign=middle] ;
run ; 
   
ods powerpoint close;
  