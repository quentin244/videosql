create type Abonnement_t from varchar(25);
create type PrixAbonnement_t from smallint;
create type NbFilms_t from smallint;
create type Duree_t from integer;
create type Numero_t from smallint;
create type Film_t from varchar(52);
create type Real_t from varchar(25);
create type Nom_t from varchar(25);
create type Prenom_t from varchar(25);
create type PEGI_t from tinyint;
create type TitreVF_t from varchar(52);
create type TitreVO_t from varchar(52);
create type DateV_t from date;
create type Pays_t from varchar(25);
create type Edition_t from varchar(25);
create type nomDistinction_t from varchar(25);
create type annee_t from int;
create type prix_t from real;
create type dateNaiss_t from date;
create type support_t from varchar(25);
create type id_t from smallint;
create type Etat_t from tinyint;
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VerifStockPhys

create or alter procedure VerifStockPhys
@P_IdPhys id_t, @P_filmVF TitreVF_t, @P_Date DateV_t, @P_Pays Pays_t, @P_Edition Edition_t
as
declare @v_DateFin date = (select DateFin from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
declare @v_DateDebut date = (select DateDebut from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
Declare @v_Etat Etat_t = (select Etat from Physique where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
BEGIN
	if(@v_Etat<5)
	BEGIN
		print 'Ce film est en stock'
		if((@v_DateDebut < (select getDate())) and ((select getDate()) < @v_DateFin))
		begin
			print 'ce film est deja louer'
			Return 0
		end
		else
		begin
			print 'ce film est disponible'
			Return 1
		end
	END
	else
	begin
		print 'ce film n''est pas louable'
		Return 0
	end
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VerifStockNum

create procedure VerifStockNum
@P_filmVF TitreVF_t, @P_Date DateV_t, @P_Pays Pays_t, @P_Edition Edition_t
as
Declare @v_Film TitreVF_t = (select titreVF from Numérique where TitreVF = @P_filmVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
BEGIN
	IF (not exists(select titreVF from Numérique where TitreVF = @P_filmVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition))
	BEGIN
		print 'ce film n''est pas en stock'
		Return 0
	END
	ELSE
	BEGIN
		print 'Ce film est en stock'
			print 'ce film est disponible'
			Return 1
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcPEGIreminder

create procedure ProcPEGIreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Pays Pays_t, @P_Edition Edition_t,  @P_NumeroAbonne Numero_t
AS 
Declare @v_AgeP int = (Year(getdate())- Year((Select DateNaiss From Abonné Where Numero = @P_NumeroAbonne)))
Declare @v_PegiF int = (Select PEGI FROM Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
BEGIN
IF (@v_AgeP < @v_PegiF)
    	BEGIN
    		Print 'Attention votre age est inferieur a l''age minimal conseillé'
			Return 1
    	END
Return 0
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop TRIGGER VerifLocationPhys

create TRIGGER VerifLocationPhys
ON LouerPhys
FOR INSERT   
AS
Declare @v_Id id_t = (select id from inserted) 
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
	exec @return_status_Stock = VerifStockPhys @v_Id, @v_TitreVF, @v_Date, @v_Pays, @v_Edition
	if(@return_status_Stock = 0)
		BEGIN
			print ('Aucun Fim en stock Annulé');
			ROLLBACK TRANSACTION;
		END
	else
	BEGIN
   if(@v_Force <> 2)
	BEGIN
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		BEGIN
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		END
	END
	else
	BEGIN
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
	END
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop TRIGGER VerifLocationNum

create TRIGGER VerifLocationNum
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
	exec @return_status_Stock = VerifStockNum @v_TitreVF, @v_Date, @v_Pays, @v_Edition
	if(@return_status_Stock = 0)
		BEGIN
			print ('Aucun Fim en stock Annulé');
			ROLLBACK TRANSACTION;
		END
	else
	BEGIN
   if(@v_Force <> 2)
	BEGIN
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		BEGIN
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		END
	END
	else
	BEGIN
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Pays, @v_Edition, @v_NumAbo
	END
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmNonLouable

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
BEGIN
	open C_Film
	FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Pays, @v_Edition
	if @@FETCH_STATUS <> 0
		print 'Aucun Film non louable'
	Else
	BEGIN
		print 'Film non louable: '
		while @@FETCH_STATUS = 0
		BEGIN
			print @v_Support  + ' ' + @v_TitreVF + ' ' + convert(Varchar, @v_Date) +' ' + @v_Pays + ' ' + @v_Edition
			FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Pays, @v_Edition
		END
	END
	CLOSE C_Film
	DEALLOCATE C_Film
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCrealisateur

create procedure PROCrealisateur
@P_film film_t
AS
DECLARE @v_nomR nom_t
BEGIN
    Set @v_nomR = (select nom from participer where @P_film=titreVF And Role = 'Realisateur');
    print @P_film +' est realise par '+@v_nomR
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmAct

create procedure PROCfilmAct
@P_nomA nom_t, @P_prenomA prenom_t
AS
DECLARE @v_film Film_t

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
drop procedure PROCdistinctionFilm

create procedure PROCdistinctionFilm
@P_film film_t
AS
DECLARE @v_nomDist nomDistinction_t 
DECLARE @v_categorieDist varchar(25)
DECLARE @v_lieuDist varchar(25) 
Declare C_filmDist CURSOR FOR
select nom, Categorie
from DistinguerFilm 
where @P_film=titreVF

BEGIN
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
drop procedure PROCprixPhys

create procedure PROCprixPhys
@P_annee_min annee_t, @P_annee_max annee_t
AS
DECLARE @v_film TitreVF_t
DECLARE @v_prix prix_t
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
drop procedure PROCprixNum

create procedure PROCprixNum
@P_annee_min annee_t, @P_annee_max annee_t
AS
DECLARE @v_film film_t
DECLARE @v_prix prix_t

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
drop procedure EstAbo

create procedure EstAbo
@P_Prenom prenom_t, @P_Nom nom_t
AS
Declare @v_Numero Numero_t
Declare @true tinyint
set @true = 1;
BEGIN
    If (Exists (select * from Abonné where Nom=@P_Nom and Prenom = @P_Prenom))
   	 set @true = 0;
    BEGIN
   	 If @true=0
   		 BEGIN
   		 set @v_Numero = (select Numero from Abonné where Nom=@P_Nom and Prenom = @P_Prenom);
   		 print ''+str(@v_Numero);
   		 END
   	 ELSE
   		 print 'Nup';
    END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure AfficheEdition

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
	BEGIN
   		print 'Aucune edition n''est repertoriée'
	 END
    ELSE
    BEGIN
   		While @@FETCH_STATUS = 0
		BEGIN
   			Print @v_Edition
   			FETCH NEXT FROM ListEdition into @v_Edition
		END
    END
	CLOSE ListEdition
	DEALLOCATE ListEdition
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmreal

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
	BEGIN
		print 'Aucun film de ce réalisateur n''est repertorié dans la base de donnée'
	END
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
drop procedure rachat

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
BEGIN
delete From Physique Where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV;
print'id suppr'
IF ((select COUNT(*) From Physique Where Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV)=0)
    Delete From Version Where Edition = @v_Edition and TitreVF = @v_TitreVF and Pays = @v_Pays and DateV = @v_DateV
    print'version suppr'
    BEGIN
    IF ((select COUNT(*) From Version Where @v_TitreVF = TitreVF)=0)
   	 print'film suppr'
   	 delete from Film Where  TitreVF =@v_TitreVF
    END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure trending

create procedure trending
AS
Declare @v_TitreVF TitreVF_t
Declare @v_count int
DECLARE C_Film_trend CURSOR FOR
    select TitreVF, count(*)
	from LouerPhys
	group by TitreVF
    order by count(*) desc

BEGIN
    open C_Film_trend
    FETCH NEXT FROM C_Film_trend into @v_TitreVF, @v_count
	if @@FETCH_STATUS <> 0
    	print 'Aucun Film trENDing'
	Else
   	 BEGIN
    	print 'Film trENDing: '
    	while @@FETCH_STATUS = 0
   		 BEGIN
        	print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_count)
        	FETCH NEXT FROM C_Film_trend into @v_TitreVF, @v_count
   		 END
   	 END
	CLOSE C_Film_trend
	DEALLOCATE C_Film_trend
END
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

BEGIN
    open C_durable
    FETCH NEXT FROM C_durable into @v_TitreVF, @v_avg
	if @@FETCH_STATUS <> 0
    	print 'Aucun Film'
	Else
   	 BEGIN
    	print 'Film trENDing: '
    	while @@FETCH_STATUS = 0
   		 BEGIN
        	print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_avg)
        	FETCH NEXT FROM C_durable into @v_TitreVF, @v_avg
   		 END
   	 END
	CLOSE C_durable
	DEALLOCATE C_durable
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmVo

create procedure PROCfilmVo
@P_filmVF Film_t
AS
DECLARE @P_titreVO TitreVO_t
BEGIN
    SET @P_titreVO=(select titreVO from Film where TitreVF=@P_filmVF);
    print @P_filmVF+' a pour titre en original '+@P_titreVO
END
//////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCavantAbo

create procedure PROCavantAbo
@P_abo Abonnement_t
AS
DECLARE @v_prix PrixAbonnement_t
DECLARE @v_nb NbFilms_t
DECLARE @v_dureeLoc Duree_t

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
    print 'Avec l abonnement '+@P_abo+' on peut louer pour '+@v_prix+' euros '+@v_nb+' films pENDant une duree de '+@v_dureeLoc+' jours'
END
CLOSE C_avantAbo
DEALLOCATE C_avantAbo

END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCretardNum

create procedure PROCretardNum
AS
DECLARE @v_num Numero_t

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
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCretardPhys

create procedure PROCretardPhys
AS
DECLARE @v_num Numero_t

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
DECLARE @v_num Numero_t

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
    IF(@v_num=(select Abonné.numero from Abonné,LouerNum where Abonné.Nom=LouerNum.Nom and Abonné.Prenom=LouerNum.Prenom and Abonné.DateNaiss= LouerNum.DateNaiss and datefin is not null or datefin < GETDATE()))
   	 print 'attention : location en cours pour l abonne numero '+@v_num
    ELSE
   	 IF(GETDATE()-(select renouvellement from Abonné where @v_num=numero)>7)
   	 BEGIN
   		 delete from Abonné where numero=@v_num
   		 delete from Personne where @v_num=(select numero from Abonné where Personne.Nom=Nom and Personne.Prenom=Prenom and Personne.DateNaiss= DateNaiss)
   	 END
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
DECLARE @v_num Numero_t

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
    IF(@v_num=(select Abonné.Numero from Abonné,LouerPhys where Abonné.Nom=LouerPhys.Nom and Abonné.Prenom=LouerPhys.Prenom and Abonné.DateNaiss= LouerPhys.DateNaiss and datefin is not null or datefin < GETDATE()))
   	 print 'attention : location en cours pour l abonne numero '+@v_num
    ELSE
   	 IF(GETDATE()-(select renouvellement from Abonné where @v_num=numero)>7)
   	 BEGIN
   		 delete from Abonné where numero=@v_num
   		 delete from Personne where @v_num=(select numero from Abonné where Personne.Nom=Nom and Personne.Prenom=Prenom and Personne.DateNaiss= DateNaiss)
   	 END
   	 ELSE
   		 print 'L abonne '+@v_num+' doit renouveller son abonnement'
   	 
    FETCH NEXT FROM C_renouvellementPhys into @v_num
    END
END
CLOSE C_renouvellementPhys
DEALLOCATE C_renouvellementPhys

END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCduree

create procedure PROCduree
@P_nomR nom_t,@P_prenomR prenom_t
as
DECLARE @v_film Film_t

DECLARE C_duree CURSOR FOR
select Film.titreVF
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
drop procedure ProcVraiNom

create procedure ProcVraiNom
@P_filmVF Film_t
as
Declare @v_titreVO Film_t
BEGIN
    set @v_titreVO=(select titreVO from Film where @P_filmVF=titreVF)
    print 'le titre original du film '+@P_filmVF+' est '+@v_titreVO
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROClitigePhys
create procedure PROClitigePhys
@P_numClient Numero_t
AS
Declare @v_nb int
Declare @politique tinyint
begin 
	set @politique=0
	set @v_nb=(select*
	from Film,Version,Physique,LouerPhys,Abonnement,Abonne
	where Film.titreVF=Version.titreVF and Version.dateV=Numerique.dateV and Version.pays=Numerique.pays and pays.Edition=Version.edition
	and Physique.dateV=louerPhys.dateV and Physique.pays=louerPhys.pays and Physique.edition=louerPhys.edition and LouerPhys.numero=Abonne.numero
	and Physique.id=LouerPhys.id and Abonne.nom_abonnement=Abonnement.nom and Abonne.numero=@P_numclient and (getdate()-7>datedebut + dureeloc))
	
	if @v_nb >= 1
		set @politique=@politique+1
		print 'L abonne numero '+str(@P_numClient)+' a du retard de plus d une semaine'
end

drop procedure PROClitigeNum

create procedure PROClitigeNum
@P_numClient Numero_t
AS
Declare @v_nb int
Declare @politique tinyint
begin 
	set @politique=0
	set @v_nb=(select*
	from Film,Version,Numerique,LouerNum,Abonnement,Abonne
	where Film.titreVF=Version.titreVF and Version.dateV=Numerique.dateV and Version.pays=Numerique.pays and pays.Edition=Version.edition
	and Numerique.dateV=louerNum.dateV and Numerique.pays=louerNum.pays and Numerique.edition=louerNum.edition and LouerNum.numero=Abonne.numero
	and Abonne.nom_abonnement=Abonnement.nom and Abonne.numero=@P_numclient and (getdate()-7>datedebut + dureeloc))
	
	if @v_nb >= 1
		set @politique=@politique+1
		print 'L abonne numero '+str(@P_numClient)+' a du retard de plus d une semaine'
end

create or alter procedure ProcDRMreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Pays Pays_t, @P_Edition Edition_t
AS 
Declare @v_DRM varchar(25) = (Select DRM From Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Pays = @P_Pays and Edition = @P_Edition)
BEGIN
	Print 'DRM : ' + @v_DRM
	Return 1
END

exec ProcDRMreminder 'Titanic','2011-09-27','Belgique','Idée'
