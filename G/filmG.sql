/*
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
*/

Create table Personne(
Nom				varchar(25),
Prenom			Varchar(25),
DateNaiss			Date check(DateNaiss <= getdate()),
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

create type Numero_t from smallint;
create type Film_t from varchar(52);
create type Real_t from varchar(25);
create type Nom_t from varchar(25);
create type Prenom_t from varchar(25);
create type PEGI_t from tinyint;
create type TitreVF_t from varchar(52);
create type DateV_t from date;
create type Pays_t from varchar(25);
create type Edition_t from varchar(25);
create type nomDistinctionT from varchar(25);
create type anneeT from int;
create type prixT from real;
create type dateNaiss_t from date;
create type support_t from varchar(25);
create type id_t from smallint;
create type Etat_t from tinyint;
//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure VerifStockPhys
@P_filmVF FilmT
as
Declare @v_Etat Etat_t
DECLARE C_StockFilm CURSOR FOR
select Etat
from Physique
where TitreVF = @P_filmVF
BEGIN
OPEN C_StockFilm
FETCH NEXT FROM C_StockFilm into @v_Etat

IF @@FETCH_STATUS <> 0
	Begin
	print 'ce film n''est pas en stock'
	Return 0
	End
ELSE
Begin
	while @@FETCH_STATUS = 0
		Begin
			if(@v_Etat<5)
			begin
				print 'Ce film est en stock'
				Return 1
			end
			else
			FETCH NEXT FROM C_StockFilm into @v_Etat
		End
End
CLOSE C_StockFilm
DEALLOCATE C_StockFilm
end
exec VerifStockPhys Titanic
//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure VerifStockNum
@P_filmVF FilmT
as
Declare @v_Film FilmT
DECLARE C_StockFilm CURSOR FOR
select titreVF
from Numérique
where TitreVF = @P_filmVF
BEGIN
OPEN C_StockFilm
FETCH NEXT FROM C_StockFilm into @v_Film

IF @@FETCH_STATUS <> 0
	Begin
    print 'ce film n''est pas en stock'
	Return 0
	End
ELSE
Begin
    print 'Ce film est en stock'
	Return 1
End
CLOSE C_StockFilm
DEALLOCATE C_StockFilm
end
//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure ProcPEGIreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Pays Pays_t, @P_Edition Edition_t,  @P_NumeroAbonne Numero_t
AS 
Declare @v_AgeP int = (Year(getdate())- Year((Select DateNaiss From Abonné Where Numero = @P_NumeroAbonne)))
Declare @v_PegiF int = (Select PEGI FROM Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
Begin
IF (@v_AgeP < @v_PegiF)
    	BEGIN
    		Print 'Attention votre age est inferieur a l''age minimal conseillé'
			Return 1
    	END
Return 0
End

//////////////////////////////////////////////////////////////////////////////////////////////////

create TRIGGER VerifLocationPhys
ON LouerPhys
FOR INSERT   
AS 
Declare @v_TitreVF TitreVF_t = (select TitreVF from inserted)
Declare @v_Date DateV_t = (select DateV from inserted)
Declare @v_Pays Pays_t = (select Pays from inserted)
Declare @v_Edition Edition_t = (select Edition from inserted)
Declare @v_NumAbo Numero_t = (select Numero from inserted, Abonné where inserted.Nom = Abonné.Nom and inserted.Prenom = Abonné.Prenom and inserted.DateNaiss = Abonné.DateNaiss)
Declare @v_Pegi Integer
Declare @v_Force Integer = (select Force from inserted)
DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
	exec @return_status_Stock = VerifStock @v_TitreVF
	if(@return_status_Stock = 0)
		begin
			print ('Aucun Fim en stock Annulé');
			ROLLBACK TRANSACTION;
		end
	else
	begin
   if(@v_Force <> 2)
	Begin
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		begin
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		end
	End
	else
	Begin
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
	End
	end
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create TRIGGER PEGIreminderNum
ON LouerNum
FOR INSERT   
AS 
Declare @v_TitreVF TitreVF_t = (select TitreVF from inserted)
Declare @v_Date DateV_t = (select DateV from inserted)
Declare @v_Pays Pays_t = (select Pays from inserted)
Declare @v_Edition Edition_t = (select Edition from inserted)
Declare @v_NumAbo Numero_t = (select Numero from inserted, Abonné where inserted.Nom = Abonné.Nom and inserted.Prenom = Abonné.Prenom and inserted.DateNaiss = Abonné.DateNaiss)
Declare @v_Pegi Integer
Declare @v_Force Integer = (select Force from inserted)
DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
	exec @return_status_Stock = VerifStock @v_TitreVF
	if(@return_status_Stock = 0)
		begin
			print ('Aucun Fim en stock Annulé');
			ROLLBACK TRANSACTION;
		end
	else
	begin
   if(@v_Force <> 2)
	Begin
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		begin
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		end
	End
	else
	Begin
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
	End
	end
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCfilmNonLouable
AS 
Declare @v_Support support_t
Declare @v_TitreVF TitreVF_t
Declare @v_Date DateV_t
Declare @v_Pays Pays_t
Declare @v_Edition Edition_t
DECLARE C_Film CURSOR FOR
	select  Support, TitreVF, DateV, Pays, Edition 
	from Physique
	where Etat = 5;
begin
	open C_Film
	FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Pays, @v_Edition
	if @@FETCH_STATUS <> 0
		print 'Aucun Film non louable'
	Else
	Begin
		print 'Film non louable: '
		while @@FETCH_STATUS = 0
		Begin
			print @v_Support  + ' ' + @v_TitreVF + ' ' + convert(Varchar, @v_Date) +' ' + @v_Pays + ' ' + @v_Edition
			FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Pays, @v_Edition
		End
	end
	CLOSE C_Film
	DEALLOCATE C_Film
end

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCrealisateur
@P_film filmT
AS
DECLARE @v_nomR nomT
Begin
    Set @v_nomR = (select nom from participer where @P_film=titreVF And Role = 'Realisateur');
    print @P_film +' est realise par '+@v_nomR
End

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCfilmAct
@P_nomA nomT, @P_prenomA prenomT
AS
DECLARE @v_film filmT

Declare C_filmAct CURSOR FOR
select titreVF
from Participer
where @P_nomA=nom and @P_prenomA=prenom;

BEGIN

OPEN C_filmAct
FETCH NEXT FROM C_filmAct into @v_film

IF @@FETCH_STATUS <> 0
    print @P_prenomA + ' '+@P_nomA + 'n a joue dans aucun film'
ELSE
BEGIN
    print @P_prenomA +' '+@P_nomA +'a joue dans les films suivants : '
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film
   	 FETCH NEXT FROM C_filmAct into @v_film
    END
END
CLOSE C_filmAct
DEALLOCATE C_filmAct
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCdistinctionFilm
@P_film filmT
AS
DECLARE @v_nomDist nomDistinctionT 
DECLARE @v_categorieDist varchar(25)
DECLARE @v_lieuDist varchar(25) 
Declare C_filmDist CURSOR FOR
select nom, Categorie
from DistinguerFilm 
where @P_film=titreVF

Begin
OPEN C_filmDist
FETCH NEXT FROM C_filmDist into @v_nomDist, @v_categorieDist

IF @@FETCH_STATUS <> 0
    print 'aucune distinction pour le film' + '@P_film'
ELSE
BEGIN
    print @P_film +'a recu les distinction suivants : '
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_nomDist + ' ' + @v_categorieDist
   	 FETCH NEXT FROM C_filmDist into @v_nomDist, @v_categorieDist
    END
END
CLOSE C_filmDist
DEALLOCATE C_filmDist
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCprixPhys
@P_annee_min anneeT, @P_annee_max anneeT
AS
DECLARE @v_film TitreVF_t
DECLARE @v_prix prixT
DECLARE C_prixPhys CURSOR FOR
select titreVF,prix
from Physique
where YEAR(dateV) between @P_annee_min and @P_annee_max
BEGIN
OPEN C_prixPhys
FETCH NEXT FROM C_prixPhys into @v_film,@v_prix

IF @@FETCH_STATUS <> 0
    print 'Aucun film n existe entre '+@P_annee_min+' et '+@P_annee_max
ELSE
BEGIN
    print 'Liste des films sortis entre '+ str(@P_annee_min) +' et ' + str(@P_annee_max)
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film +' '+str(@v_prix)
   	 FETCH NEXT FROM C_prixPhys into @v_film,@v_prix
    END
END
CLOSE C_prixPhys
DEALLOCATE C_prixPhys
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCprixNum
@P_annee_min anneeT, @P_annee_max anneeT
AS
DECLARE @v_film filmT
DECLARE @v_prix prixT

DECLARE C_prixNum CURSOR FOR
select titreVF,prix
from Numérique
where YEAR(dateV) between @P_annee_min and @P_annee_max

BEGIN

OPEN C_prixNum
FETCH NEXT FROM C_prixNum into @v_film,@v_prix

IF @@FETCH_STATUS <> 0
    print 'Aucun film n existe entre '+ str(@P_annee_min)+' et '+str(@P_annee_max)
ELSE
BEGIN
    print 'Liste des films sortis entre '+ str(@P_annee_min)+' et '+str(@P_annee_max)
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film +' '+str(@v_prix)
   	 FETCH NEXT FROM C_prixNum into @v_film,@v_prix
    END
END
CLOSE C_prixNum
DEALLOCATE C_prixNum

END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure EstAbo
@P_Prenom prenom_t, @P_Nom nom_t
AS
Declare @v_Numero Numero_t
Declare @true tinyint
set @true = 1;
Begin
    If (Exists (select * from Abonné where Nom=@P_Nom and Prenom = @P_Prenom))
   	 set @true = 0;
    Begin
   	 If @true=0
   		 begin
   		 set @v_Numero = (select Numero from Abonné where Nom=@P_Nom and Prenom = @P_Prenom);
   		 print ''+str(@v_Numero);
   		 end
   	 ELSE
   		 print 'Nup';
    End
End

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure AfficheEdition
@P_TitreVF TitreVF_t
AS
Declare @v_Edition Edition_t
Declare ListEdition CURSOR FOR
    Select  Edition
    from Version
    where TitreVF = @P_TitreVF
BEGIN
	OPEN ListEdition
    FETCH NEXT FROM ListEdition into @v_Edition
    IF @@FETCH_STATUS <> 0
	Begin
   		print 'Aucune edition n''est repertoriée'
	 End
    ELSE
    BEGIN
   		While @@FETCH_STATUS = 0
		Begin
   			Print @v_Edition
   			FETCH NEXT FROM ListEdition into @v_Edition
		End
    END
	CLOSE ListEdition
	DEALLOCATE ListEdition
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCfilmreal
@P_nomReal Nom_t, @P_prenomReal Prenom_t
AS
Declare @v_film TitreVF_t
DECLARE C_filmDeReal CURSOR FOR
	select TitreVF
	from Participer
	where Nom=@P_nomReal 
	and Prenom=@P_prenomReal 
	and Role = 'Realisateur' 

BEGIN
	OPEN C_filmDeReal
	FETCH NEXT FROM C_filmDeReal into @v_film
	IF @@FETCH_STATUS <> 0
	Begin
		print 'Aucun film de ce réalisateur n''est repertorié dans la base de donnée'
	End
	ELSE
	BEGIN
		print 'les films de ' + @P_nomReal + ' sont:'
		while @@FETCH_STATUS = 0
		BEGIN
   			print @v_film
   			FETCH NEXT FROM C_filmDeReal into @v_film
		END
	END
	CLOSE C_filmDeReal
	DEALLOCATE C_filmDeReal
END

//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure rachat
@P_Id id_t
AS
Declare @v_Edition Edition_t
Declare @v_TitreVF TitreVF_t
Declare @v_Pays    Pays_t
Declare @v_DateV DateV_t
set @v_Edition = (Select Edition From Physique Where id = @P_Id);
set @v_TitreVF = (Select TitreVF From Physique where id = @P_Id);
set @v_Pays = (Select Pays From Physique Where id = @P_Id);
set @v_DateV = (Select DateV From Physique Where id = @P_Id);
Begin
delete From Physique Where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV;
print'id suppr'
IF ((select COUNT(*) From Physique Where Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV)=0)
    Delete From Version Where Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV
    print'version suppr'
    Begin
    IF ((select COUNT(*) From Version Where @v_TitreVF = TitreVF)=0)
   	 print'film suppr'
   	 delete from Film Where  TitreVF =@v_TitreVF
    end
End


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure trending

create procedure trending
AS
Declare @v_TitreVF TitreVF_t
Declare @v_count int
DECLARE C_FilmTrend CURSOR FOR
    select TitreVF, count(*)
	from LouerPhys
	group by TitreVF
    order by count(*) desc

Begin
    open C_FilmTrend
    FETCH NEXT FROM C_FilmTrend into @v_TitreVF, @v_count
	if @@FETCH_STATUS <> 0
    	print 'Aucun Film trending'
	Else
   	 Begin
    	print 'Film trending: '
    	while @@FETCH_STATUS = 0
   		 Begin
        	print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_count)
        	FETCH NEXT FROM C_FilmTrend into @v_TitreVF, @v_count
   		 End
   	 end
	CLOSE C_FilmTrend
	DEALLOCATE C_FilmTrend
end

//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure durable

create procedure durable
AS
Declare @v_TitreVF TitreVF_t
Declare @v_avg int
DECLARE C_durable CURSOR FOR
    select TitreVF, avg(Etat)
	from Physique
	group by TitreVF
    order by count(Etat)

Begin
    open C_durable
    FETCH NEXT FROM C_durable into @v_TitreVF, @v_avg
	if @@FETCH_STATUS <> 0
    	print 'Aucun Film'
	Else
   	 Begin
    	print 'Film trending: '
    	while @@FETCH_STATUS = 0
   		 Begin
        	print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_avg)
        	FETCH NEXT FROM C_durable into @v_TitreVF, @v_avg
   		 End
   	 end
	CLOSE C_durable
	DEALLOCATE C_durable
