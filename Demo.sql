SET DATEFORMAT ymd;
/*Afficher les caracteristique des abonnement*/
exec AvantAboTout
/*S'Abonner*/
exec Abonner 'Quentin', 'Joubert', '1997-02-04', 'Asticot', 069, '37 rue louis Morard 75014 Paris', 0695047346, '2019-08-01', 1, 1
/*Modifier son Abonnement*/
select * from Abonné
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'SuperAsticot'
/*Verifier que l'utilisateurs est bien abonné*/
exec CheckAbo 'Quentin','Joubert'
/*Afficher les film en stock et support*/
exec TitrefilmEnStockPhys
exec TitrefilmEnStockNum
/*Afficher toute les version disponible d'un film*/
exec IdDeTitre 'Avatar'
exec VersionFilmPhys 'Titanic', 'DVD'
/*Louer un film */
exec LocationPhys 11566, 'Avatar','1928-07-22','Java','Albert','Camus','1952-01-01', 0
exec LocationPhys 11566, 'Avatar','1928-07-22','Java','Joubert', 'Quentin', '1997-02-04', 0
exec LocationNum 1234, 'Avatar','1928-07-22','Java','Albert','Camus','1952-01-01', 0
/*Resilier son abonnement*/
select * from LouerNum
exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'Null'
/*Afficher les film en cours de location par un abonné*/
exec FilmLouerClient 'Quentin','Joubert','1997-02-04'
/*Afficher les location dont la date de debut est*/
exec LocNum '2018-02-09'
/*Afficher le nombre de film en cours de location*/
exec NbFilmLoue
/*Afficher les film en cours de location*/
exec FilmLouer
/*Rendre un film*/
exec RenduLocationPhys 'Cherazade', 'Atila', '1964-01-31', 11010,'2018-02-09'
exec NbFilmLoue
/*Acheter un film */
exec Achat 11566
/*afficher les location en retard*/
exec RetardPhys
exec RetardNum
exec RetardPhysPers 'Joubert','Quentin','1997-02-04'
exec RetardNumPers 'Allo','Mais','1929-06-21'
exec Trending
select * from Abonné
exec LocationPhys 11010, 'Titanic', '2014-08-29', 'Java', 'Wenenensday', 'Drop', '2010-07-14' , 2
exec DateFinPrevu 'Wenenensday', 'Drop', '2010-07-14','Titanic', '2014-08-29'