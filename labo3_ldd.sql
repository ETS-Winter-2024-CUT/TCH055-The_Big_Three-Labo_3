-- ============================================================
-- Auteur: Anis Boubaker 
-- Date de création: 2019-03-08
-- Description:
--  Script de création du schema de la base de données Location
--  Vidéo utilisée dans le cadre du laboratoire 3.
-- ============================================================


DROP TABLE Film CASCADE CONSTRAINTS;
DROP TABLE Location CASCADE CONSTRAINTS;
DROP TABLE Categorie CASCADE CONSTRAINTS;
DROP TABLE Client CASCADE CONSTRAINTS;
DROP TABLE Facture CASCADE CONSTRAINTS;
DROP TABLE Coupon CASCADE CONSTRAINTS;

CREATE TABLE Film
(
  imdb_id   VARCHAR2(15) PRIMARY KEY,
  titre     VARCHAR2(75) NOT NULL,
  annee_sortie  NUMBER(5) NOT NULL,
  copies_total  NUMBER(3) NOT NULL,
  copies_dispo  NUMBER(3) NOT NULL,
  id_categorie  NUMBER(10) NOT NULL
);

CREATE TABLE Location
(   
    id_location NUMBER(10) PRIMARY KEY,
    imdb_id     VARCHAR2(15) NOT NULL,
    date_location DATE NOT NULL,
    id_client   NUMBER(10) NOT NULL,
    num_facture NUMBER(10)
);

CREATE TABLE Client
(
    id_client   NUMBER(10) PRIMARY KEY,
    nom         VARCHAR2(50) NOT NULL,
    prenom      VARCHAR2(50) NOT NULL,
    montant_a_payer NUMBER(10,2)
);

CREATE TABLE Categorie
(
    id_categorie NUMBER(10) PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    tarif NUMBER(10,2) NOT NULL,
    id_parent NUMBER(10)
);

CREATE TABLE Facture
(
    num_facture NUMBER(10) PRIMARY KEY,
    id_client   NUMBER(10) NOT NULL,
    date_facturation    DATE NOT NULL,
    montant_total       NUMBER(10), 
    date_paiement       DATE
);

CREATE TABLE Coupon
(
    id_coupon NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    montant   NUMBER(10,2) NOT NULL,
    id_client NUMBER(10) NOT NULL
);

ALTER TABLE Film ADD CONSTRAINT FK_Film_Categorie 
    FOREIGN KEY(id_categorie) REFERENCES Categorie(id_categorie);

ALTER TABLE Categorie ADD CONSTRAINT FK_Categorie_Categorie
    FOREIGN KEY(id_parent) REFERENCES Categorie(id_categorie);
    
ALTER TABLE Location ADD CONSTRAINT FK_Location_Film 
    FOREIGN KEY(imdb_id) REFERENCES Film(imdb_id);
    
ALTER TABLE Location ADD CONSTRAINT FK_Location_Client 
    FOREIGN KEY(id_client) REFERENCES Client(id_client)
    ON DELETE CASCADE;
    
ALTER TABLE Location ADD CONSTRAINT FK_Location_Facture 
    FOREIGN KEY(num_facture) REFERENCES Facture(num_facture)
    ON DELETE SET NULL;
    
ALTER TABLE Facture ADD CONSTRAINT FK_Facture_Client 
    FOREIGN KEY(id_client) REFERENCES Client(id_client)
    ON DELETE CASCADE;

ALTER TABLE Coupon ADD CONSTRAINT FK_Coupon_Client 
    FOREIGN KEY(id_client) REFERENCES Client(id_client)
    ON DELETE CASCADE;
    

DROP SEQUENCE SQ_Num_Facture;
CREATE SEQUENCE SQ_Num_Facture;


-- ============================================================
-- DECLENCHEUR: TRG_ID_Factures 
-- TYPE: Toutes lignes, à l'insertion dans Facture
-- Description:
--  Génère les numéros de factures de façon incrémentale lors 
-- des insertions dans la table Facture
-- ============================================================
CREATE OR REPLACE TRIGGER TRG_ID_Factures
BEFORE INSERT
ON Facture
FOR EACH ROW
BEGIN
    SELECT SQ_NUM_Facture.nextval
    INTO :NEW.num_facture
    FROM DUAL;
END;