end

//////////////////////////////////////////////////////////////////////////////////////////////////

create procedure PROCfilmVo
@P_filmVF FilmT
AS
DECLARE @P_titreVO filmVoT
Begin
    SET @P_titreVO=(select titreVO from Film where TitreVF=@P_filmVF);
    print @P_filmVF+' a pour titre en original '+@P_titreVO
End

create type AboT from varchar(25);
create type PrixAboT from smallint;
create type NbFilmsT from smallint;
create type DureeT from integer;
create type NumAboT from smallint;

drop type LocationT
drop procedure PROCavantAbo

create procedure PROCavantAbo
@P_abo AboT
AS
DECLARE @v_prix PrixAboT
DECLARE @v_nb NbFilmsT
DECLARE @v_dureeLoc DureeT

DECLARE C_avantAbo CURSOR FOR
select prix,LocationMax,DureeLoc
from Abonnemement
where nom=@P_abo

BEGIN

OPEN C_avantAbo
FETCH NEXT FROM C_avantAbo into @v_prix,@v_nb,@v_dureeLoc

IF @@FETCH_STATUS <> 0
    print 'L abonnement '+@P_abo+' ne contient aucune caracteristique'
ELSE
BEGIN
    print 'Avec l abonnement '+@P_abo+' on peut louer pour '+@v_prix+' euros '+@v_nb+' films pendant une duree de '+@v_dureeLoc+' jours'
