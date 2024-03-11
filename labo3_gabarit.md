# Laboratoire 3 - Location Vidéo

- Auteurs: Léonard Marcoux, Maxim Dmitriev et Vianney Veremme
- Date de remise: 24 mars 2024

## Question 1

> Écrire un déclencheur `TRG_verifier_impayes_avant_location` qui empêche la création d’une nouvelle location si un client a un montant impayé de plus de <ins>50$</ins>.
> Si ce montant excède <ins>25$</ins>, il doit être permis au client de louer mais un message d’alerte doit s’afficher dans la console (ex. : **Attention, le client a des factures impayées**).
> Les factures impayées sont celles dont la date de paiement est nulle (`NULL`).

```sql

```

## Question 2.1

> Écrire la procédure `p_Calculer_Montant_Du` qui met à jour la colonne dérivée `montant_total_a_payer` de la table `Client`, pour le client dont l’identifiant est passé en paramètre.
> Le montant total à payer est calculé en additionnant les montants de toutes les factures d’un client qui n’ont pas été payées (`date_paiement` est `NULL`).

```sql

```


## Question 2.2

> Écrire la procédure `p_Calculer_Tous_Montants_Dus` qui met à jour le `montant_total_a_payer` pour tous les clients.

```sql

```


## Question 3

> Écrire la fonction `f_Montant_Facture` qui calcule et retourne le montant total d’une facture dont l’identifiant est reçu en paramètre.
> Le montant d’une facture est calculé en se basant sur le prix de location.
> Le prix de location dépend de la catégorie du film loué (colonne `tarif` de la table `Categorie`).

```sql

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

```


## Question 5

> Écrire la procédure `p_Generer_Coupons` qui ajoute des coupons dans la table `Coupon` pour les n-clients n’ayant pas de coupons, choisis aléatoirement.
> Le nombre n de clients ainsi que le montant des coupons sont passés en paramètre.
>> Note: Pour obtenir un client aléatoirement, il suffit de trier les clients aléatoirement avec la fonction `DBMS_RANDOM.value` : `ORDER BY DBMS_RANDOM.value`

```sql

```


## Question 6.1

> Écrire la fonction `f_Nb_Films_Dans_Cat` qui retourne le nombre de films classés dans une catégorie donnée.

```sql

```


## Question 6.2

> En utilisant [cette fonction](#question-61), écrire la requête SQL permettant d’afficher les noms des catégories, classées selon leur nombre de films.

```sql

```


## Question 7

> Écrire la procédure `p_Afficher_Cats_Parentes` permettant d’afficher le nom de toutes les catégories parentes (une par ligne) de la catégorie dont l’identifiant est passé en paramètre.

```sql

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
