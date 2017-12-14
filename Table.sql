Create table Personne(
Nom				varchar(25),
Prenom			Varchar(25),
DateNaiss		Date check(DateNaiss <= getdate()),
Primary Key(Nom, Prenom, DateNaiss)
);
Create table Abonnement(
Nom				varchar(25) primary key,
Prix				smallint,
LocationMax			smallint,
DureeLoc			integer
);
Create table Abonné(
Numero			smallint Unique,
Adresse			varchar(52),
Téléphone			integer,
Renouvellement		date,
Ancienneté			smallint,
Politique			tinyint,
Nom				varchar(25),
Prenom			varchar(25),
DateNaiss			date check((YEAR(getdate()) - YEAR(DateNaiss)) >= 6),
Nom_Abonnement		varchar(25),
primary key (Nom,Prenom,DateNaiss),
Constraint fk1_abonne Foreign key(Nom, Prenom, DateNaiss) references Personne(Nom, Prenom, DateNaiss)	on delete cascade,
Constraint fk2_abonne Foreign key (Nom_Abonnement) references Abonnement(Nom) on update cascade on delete set NULL
);
Create table Professionnel(
Filmographie			text,
Biographie			text,
Caractéristique		text,
Nom				varchar(25),
Prenom			varchar(25),
DateNaiss			date check(DateNaiss <= getdate()),
primary key (Nom, Prenom, DateNaiss),
Constraint fk1_pro Foreign key(Nom, Prenom, DateNaiss) references Personne(Nom, Prenom, DateNaiss) on delete cascade
);
Create table Film(
TitreVF				varchar(52) primary key,
TitreVO			varchar(52),
Site				varchar(25),
Generique			text,
Resume			text,
VO				varchar(25) 
);
Create table Version(
DateV				date NOT NULL check(DateV <= getdate()),
Pays				varchar(25) NOT NULL ,
Edition				varchar(25) NOT NULL ,
DRM				varchar(25) ,
PEGI				tinyint check(PEGI <= 18),
Duree				time,
TitreVF				varchar(52) NOT NULL,
PRIMARY KEY (TitreVF, DateV ,Pays ,Edition),
constraint fk1_version foreign key (TitreVF) references Film(TitreVf) on update cascade on delete cascade 
);  
Create table Numérique(
TitreVF				varchar(52),
Prix 				smallint,
DateV				date,
Pays				varchar(25),
Edition				varchar(25),
DateInsert			date	default getdate(),
primary key (TitreVF,DateV,Pays,Edition),
constraint fk1_Numérique foreign key (TitreVF,DateV,Pays,Edition) references Version(TitreVF,DateV,Pays,Edition) on update cascade on delete cascade 
);
Create table LouerNum(
DateDebut			date check(DateDebut <= getdate()),
DateFin			date,
TitreVF				varchar(52),
DateV				date,
Pays				varchar(25),
Edition				varchar(25),
Nom				varchar(25),
Prenom			varchar(25),
DateNaiss			date,
Force 				Integer Default(0),
Primary Key(Nom, Prenom, DateNaiss, TitreVF, DateDebut),
constraint checkNum check(DateFin > DateDebut),
constraint fk1_LouerNum foreign key (Nom,Prenom,DateNaiss) references Abonné(Nom,Prenom,DateNaiss) on update cascade on delete NO Action,
constraint fk2_LouerNum foreign key (TitreVF,DateV,Pays,Edition) references Numérique(TitreVF,DateV,Pays,Edition) on update no action on delete cascade
);
Create table Physique(
id				smallint,
TitreVF				varchar(52),
Etat				tinyint,
Support			varchar(25),
Prix				float,
DateV				date,
Pays				varchar(25),
Edition				varchar(25),
DateInsert			date	default getdate(),
primary key(id,Pays,DateV,Edition,TitreVF),
constraint fk1_Physique foreign key (TitreVF,DateV,Pays,Edition) references Version(TitreVF,DateV,Pays,Edition) on update cascade on delete no action
);         
Create table LouerPhys(
DateDebut			date check(DateDebut <= getdate()),
DateFin			date ,
id				smallint,
TitreVF				varchar(52),
DateV				date,
Pays				varchar(25),
Edition				varchar(25),
Nom 				varchar(25),
Prenom			varchar(25),
DateNaiss 			date,
Force 				Integer Default(0),
Primary Key(Nom, Prenom, DateNaiss, TitreVF, DateDebut),
constraint checkPhy check(DateFin > DateDebut),
constraint fk1_LouerPhys foreign key (id,Pays,DateV,Edition,TitreVF) references Physique(id,Pays,DateV,Edition,TitreVF) on update no action on delete cascade,
constraint fk2_LouerPhys foreign key (Nom,Prenom,DateNaiss) references Abonné(Nom,Prenom,DateNaiss) on update no action on delete No action
);
Create table Langue(
Langue			varchar(25) primary key
);
Create table Vocaliser(
DateV				date not null,
Pays				varchar(25) not null,
Edition				varchar(25) not null,
TitreVF				varchar(52) NOT NULL ,
Langue			varchar(25) NOT NULL ,
Primary Key(DateV, Pays, Edition, TitreVF, Langue),
constraint fk1_Vocaliser foreign key (TitreVF, DateV ,Pays ,Edition) references Version (TitreVF,DateV,Pays,Edition) on update cascade on delete no action,
constraint fk2_Vocaliser foreign key (Langue) references langue(Langue) on update cascade on delete no action
);
Create table Sous_Titrer(
Langue			varchar(25) NOT NULL ,
DateV				date NOT NULL ,
Pays				varchar(25) NOT NULL ,
Edition				varchar(25) NOT NULL ,
TitreVF				varchar(52) NOT NULL ,
Primary Key(DateV, Pays, Edition, TitreVF, Langue),
constraint fk1_Sous_Titrer foreign key (Langue) references langue(Langue) on update cascade on delete no action,
constraint fk2_Sous_Titrer foreign key (TitreVF, DateV ,Pays ,Edition) references Version(TitreVF, DateV ,Pays ,Edition) on update cascade on delete no action
);
Create table Participer(
Role      			Varchar (25) ,
TitreVF   			Varchar (52) NOT NULL ,
Nom       			Varchar (25) NOT NULL ,
Prenom    			Varchar (25) NOT NULL ,
DateNaiss 			Date NOT NULL,
Primary Key(Nom, Prenom, DateNaiss, Role, TitreVF),
constraint fk1_Participer foreign key (TitreVF) references Film(TitreVF) on update cascade on delete no action,
constraint fk2_Participer foreign key (Nom,Prenom,DateNaiss) references Personne(Nom ,Prenom ,DateNaiss) on update cascade on delete no action
);
CREATE TABLE Distinction(
Nom       			varchar(25) NOT NULL ,
Categorie 			varchar(25) NOT NULL ,
Lieu      			varchar(25) NOT NULL ,
constraint pk_Distinction PRIMARY KEY (Nom ,Categorie ,Lieu)
);
Create table Distinguer(
DateD				date check(DateD <= getdate()),
TitreVF				varchar(52) NOT NULL ,
Nom				varchar(25) NOT NULL ,
Prenom			varchar(25) NOT NULL ,
DateNaiss			date NOT NULL,
Nom_Distinction		varchar(25) NOT NULL ,
Categorie			varchar(25) NOT NULL ,
Lieu				varchar(25) NOT NULL ,
Primary Key(Nom, Prenom, DateNaiss, TitreVF, Nom_Distinction, categorie, Lieu),
constraint fk1_distinguer FOREIGN KEY (TitreVF) REFERENCES Film(TitreVF) on update cascade on delete no action,
constraint fk2_distinguer FOREIGN KEY (Nom, Prenom, DateNaiss) REFERENCES Personne(Nom, Prenom, DateNaiss) on update cascade on delete no action,
constraint fk3_distinguer FOREIGN KEY (Nom_Distinction,Categorie,Lieu) REFERENCES Distinction(Nom,Categorie,Lieu) on update cascade on delete no action
);
Create table DistinguerFilm(
DateD				date check(DateD <= getdate()),
TitreVF				varchar(52) NOT NULL ,
Nom				varchar(25) NOT NULL ,
Categorie			varchar(25) NOT NULL ,
Lieu				varchar(25) NOT NULL ,
Primary Key(Nom, Categorie, Lieu, TitreVF),
constraint fk1_distinguerFilm FOREIGN KEY (TitreVF) REFERENCES Film(TitreVF) on update cascade on delete no action,
constraint fk2_distinguerFilm FOREIGN KEY (Nom,Categorie,Lieu) REFERENCES Distinction(Nom,Categorie,Lieu) on update cascade on delete no action
);
Create table DistinguerProfessionnel(
DateD				date check(DateD <= getdate()),
Nom				varchar(25) NOT NULL ,
Categorie			varchar(25) NOT NULL ,
Lieu				varchar(25) NOT NULL ,
Nom_Personne		varchar(25) NOT NULL ,
Prenom			varchar(25) NOT NULL ,
DateNaiss			date NOT NULL ,
Primary Key(Nom_Personne, Prenom, DateNaiss, Nom, Categorie, Lieu),
constraint fk1_distinguerPro FOREIGN KEY (Nom,Prenom,DateNaiss) REFERENCES Personne(Nom,Prenom,DateNaiss) on update cascade on delete no action,
constraint fk2_distinguerPro FOREIGN KEY (Nom,Categorie,Lieu) REFERENCES Distinction(Nom,Categorie,Lieu) on update cascade on delete no action
);