END
CLOSE C_avantAbo
DEALLOCATE C_avantAbo

END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCretardNum

create procedure PROCretardNum
AS
DECLARE @v_num NumAboT

DECLARE C_retardNum CURSOR FOR
select numero
from Abonne,Abonnement,LouerNum
where Abonnement.nom=Abonne.nom_Abonnement and LouerNum.Numero=Abonne.numero
and Abonnement.LocationMax+LouerNum.DateDebut >=Abonnement.DureeLoc

BEGIN

OPEN C_retardNum
FETCH NEXT FROM C_retardNum into @v_num

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Liste des abonnes avec un retard en cours'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_num
   	 FETCH NEXT FROM C_retardNum into @v_num
    END
END
CLOSE C_retardNum
DEALLOCATE C_retardNum

END

drop procedure PROCretardPhys
//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure PROCretardPhys
AS
DECLARE @v_num NumAboT

DECLARE C_retardPhys CURSOR FOR
select numero
from Abonne,Abonnement,LouerNum
where Abonnement.nom=Abonne.nom_Abonnement and LouerPhys.Numero=Abonne.numero
and Abonnement.LocationMax+LouerPhys.DateDebut >=Abonnement.DureeLoc

BEGIN

OPEN C_retardPhys
FETCH NEXT FROM C_retardPhys into @v_num

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Liste des abonnes avec un retard en cours'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_num
   	 FETCH NEXT FROM C_retardPhys into @v_num
    END
