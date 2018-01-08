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
//////////////
drop procedure PROCavantAbo
drop procedure EstAbo
drop procedure AfficheEdition
drop procedure rachat
drop procedure PROCfilmNonLouable
drop procedure trending
drop procedure VerifStockPhys
drop procedure VerifStockNum
drop procedure ProcPEGIreminder
drop TRIGGER VerifLocationPhys
drop TRIGGER PEGIreminderNum
drop procedure PROCfilmNonLouable
drop procedure PROCrealisateur
drop procedure PROCfilmAct
drop procedure PROCdistinctionFilm
drop procedure PROCprixPhys
drop procedure PROCprixNum
drop procedure EstAbo
drop procedure AfficheEdition
drop procedure PROCfilmreal
drop procedure rachat
drop procedure trending
drop procedure durable
drop procedure PROCfilmVo
drop procedure PROCretardNum
drop procedure PROCretardPhys
drop procedure PROCrenouvellementNum
drop procedure PROCrenouvellementPhys
drop procedure PROCduree
drop procedure ProcVraiNom
/////////////
