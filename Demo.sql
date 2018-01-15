/*Afficher Tous les Abonnement*/
exec AvantAboTout
/*S'Abonner*/
exec Abonner 'Quentin', 'Joubert', '1997-02-04', 'Asticot', 069, '37 rue louis Morard 75014 Paris', 0695047346, '2019-08-01', 1, 1
select * from Abonné
/*Modifier son Abonnement*/
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'SuperAsticot'
select * from Abonné
/*Verifier que l'utilisateurs est bien abonné*/
exec CheckAbo 'Quentin','Joubert'
/*Resilier son abonnement*/
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'Null'
select * from Abonné
/*Afficher les film en stock et support*/
exec TitrefilmEnStockPhys
exec TitrefilmEnStockNum

exec VersionFilmPhys 'Avatar', 'BlueRay'
exec LocationPhys 11566, 'Avatar','1928-07-22','Java','Albert','Camus','1952-01-01', 0