END
CLOSE C_retardPhys
DEALLOCATE C_retardPhys

END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCrenouvellementNum

create procedure PROCrenouvellementNum
AS
DECLARE @v_num NumAboT

DECLARE C_renouvellementNum CURSOR FOR
select numero
from Abonne
where renouvellement < getdate()

BEGIN

OPEN C_renouvellementNum
FETCH NEXT FROM C_renouvellementNum into @v_num

IF @@FETCH_STATUS <> 0
    print 'Aucun Abonne n a besoin de renouveler son abonnement'
ELSE
BEGIN
    While @@FETCH_STATUS = 0
    BEGIN
    IF(@v_num=(select Abonné.numero from Abonné,LouerNum where Abonné.numero=LouerNum.numero and datefin is not null or datefin < GETDATE()))
   	 print 'attention : location en cours pour l abonne numero '+@v_num
    ELSE
   	 IF(GETDATE()-(select renouvellement from Abonné where @v_num=numero)>7)
   	 BEGIN
   		 delete from Abonné where numero=@v_num
   		 delete from Personne where @v_num=(select numero from Abonné where Personne.Nom=Nom and Personne.Prenom=Prenom and Personne.DateNaiss= DateNaiss)
   	 end
   	 ELSE
   		 print 'L abonne '+@v_num+' doit renouveller son abonnement'
   	 
    FETCH NEXT FROM C_renouvellementNum into @v_num
    END
