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
create type DateV_t from datetime;
create type Pays_t from varchar(25);
create type Edition_t from varchar(25);
create type nomDistinction_t from varchar(25);
create type annee_t from int;
create type prix_t from real;
create type dateNaiss_t from datetime;
create type support_t from varchar(25);
create type id_t from smallint;
create type Etat_t from tinyint;
create type adresse_t from varchar(52);
create type telephone_t from smallint;
create type renouvellement_t from datetime;
create type anciennete_t from smallint;
create type politique_t from tinyint;
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VerifStockPhys
/* Prend la clef primaire d'un film et print si il louable/deja/pas */
create or alter procedure VerifStockPhys
@P_IdPhys id_t, @P_filmVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
as
declare @v_DateFin date = (select DateFin from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
declare @v_DateDebut date = (select DateDebut from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
Declare @v_Etat Etat_t = (select Etat from Physique where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
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
/* Prend la clef primaire d'un film et print si il louable/pas */
create procedure VerifStockNum
@P_filmVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
as
Declare @v_Film TitreVF_t = (select titreVF from Numérique where TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
BEGIN
	IF (not exists(select titreVF from Numérique where TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition))
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
/* lie au trigger PEGI  */
create procedure ProcPEGIreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t,  @P_NumeroAbonne Numero_t
AS 
Declare @v_AgeP int = (Year(getdate())- Year((Select DateNaiss From Abonné Where Numero = @P_NumeroAbonne)))
Declare @v_PegiF int = (Select PEGI FROM Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Edition = @P_Edition)
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
/* trigger les verifs lors d'une insertion dans louer */
create TRIGGER VerifLocationPhys
ON LouerPhys
FOR INSERT   
AS
Declare @v_Id id_t = (select id from inserted) 
Declare @v_TitreVF TitreVF_t = (select TitreVF from inserted)
Declare @v_Date DateV_t = (select DateV from inserted)
Declare @v_Edition Edition_t = (select Edition from inserted)
Declare @v_NumAbo Numero_t = (select Numero from inserted, Abonné where inserted.Nom = Abonné.Nom and inserted.Prenom = Abonné.Prenom and inserted.DateNaiss = Abonné.DateNaiss)
Declare @v_Pegi Integer
Declare @v_Force Integer = (select Force from inserted)
DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
	exec @return_status_Stock = VerifStockPhys @v_Id, @v_TitreVF, @v_Date, @v_Edition
	if(@return_status_Stock = 0)
		BEGIN
			print ('Aucun Film en stock Annulé');
			ROLLBACK TRANSACTION;
		END
	else
	BEGIN
   if(@v_Force <> 2)
	BEGIN
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		BEGIN
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		END
	END
	else
	BEGIN
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
	END
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop TRIGGER VerifLocationNum
/* trigger les verifs lors d'une insertion dans louer */
create TRIGGER VerifLocationNum
ON LouerNum
FOR INSERT   
AS 
Declare @v_TitreVF TitreVF_t = (select TitreVF from inserted)
Declare @v_Date DateV_t = (select DateV from inserted)
Declare @v_Edition Edition_t = (select Edition from inserted)
Declare @v_NumAbo Numero_t = (select Numero from inserted, Abonné where inserted.Nom = Abonné.Nom and inserted.Prenom = Abonné.Prenom and inserted.DateNaiss = Abonné.DateNaiss)
Declare @v_Pegi Integer
Declare @v_Force Integer = (select Force from inserted)
DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
	exec @return_status_Stock = VerifStockNum @v_TitreVF, @v_Date, @v_Edition
	if(@return_status_Stock = 0)
		BEGIN
			print ('Aucun Fim en stock Annulé');
			ROLLBACK TRANSACTION;
		END
	else
	BEGIN
   if(@v_Force <> 2)
	BEGIN
		exec @return_status_PEGI = ProcPEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
		if(@return_status_PEGI = 1)
		BEGIN
			print ('Insertion Annulé');
			ROLLBACK TRANSACTION;
		END
	END
	else
	BEGIN
		exec ProcPEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
	END
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmNonLouable
/* liste les films trop use pour etre loue */
create procedure PROCfilmNonLouable
AS 
Declare @v_Support support_t
Declare @v_TitreVF TitreVF_t
Declare @v_Date DateV_t
Declare @v_Pays Pays_t
Declare @v_Edition Edition_t
DECLARE C_Film CURSOR FOR
	select  Support, TitreVF, DateV, Edition 
	from Physique
	where Etat = 5;
BEGIN
	open C_Film
	FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Edition
	if @@FETCH_STATUS <> 0
		print 'Aucun Film non louable'
	Else
	BEGIN
		print 'Film non louable: '
		while @@FETCH_STATUS = 0
		BEGIN
			print @v_Support  + ' ' + @v_TitreVF + ' ' + convert(Varchar, @v_Date) +' ' + @v_Pays + ' ' + @v_Edition
			FETCH NEXT FROM C_Film into @v_Support, @v_TitreVF, @v_Date, @v_Edition
		END
	END
	CLOSE C_Film
	DEALLOCATE C_Film
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCprixPhys
/*prend deux annees et liste les films dedans avec leurs prix correspondant*/
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
/*prend deux annees et liste les films dedans avec leurs prix correspondant*/
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
/*prend deux annees et liste les films dedans avec leurs prix correspondant*/
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
drop procedure rachat
/*prend l'id d'un film est le suppr*/
create procedure rachat
@P_Id id_t
AS
Declare @v_Edition Edition_t
Declare @v_TitreVF TitreVF_t
Declare @v_DateV DateV_t
set @v_Edition = (Select Edition From Physique Where id = @P_Id);
set @v_TitreVF = (Select TitreVF From Physique where id = @P_Id);
set @v_DateV = (Select DateV From Physique Where id = @P_Id);
BEGIN
delete From Physique Where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV;
print'id suppr'
IF ((select COUNT(*) From Physique Where Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV)=0)
    Delete From Version Where Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV
    print'version suppr'
    BEGIN
    IF ((select COUNT(*) From Version Where @v_TitreVF = TitreVF)=0)
   	 print'film suppr'
   	 delete from Film Where  TitreVF =@v_TitreVF
    END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure durable
/*avg durable par film*/
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
drop procedure ProcDRMreminder
/*trigger print DRM*/
create or alter procedure ProcDRMreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
AS 
Declare @v_DRM varchar(25) = (Select DRM From Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Edition = @P_Edition)
BEGIN
	Print 'DRM : ' + @v_DRM
	Return 1
END
//////////////////////////////////////////////////////////////////////////////////////////////////

create or alter procedure PROCfilmLouer
@P_DateLoc DateV_t
AS 
Declare @v_TitreVF TitreVF_t
DECLARE C_Film CURSOR FOR
	select distinct(LouerPhys.TitreVF)
	from LouerPhys, LouerNum
	where (LouerPhys.DateDebut < @P_DateLoc 
	and LouerPhys.DateFin > @P_DateLoc)
	or( LouerNum.DateDebut < @P_DateLoc 
	and LouerNum.DateFin > @P_DateLoc)
BEGIN
	open C_Film
	FETCH NEXT FROM C_Film into @v_TitreVF
	if @@FETCH_STATUS <> 0
		print 'Aucun Film louer'
	Else
	BEGIN
		print 'Film en cours de location le ' + convert(varchar, @P_DateLoc) + ':'
		while @@FETCH_STATUS = 0
		BEGIN
			print  ' ' + @v_TitreVF 
			FETCH NEXT FROM C_Film into @v_TitreVF
		END
	END
	CLOSE C_Film
	DEALLOCATE C_Film
END


create or alter procedure PROCRenduLocation
@P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @P_TitreVF TitreVF_t, @P_DateDebut DateV_t
AS
Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor
Declare @v_Date DateV_t = (select GETDATE())
Declare @v_DateRendu DateV_t = (select DateFin from LouerPhys
		where Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss 
		and TitreVF = @P_TitreVF and DateDebut =@P_DateDebut )
BEGIN
	if (@v_DateRendu = NULL)
	BEGIN
		update LouerPhys set DateFin = @v_Date 
		where Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss 
		and TitreVF = @P_TitreVF and DateDebut =@P_DateDebut 
	END
	ELSE
	BEGIN
		print  'ERREUR : ce fim a deja une date de rendu'  
	END
END

create or alter procedure PROCDateFinPrevu
@P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @P_TitreVF TitreVF_t, @P_DateDebut DateV_t
AS
Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor
BEGIN
	print 'Film doit etre rendu le ' + convert(varchar, @v_DateFinPrevu) + ':'
END