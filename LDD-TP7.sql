/*Partie1*/
ALTER DATABASE DEFAULT TABLESPACE USERS;
ALTER USER /*<nom>*/ QUOTA 50m ON USERS;

/*Partie2*/
/*1*/
CREATE TABLE Pilote AS (
SELECT *
FROM IQ_BD_GONZAGUE.PILOTE);

CREATE TABLE Avion AS (
SELECT *
FROM IQ_BD_GONZAGUE.AVION);

CREATE TABLE Vol AS (
SELECT *
FROM IQ_BD_GONZAGUE.VOL);

/*2*/
SELECT *
FROM DICTIONARY
ORDER BY TABLE_NAME;

/*3*/
SELECT column_name, comments
FROM dict_columns
WHERE table_name = 'USER_TABLES';

DESC USER_TABLES;

/*4*/
SELECT TABLE_NAME
FROM USER_TABLES;

/*5*/
SELECT TABLE_NAME
FROM ALL_TABLES
WHERE OWNER = 'IQ_BDD_SCOTT';

/*6*/
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE, TABLE_NAME
FROM USER_CONSTRAINTS;

PURGE RECYCLEBIN;

/*7*/
/*a*/
ALTER TABLE Avion
ADD CONSTRAINT Pk_Avion PRIMARY KEY (codeAvion);

ALTER TABLE Pilote
ADD CONSTRAINT Pk_Pilote PRIMARY KEY (numPilote);

ALTER TABLE Vol
ADD CONTRAINT Pk_Vol PRIMARY KEY (codeAvion, numPilote)
ADD CONSTRAINT Fk_Vol_Avion FOREIGN KEY (codeAvion) REFERENCES Avion (codeAvion)
ADD CONSTRAINT Fk_Vol_Pilote FOREIGN KEY (numPilote) REFERENCES Pilote (numPilote);

/*b*/
ALTER TABLE Avion
ADD CONSTRAINT check_capacite CHECK (capacite BETWEEN 0 AND 900);

/*c*/
ALTER TABLE Avion
ADD CONSTRAINT check_dateDep CHECK (dateDep < dateArr)
ADD CONSTRAINT check_dateArr CHECK (dateArr > dateDep);


/*Partie3*/
/*1*/
SELECT Vol.NumVol, VolNumPil, Vol.NumAv, Vol.VilleDep, Vol.VilleArr, Vol.DateDep, Vol.DateArr
FROM Vol
WHERE UPPER(Vol.villeArr) = UPPER('Paris');