END
CLOSE C_renouvellementNum
DEALLOCATE C_renouvellementNum

END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCrenouvellementPhys

create procedure PROCrenouvellementPhys
AS
DECLARE @v_num NumAboT

DECLARE C_renouvellementPhys CURSOR FOR
select numero
from Abonne
where renouvellement < getdate()

BEGIN

OPEN C_renouvellementPhys
FETCH NEXT FROM C_renouvellementPhys into @v_num

IF @@FETCH_STATUS <> 0
    print 'Aucun Abonne n a besoin de renouveler son abonnement'
ELSE
BEGIN
    While @@FETCH_STATUS = 0
    BEGIN
    IF(@v_num=(select Abonné.numero from Abonné,LouerPhys where Abonné.numero=LouerPhys.numero and datefin is not null or datefin < GETDATE()))
   	 print 'attention : location en cours pour l abonne numero '+@v_num
    ELSE
   	 IF(GETDATE()-(select renouvellement from Abonné where @v_num=numero)>7)
   	 BEGIN
   		 delete from Abonné where numero=@v_num
   		 delete from Personne where @v_num=(select numero from Abonné where Personne.Nom=Nom and Personne.Prenom=Prenom and Personne.DateNaiss= DateNaiss)
   	 end
   	 ELSE
   		 print 'L abonne '+@v_num+' doit renouveller son abonnement'
   	 
    FETCH NEXT FROM C_renouvellementPhys into @v_num
    END
END
CLOSE C_renouvellementPhys
DEALLOCATE C_renouvellementPhys

END
//////////////////////////////////////////////////////////////////////////////////////////////////

create procedure PROCduree
@P_nomR nomT,@P_prenomR prenomT
as
DECLARE @v_film filmT

DECLARE C_duree CURSOR FOR
select titreVF
from Film,Version,Participer
where Film.titreVF=Participer.titreVF and Film.titreVF=Version.titreVF and nom=@P_nomR and prenom=@P_prenomR and duree> '02:00:00' and role='Realisateur'

BEGIN

OPEN C_duree
FETCH NEXT FROM C_duree into @v_film

IF @@FETCH_STATUS <> 0
    print 'Aucun film n est realise par '+@P_prenomR+' '+@P_nomR
ELSE
BEGIN
    print 'Liste des films realises par '+@P_prenomR+' '+@P_nomR
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film
   	 FETCH NEXT FROM C_duree into @v_film
    END
END
CLOSE C_duree
DEALLOCATE C_duree

END
//////////////////////////////////////////////////////////////////////////////////////////////////
create procedure ProcVraiNom
@P_filmVF FilmT
as
Declare @v_titreVO FilmT
begin
    set @v_titreVO=(select titreVO from Film where @P_filmVF=titreVF)
    print 'le titre original du film '+@P_filmVF+' est '+@v_titreVO
end


