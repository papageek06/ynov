Schéma relationnel correspondant à la base de données :
    VOL (novol, vildep, vilar, dep_h, dep_mn, ar_h, ar_mn, ch_jour)
    novol : clé primaire
    PILOTE (nopilot, nom, adresse, sal, comm, embauche)
    nopilot : clé primaire
    APPAREIL (code_type, nbplace, design)
    code_type : clé primaire
    AVION (nuavion, type, annserv, nom, nbhvol)
    nuavion : clé primaire
    type : clé étrangère en réf. à code_type de APPAREIL
    AFFECTATION (novol, date_vol, nbpass, nopilot, nuavion)
    novol, date_vol : clé primaire
    novol : clé étrangère en réf. à novol de VOL
    nopilot : clé étrangère en réf. à nopilot de PILOTE
    nuavion : clé étrangère en réf. à nuavion de AVION

    ch_jour est positionné à 1 si l’arrivée du vol à lieu le lendemain de son départ.
l’adresse du pilote est limité à sa ville.
Attention, dans les requêtes, pensez bien à mettre les dates sous la forme 'AAAA-MM-JJ'. 

1. Afficher le nom et le salaire des pilotes dont le salaire est compris entre 19000 et 23000.
    SELECT nom, sal 
    FROM pilote 
    WHERE sal BETWEEN 19000 AND 23000;

2. Liste des vols qui arrivent à LONDRES avant 12 H 00. Affichez le numéro de vol, la ville de départ, la
ville d’arrivée, l’heure de départ et l’heure d’arrivée. Le résultat sera trié par ordre alphabétique des
villes de départ.
    SELECT novol, vildep, vilar, dep_h, ar_h 
    FROM vol
    WHERE vilar = 'LONDRES' 
    AND ar_h < '12:00:00' 
    ORDER BY vildep ASC;

3. Numéros et type des avions qui appartiennent à un type d’appareil dont le premier caractère est ‘7’
    SELECT nuavion, type FROM avion WHERE type LIKE '7%';

4. Liste alphabétique des pilotes (nom, date d’embauche, adresse) qui habitent PARIS et qui ont été
embauchés entre le 1 Janvier 2011 et le 1 Janvier 2018.
    SELECT nom, embauche, adresse 
    FROM pilote
    WHERE adresse = 'PARIS' 
    AND embauche BETWEEN '2011-01-01' AND '2018-01-01'
    ORDER BY nom ASC;

5. Liste alphabétique des pilotes qui ont effectués un vol le 2 Mars 2014. (nom du pilote, n° du vol, ville
de départ et ville d’arrivée)
    SELECT p.nom, a.novol, v.vildep, v.vilar
    FROM pilote p
    JOIN affectation a ON p.nopilot = a.nopilot
    JOIN vol v ON a.novol = v.novol
    WHERE a.date_vol = '2014-03-02'
    ORDER BY p.nom ASC;

    NATURAL JOIN
Jointure entre 2 tables sur les ou les champs qui portent le même nom (à utiliser par exemple quand la clé étrangère
porte le même nom que la clé primaire correspondante). Donc identique à JOIN excepté qu’il est inutile de préciser
les champs avec ON.
Syntaxe :
select champ1, champ2 from table1 NATURAL JOIN table2 ; 

SELECT p.nom, a.novol, v.vildep, v.vilar
FROM pilote p NATURAL JOIN affectation a
NATURAL JOIN vol v
WHERE a.date_vol = '2014-03-02'
ORDER BY p.nom ASC;
    
6. Donnez la liste des pilotes qui ont été embauchés après le pilote n° 3452. (n° et nom des pilotes)
    SELECT nopilot, nom FROM pilote
    WHERE embauche > (SELECT embauche FROM pilote WHERE nopilot = 3452);


7. N° et nom du pilote qui a le salaire le plus élevé
    SELECT nopilot, nom FROM pilote
    WHERE sal = (SELECT MAX(sal) FROM pilote);

8. Donnez le numéro, le nom et le montant de la commission du pilote qui a la plus faible commission non
nulle.
    SELECT nopilot, nom, comm FROM pilote
    WHERE comm = (SELECT MIN(comm) 
    FROM pilote 
    WHERE comm IS NOT NULL);

9. Donnez le nombre d’avions par type d’avion pour les avions de la base de données.
    SELECT type, COUNT(*) 
    FROM avion 
    GROUP BY type;

10. Donnez les noms des pilotes qui ont piloté tous les avions
    SELECT nom 
    FROM pilote 
    WHERE NOT EXISTS (
        SELECT nuavion 
        FROM avion 
        WHERE NOT EXISTS (
            SELECT * 
            FROM affectation 
            WHERE affectation.nopilot = pilote.nopilot 
            AND affectation.nuavion = avion.nuavion
        )
    );


    
11. Donnez les noms des pilotes qui n’ont pas piloté tous les avions
    SELECT nom 
    FROM pilote JOIN affectation ON pilote.nopilot = affectation.nopilot
    WHERE COUNT(DISTINCT affectation.nuavion) < (SELECT COUNT(*) FROM avion)
    GROUP BY pilote.nopilot, pilote.nom;
  
        

12. Donnez les noms des pilotes qui n’ont piloté aucun avion
    SELECT nom 
    FROM pilote 
    WHERE NOT EXISTS (
        SELECT nuavion 
        FROM avion 
        WHERE NOT EXISTS (
            SELECT * 
            FROM affectation 
            WHERE affectation.nopilot = pilote.nopilot 
            AND affectation.nuavion = avion.nuavion
        )
    );

13. Donnez pour chaque pilote qui est passé par PARIS, le numéro de vol et la date correspondante. (n° et
nom du pilote, n° et date du vol)
    SELECT p.nopilot, p.nom, v.novol, a.date_vol
    FROM pilote p
    JOIN affectation a ON p.nopilot = a.nopilot
    JOIN vol v ON a.novol = v.novol
    WHERE v.vildep = 'PARIS' OR v.vilar = 'PARIS';


14. Donnez le taux moyen de remplissage des avions de type 734 pour les vols enregistrés dans la base de
données
    SELECT AVG(taux_remplissage) AS taux_moyen_remplissage
    FROM (
        SELECT (a.nbpass / ap.nbplace) * 100 AS taux_remplissage
        FROM affectation a
        JOIN avion ap ON a.nuavion = ap.nuavion
        WHERE ap.type = '734'
    ) AS sous_requete;

15. Donnez la liste des avions (numéro avion) qui ont été pilotés par plus de 2 pilotes.
    SELECT nuavion
    FROM affectation
    GROUP BY nuavion
    HAVING COUNT(DISTINCT nopilot) > 2;

16. Donnez la liste des pilotes qui ont le même nom mais une adresse différente. (nom et adresse du pilote)
    SELECT nom, adresse
    FROM pilote
    GROUP BY nom, adresse
    HAVING COUNT(*) > 1;

17. Donnez la liste des vols qui correspondent à des allers-retours entre 2 villes (n° du vol, ville de départ,
ville d’arrivée)
    SELECT v1.novol, v1.vildep, v1.vilar
    FROM vol v1
    JOIN vol v2 ON v1.vildep = v2.vilar AND v1.vilar = v2.vildep
    WHERE v1.novol <> v2.novol;
