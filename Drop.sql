drop table DistinguerProfessionnel;
drop table DistinguerFilm;
drop table Distinguer;
drop table Distinction;
drop table Participer;
drop table Sous_titrer;
drop table Vocaliser;
drop table Langue;
drop table LouerPhys;
drop table Physique;
drop table LouerNum;
drop table Numérique;
drop table Version;
drop table Film;
drop table Professionnel;
drop table Abonné;
drop table Abonnement;
drop table Personne;
/////////////
drop type Abonnement_t ;
drop type PrixAbonnement_t;
drop type NbFilms_t; 
drop type Duree_t ;
drop type Numero_t; 
drop type Film_t;
drop type Real_t ;
drop type Nom_t ;
drop type Prenom_t;
drop type PEGI_t;
drop type TitreVF_t ;
drop type TitreVO_t;
drop type DateV_t;
drop type Edition_t;
drop type nomDistinction_t;
drop type annee_t; 
drop type prix_t;
drop type dateNaiss_t ;
drop type support_t; 
drop type id_t ;
drop type Etat_t;
drop type adresse_t;
drop type anciennete_t;
drop type politique_t;
drop type renouvellement_t;
drop type telephone_t;
drop type Langue_t;
drop type DateLoc_t;
drop type DRM_t;
drop type Site_t;
//////////////
drop procedure AvantAbo
drop procedure EstAbo
drop procedure AfficheEdition
drop procedure Rachat
drop procedure FilmNonLouable
drop procedure Trending
drop procedure VerifStockPhys
drop procedure VerifStockNum
drop procedure PEGIreminder
drop TRIGGER VerifLocationPhys
drop TRIGGER PEGIreminderNum
drop procedure FilmNonLouable
drop procedure Realisateur
drop procedure FilmAct
drop procedure DistinctionFilm
drop procedure PrixPhys
drop procedure PrixNum
drop procedure EstAbo
drop procedure AfficheEdition
drop procedure RilmReal
drop procedure Rachat
drop procedure Trending
drop procedure Durable
drop procedure DRMreminder
drop procedure DureeMaxLoc
drop procedure FilmVo
drop procedure RetardNum
drop procedure RetardPhys
drop procedure RenouvellementNum
drop procedure RenouvellementPhys
drop procedure Duree
drop procedure VraiNom
drop procedure RetourLocPhys
drop procedure RetourLocNum
drop procedure NbFilmEnStock
drop procedure NbFilmLoue
drop procedure NbFilmLouable
drop procedure FilmLouer
drop procedure RenduLocation
drop procedure DateFinPrevu
drop procedure TrendingDRM
drop procedure FilmPrime
drop procedure EtatDRM
drop procedure SiteFilm
drop procedure LocNum
drop procedure LocPhys
drop procedure LangueSousTitre
drop procedure LangueBandeSon
drop procedure FilmLouable
drop procedure CheckAbo
/////////////
