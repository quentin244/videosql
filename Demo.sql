SET DATEFORMAT ymd;  
/*Afficher Tous les Abonnement*/
exec AvantAboTout
/*S'Abonner*/
exec Abonner 'Quentin', 'Joubert', '1997-02-04', 'Asticot', 069, '37 rue louis Morard 75014 Paris', 0695047346, '2019-08-01', 1, 1
/*Modifier son Abonnement*/
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'SuperAsticot'
/*Verifier que l'utilisateurs est bien abonné*/
exec CheckAbo 'Quentin','Joubert'
/*Resilier son abonnement*/
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'Null'
/*Afficher les film en stock et support*/
exec TitrefilmEnStockPhys
exec TitrefilmEnStockNum
/*Afficher toute les version disponible d'un film*/
exec VersionFilmPhys 'Avatar', 'BlueRay'
exec NbFilmLoue
/*Louer un film */
exec LocationPhys 11566, 'Avatar','1928-07-22','Java','Albert','Camus','1952-01-01', 0
exec LocationNum 123, 'Avatar','1928-07-22','Java','Albert','Camus','1952-01-01', 0
exec FilmLouerClient 'Albert','Camus','1952-01-01'
exec LocPhys '2018-01-26'
exec NbFilmLoue
exec FilmLouer
/*Rendre un film*/
exec RenduLocationPhys 'Albert','Camus','1952-01-01', 11566,'2018-01-26'
exec NbFilmLoue
exec Achat 11566