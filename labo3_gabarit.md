# Laboratoire 3 - Location Vidéo

- Auteurs: Léonard Marcoux, Maxim Dmitriev et Vianney Veremme
- Date de remise: 24 mars 2024

## Question 1

> Écrire un déclencheur `TRG_verifier_impayes_avant_location` qui empêche la création d’une nouvelle location si un client a un montant impayé de plus de <ins>50$</ins>.
> Si ce montant excède <ins>25$</ins>, il doit être permis au client de louer mais un message d’alerte doit s’afficher dans la console (ex. : **Attention, le client a des factures impayées**).
> Les factures impayées sont celles dont la date de paiement est nulle (`NULL`).

```sql
CREATE OR REPLACE TRIGGER TRG_verifier_impayes_avant_location
BEFORE INSERT ON Location
FOR EACH ROW
DECLARE
    montant_impaye NUMBER(10,2);
BEGIN
    -- Calcul du montant impayé
    SELECT SUM(montant_total)
    INTO montant_impaye
    FROM Facture
    WHERE id_client = :NEW.id_client
    AND date_paiement IS NULL;

    -- Vérification du montant impayé
    IF montant_impaye > 50 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Impossible de créer une nouvelle location. Montant impayé supérieur à 50$.');
    ELSIF montant_impaye > 25 THEN
        DBMS_OUTPUT.PUT_LINE('Attention, le client a des factures impayées.');
    END IF;
END;
```

## Question 2.1

> Écrire la procédure `p_Calculer_Montant_Du` qui met à jour la colonne dérivée `montant_total_a_payer` de la table `Client`, pour le client dont l’identifiant est passé en paramètre.
> Le montant total à payer est calculé en additionnant les montants de toutes les factures d’un client qui n’ont pas été payées (`date_paiement` est `NULL`).

```sql
ALTER TABLE Client ADD montant_total_a_payer NUMBER(10,2);

CREATE OR REPLACE PROCEDURE p_Calculer_Montant_Du (
    v_client_id INT
)
AS
BEGIN
    UPDATE Client c
    SET montant_total_a_payer =
        (
            SELECT COALESCE(SUM(f.montant_total), 0)
            FROM Facture f
            WHERE f.id_client = v_client_id
            AND f.date_paiement IS NULL
        )
    WHERE c.id_client = v_client_id;
END;
/
```

## Question 2.2

> Écrire la procédure `p_Calculer_Tous_Montants_Dus` qui met à jour le `montant_total_a_payer` pour tous les clients.

```sql
CREATE OR REPLACE PROCEDURE p_Calculer_Tous_Montants_Dus
AS
BEGIN
    UPDATE Client c
    SET montant_total_a_payer =
        (
            SELECT COALESCE(SUM(f.montant_total), 0)
            FROM Facture f
            WHERE f.id_client = c.id_client
            AND f.date_paiement IS NULL
        );
END;
/
```

## Question 3

> Écrire la fonction `f_Montant_Facture` qui calcule et retourne le montant total d’une facture dont l’identifiant est reçu en paramètre.
> Le montant d’une facture est calculé en se basant sur le prix de location.
> Le prix de location dépend de la catégorie du film loué (colonne `tarif` de la table `Categorie`).

```sql
CREATE OR REPLACE FUNCTION f_Montant_Facture(p_num_facture IN NUMBER)
RETURN NUMBER IS
    v_montant_facture NUMBER(10, 2);
BEGIN
    SELECT COALESCE(SUM(c.tarif), 0)
    INTO v_montant_facture
    FROM Location l
    JOIN Film f ON l.imdb_id = f.imdb_id
    JOIN Categorie c ON f.id_categorie = c.id_categorie
    WHERE l.num_facture = p_num_facture;

    RETURN v_montant_facture;
END;
/
```

## Question 4

> Écrire la procédure `p_Emettre_Factures` qui génère les factures pour les locations qui n’ont pas été facturées (i.e. celles où les `numFacture` sont `NULL`).
> Vous devez générer <ins>une seule facture par client</ins>.
> Vous remarquerez que, dans le script de définition des tables, les numéros de factures sont créés automatiquement par un déclencheur.
> Ce déclencheur utilise une séquence qui vous servira à récupérer le numéro de la dernière facture insérée (voir `currval`).


>  Voici l’algorithme à implémenter:
> ```
> Pour tous les clients ayant des Locations non facturées Faire:
>   Pour toutes les locations non facturées du client Faire:
>       Si on n’a pas encore créé la facture Alors:
>           Créer une nouvelle facture
>           Récupérer le numéro de la facture créée
>       Fin Si
>       Mettre à jour la location avec le nouveau numéro de facture
>   Fin Pour
> Fin Pour
> ```