/*2*/
CREATE OR REPLACE VIEW VOLS_VERS_PARIS
AS (SELECT Vol.NumVol, VolNumPil, Vol.NumAv, Vol.VilleDep, Vol.VilleArr, Vol.DateDep, Vol.DateArr
    FROM Vol
    WHERE UPPER(Vol.villeArr) = UPPER('Paris');
/*On remarque que DateDep et DateArr sont de types VARCHAR2 et non DATE.*/

/*3*/
ALTER VIEW VOLS_VERS_PARIS
MODIFY (dateDep DATE)
MODIFY (dateArr DATE);

/*4*/
UPDATE VOLS_VERS_PARIS
SET villeArr = 'Dijon'
WHERE numVol = 8;

SELECT *
FROM VOLS_VERS_PARIS;

SELECT Vol.NumVol, VolNumPil, Vol.NumAv, Vol.VilleDep, Vol.VilleArr, Vol.DateDep, Vol.DateArr
FROM Vol;

/*5*/
CREATE OR REPLACE VIEW LISTE_VOLS(NumVol, NomPilote, NomAvion)
AS (SELECT NumVol, NomPilote, NomAvion
    FROM Vol
    INNER JOIN Pilote ON (Vol.numPilote = Pilote.numPilote)
    INNER JOIN Avion ON (Vol.codeAvion = Avion.codeAvion));

SELECT *
FROM LISTE_VOLS;

/*6*/
SELECT *
FROM USER_OBJECTS;

/*7*/
UPDATE LISTE_VOLS
SET nomPilote = 'Clementine'
WHERE numVol = 4;

/*On peut update une join view (view qui depend de plusieur table) car on n'a pas spécifié WITH READ ONLY dans la création de la view.*/

/*8*/
SELECT COLUMN_NAME
FROM USER_UPDATABLE_COLUMNS
WHERE (TABLE_NAME = 'LISTE_VOLS') AND ((UPDATABLE = 'YES') OR (INSERTABLE = 'YES')) ;

SELECT COLUMN_NAME
FROM USER_UPDATABLE_COLUMNS
WHERE (TABLE_NAME = 'VOLS_VERS_PARIS') AND ((UPDATABLE = 'YES') OR (INSERTABLE = 'YES')) ;

/*Partie3*/
/*1*/
/*USER_1 : IQ_BD_CHASSAGNE*/
GRANT CREATE VIEW ON Pilote
TO IQ_BD_FORGERON;
/*USER_2 / IQ_BD_FORGERON*/
CREATE VIEW ViewPiloteUser1 AS (SELECT *
                FROM IQ_BD_CHASSAGNE.Pilote);
                
/*USER_2 : IQ_BD_FORGERON*/
GRANT CREATE VIEW ON Pilote
TO IQ_BD_CHASSAGNE;
/*USER_1 : IQ_BD_CHASSAGNE*/
CREATE VIEW ViewPiloteUser2 AS (SELECT *
                FROM IQ_BD_FORGERON.Pilote);

/*2*/
/*USER_2 : IQ_BD_FORGERON*/
INSERT INTO IQ_BD_CHASSAGNE.Pilote VALUES ();
INSERT INTO ViewPiloteUser1 VALUES ();

/*USER_2 : IQ_BD_CHASSAGNE*/
INSERT INTO IQ_BD_FORGERON.Pilote VALUES ();
INSERT INTO ViewPiloteUser2 VALUES ();

/*USER_2 n'a pas les droits pour modifier la table Pilote de USER_1.*/


/*3*/
/*USER_2 : IQ_BD_FORGERON*/
GRANT INSERT ON Pilote
TO IQ_BD_CHASSAGNE;

/*USER_2 : IQ_BD_CHASSAGNE*/
GRANT INSERT ON Pilote
TO IQ_BD_FORGERON;

/*4*/
/*USER_2 : IQ_BD_FORGERON*/
GRANT SELECT ON Pilote, Avion
TO IQ_BD_CHASSAGNE
WHITH GRANT OPTIONC;

/*USER_2 : IQ_BD_CHASSAGNE*/
GRANT SELECT ON Pilote, Avion
TO IQ_BD_FORGERON
WHITH GRANT OPTIONC;

/*5*/
/*USER_2 : IQ_BD_FORGERON*/
GRANT SELECT ON IQ_BD_CHASSAGNE.Pilote, IQ_BD_CHASSAGNE.Avion
TO IQ_BD_BOB
WHITH GRANT OPTIONC;

/*USER_2 : IQ_BD_CHASSAGNE*/
GRANT SELECT ON IQ_BD_FORGERON.Pilote, IQ_BD_FORGERON.Avion
TO IQ_BD_BOB
WHITH GRANT OPTIONC;

/*6*/
/*login : IQ_BD_BOB
  pass : BOBO0000*/
SELECT *
FROM IQ_BD_CHASSAGNE.Pilote;
SELECT *
FROM IQ_BD_CHASSAGNE.Avion;
SELECT *
FROM IQ_BD_FORGERON.Pilote;
SELECT *
FROM IQ_BD_FORGERON.Avion;

/*7*/
/*USER_1 : IQ_BD_CHASSAGNE*/
REVOKE SELECT ON Pilote, Avion FROM IQ_BD_FORGERON;

/*USER_1 : IQ_BD_FORGERON*/
REVOKE SELECT ON Pilote, Avion FROM IQ_BD_CHASSAGNE;

SELECT *
FROM USER_SYS_PRIVS;

/*On a supprimé un privilège objet qui ne necessitait pas une revocation avec cascade constraint.
Donc Bob peut encore consulte les tables Pilote et Avion de USER_1.