```sql
CREATE OR REPLACE PROCEDURE p_Emettre_Factures
IS
    v_num_facture NUMBER;
BEGIN
    -- Pour tous les clients ayant des locations non facturées
    FOR clt IN (SELECT DISTINCT id_client FROM Location WHERE num_facture IS NULL) LOOP
        -- Pour toutes les locations non facturées du client
        FOR loc IN (SELECT * FROM Location WHERE id_client = clt.id_client AND num_facture IS NULL) LOOP
            -- Vérifier si une facture existe déjà pour ce client
            SELECT num_facture
            INTO v_num_facture
            FROM Facture
            WHERE id_client = clt.id_client AND date_paiement IS NULL;

            -- Si aucune facture n'existe, en créer une nouvelle et récuperer son numéro
            IF v_num_facture IS NULL THEN
                SELECT SQ_Num_Facture.nextval
                INTO v_num_facture
                FROM DUAL;
                INSERT INTO Facture (num_facture, id_client, date_facturation, montant_total)
                VALUES (v_num_facture, clt.id_client, SYSDATE, 0);
            END IF;

            -- Mettre à jour la location avec le numéro de facture
            UPDATE Location
            SET num_facture = v_num_facture
            WHERE id_location = loc.id_location;
        END LOOP;
    END LOOP;
END;
/
```

## Question 5

> Écrire la procédure `p_Generer_Coupons` qui ajoute des coupons dans la table `Coupon` pour les n-clients n’ayant pas de coupons, choisis aléatoirement.
> Le nombre n de clients ainsi que le montant des coupons sont passés en paramètre.
>> Note: Pour obtenir un client aléatoirement, il suffit de trier les clients aléatoirement avec la fonction `DBMS_RANDOM.value` : `ORDER BY DBMS_RANDOM.value`

```sql
CREATE OR REPLACE PROCEDURE p_Generer_Coupons (
    p_montant_coupon IN NUMBER,
    p_nb_client IN NUMBER
)
AS
    v_nb_client_avec_coupon NUMBER;
    v_client_id NUMBER;
BEGIN

    SELECT COUNT(DISTINCT id_client) INTO v_nb_client_avec_coupon
    FROM Coupon;

    WHILE v_nb_client_avec_coupon < p_nb_client
    LOOP
        SELECT id_client
        INTO v_client_id
        FROM Client
        WHERE id_client NOT IN (SELECT DISTINCT id_client FROM Coupon)
        ORDER BY DBMS_RANDOM.value;

        INSERT INTO Coupon (id_client, montant)
        VALUES (v_client_id, p_montant_coupon);

        v_nb_client_avec_coupon := v_nb_client_avec_coupon + 1;
    END LOOP;
END;
/
```

## Question 6.1

> Écrire la fonction `f_Nb_Films_Dans_Cat` qui retourne le nombre de films classés dans une catégorie donnée.

```sql
CREATE OR REPLACE FUNCTION f_Nb_Films_Dans_Cat(p_id_categorie IN NUMBER)
RETURN NUMBER IS
    v_nb_films NUMBER;
BEGIN
    SELECT COALESCE(COUNT(*), 0)
    INTO v_nb_films
    FROM Film
    WHERE id_categorie = p_id_categorie;

    RETURN v_nb_films;
END;
/
```

## Question 6.2

> En utilisant [cette fonction](#question-61), écrire la requête SQL permettant d’afficher les noms des catégories, classées selon leur nombre de films.

```sql
SELECT c.nom AS nom_categorie, f_Nb_Films_Dans_Cat(c.id_categorie) AS nb_films
FROM Categorie c
ORDER BY nb_films DESC;
```

## Question 7

> Écrire la procédure `p_Afficher_Cats_Parentes` permettant d’afficher le nom de toutes les catégories parentes (une par ligne) de la catégorie dont l’identifiant est passé en paramètre.

```sql
CREATE OR REPLACE PROCEDURE p_Afficher_Cats_Parentes(p_id_categorie IN NUMBER) IS
BEGIN
    FOR categorie IN (
        SELECT c.*
        FROM Categorie c
        START WITH c.id_categorie = p_id_categorie
        CONNECT BY PRIOR c.id_parent = c.id_categorie
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(categorie.nom);
    END LOOP;
END;
/
```

## Question 8

> Écrire la fonction `f_Est_Sous_Categorie` qui reçoit en argument deux identifiants de catégories `id_cat_enfant` et `id_cat_parent`.
> Votre fonction doit retourner la valeur `O` si la catégorie ayant pour identifiant `id_cat_enfant` est un descendant de la catégorie `id_cat_parent`, ou `N` sinon.

```sql

```

## Question 9

> Écrire la fonction `f_Categorie_Plus_Populaire` qui reçoit en argument l’identifiant d’un client.
> Votre fonction doit retourner l’identifiant d’une catégorie principale qui est celle qui regroupe le plus grand nombre de films qui ont été loués par le client, en incluant ses sous-catégories.
> Nous entendons par “***catégorie principale***” une catégorie qui n’a pas de catégorie parente.
>> Note: Il serait judicieux de créer une autre fonction pour implémenter cette fonction.

```sql

```

## Question 10

> En utilisant la fonction `f_Categorie_Plus_Populaire`, écrivez une requête SQL permettant d’afficher les catégories principales par ordre de popularité.
> La catégorie la plus populaire est celle est qui la plus populaire chez le plus grand nombre de clients.

```sql

```
