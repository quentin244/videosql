//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VerifStockPhys
/* Prend la clef primaire d'un film et print si il louable/deja/pas */
create procedure VerifStockPhys
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
			print @v_Support  + ' ' + @v_TitreVF + ' ' + convert(Varchar, @v_Date) + ' ' + @v_Edition
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
create procedure ProcDRMreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
AS 
Declare @v_DRM varchar(25) = (Select DRM From Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Edition = @P_Edition)
BEGIN
	Print 'DRM : ' + @v_DRM
	Return 1
END
exec ProcDRMreminder 'Protéger et Servir', '1974-05-12', 'Bonus'
//////////////////////////////////////////////////////////////////////////////////////////////////

drop procedure ProcDureeMaxLoc

create procedure ProcDureeMaxLoc
@P_nomAbo Abonnement_t
as
declare @v_dureeMax duree_t
begin
	set @v_dureeMax=(select max(DureeLoc)
	    		 from abonnement
			 where nom=@P_nomAbo)
	if @v_dureeMax is null
	   print 'La duree maximale de l abonnement '+@P_nomAbo+' n est pas renseignee'
	else
	   print 'La duree maximale de l abonnement '+@P_nomAbo+' est de '+str(@v_dureeMax)+' jours'
end
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcRetourLocPhys

create procedure ProcRetourLocPhys
@P_dateFin DateV_t
as
declare @v_numero Numero_t

declare @v_nom Nom_t
declare @v_prenom Prenom_t
declare @v_dateNaiss dateNaiss_t

declare C_retourLocPhys cursor for
select distinct (Nom), Prenom, DateNaiss
from LouerPhys
where DateFin=@P_dateFin

begin
open C_retourLocPhys
fetch next from C_retourLocPhys into @v_nom, @v_prenom, @v_dateNaiss

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a une location physique a rendre le '+convert(varchar, @P_dateFin)
else
	begin
	print 'Liste des abonnes qui doivent rentre leur(s) location(s) physique(s) le '+ convert(varchar, @P_dateFin)
	while @@FETCH_STATUS = 0
		begin
		print @v_prenom+' ' +@v_nom 
		fetch next from C_retourLocPhys into @v_nom, @v_prenom, @v_dateNaiss
		end
	end
close C_retourLocPhys
deallocate C_retourLocPhys
end
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcRetourLocNum

create procedure ProcRetourLocNum
@P_dateFin DateV_t
as
declare @v_numero Numero_t
declare @v_nom Nom_t
declare @v_prenom Prenom_t
declare @v_dateNaiss dateNaiss_t
declare C_retourLocNum cursor for
select distinct (Nom), Prenom, DateNaiss
from LouerNum
where DateFin=@P_dateFin

begin
open C_retourLocNum
fetch next from C_retourLocNum into @v_nom, @v_prenom, @v_dateNaiss

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a une location numerique a rendre le '+convert(varchar, @P_dateFin)
else
	begin
	print 'Liste des abonnes qui doivent rentre leur(s) location(s) numerique(s) le '+ convert(varchar, @P_dateFin)
	while @@FETCH_STATUS = 0
		begin
		print @v_prenom+' ' +@v_nom 
		fetch next from C_retourLocNum into @v_nom, @v_prenom, @v_dateNaiss
		end
	end
close C_retourLocNum
deallocate C_retourLocNum
end
///////////////////////////////////////////////
drop procedure procNbFilmEnStock
/*nombre de films en stock */
create procedure procNbFilmEnStock
AS 
Declare @v_nbFilmStock smallint
BEGIN
	set @v_nbFilmStock=(select distinct(count(*)) from physique)+(select distinct(count(*)) from Numérique)
	Print 'il y a '+str(@v_nbFilmStock)+' films en stock'
	Return @v_nbFilmStock
END

//////////////////////////////////////////////////
/* nombre de films loues */
drop procedure ProcNbFilmLoue
create procedure procNbFilmLoue
as
declare @v_nbFilmLoue smallint

begin
	set @v_nbFilmLoue=(select distinct(count(*)) from louerPhys where datefin is null)+(select distinct(count(*)) from louerNum where datefin is null)
	print 'il y a '+str(@v_nbFilmLoue)+' film(s) loue(s)'
	return @v_nbFilmLoue
end

//////////////////////////////////////////////
drop procedure procNbFilmLouable

create procedure procNbFilmLouable
as
declare @v_nbFilmLouable smallint

begin
	set @v_nbFilmLouable=(select distinct(count(*)) from physique where etat <= 5)+(select count(*) from Numérique)+(select count(*) from louerPhys where datefin is not null)+(select distinct(count(*)) from louerNum where datefin is not null)
	print 'il y a '+str(@v_nbFilmLouable)+' film(s) louables(s)'
end
//////////////////////////////////////////////////////////////////////////
drop procedure procSiteFilm

create Procedure procSiteFilm
@P_titre TitreVF_t
as
declare @v_site Site_t
begin
    set @v_site=(select site from film where TitreVF=@P_titre)
    if @v_site is null
       print 'Le site du film '+@P_titre+' n est pas renseigne'
    else
       print 'Le site du film '+@P_titre+' est : ' +@v_site
end
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCfilmLouer

create or alter procedure PROCfilmLouer
AS 
Declare @v_TitreVF TitreVF_t
DECLARE C_Film CURSOR FOR
	select distinct(LouerPhys.TitreVF)
	from LouerPhys, LouerNum
	where (LouerPhys.DateDebut < GETDATE() 
	and LouerPhys.DateFin > GETDATE())
	or( LouerNum.DateDebut < GETDATE()  
	and LouerNum.DateFin > GETDATE())
BEGIN
	open C_Film
	FETCH NEXT FROM C_Film into @v_TitreVF
	if @@FETCH_STATUS <> 0
		print 'Aucun Film louer'
	Else
	BEGINcreate type DRM_t from varchar(25);

		print 'Film en cours de location le ' + convert(varchar, GETDATE()) + ':'
		while @@FETCH_STATUS = 0
		BEGIN
			print  ' ' + @v_TitreVF 
			FETCH NEXT FROM C_Film into @v_TitreVF
		END
	END
	CLOSE C_Film
	DEALLOCATE C_Film
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCRenduLocation

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
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCDateFinPrevu

create or alter procedure PROCDateFinPrevu
@P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @P_TitreVF TitreVF_t, @P_DateDebut DateV_t
AS
Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor
BEGIN
	print 'Film doit etre rendu le ' + convert(varchar, @v_DateFinPrevu)
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcNbFilmStock
/* nombre de films en stock */
create procedure ProcNbFilmStock 
as 
declare @v_nbFilmStock integer 
begin 
    set @v_nbFilmStock=(select distinct(count(*)) from numérique )+(select distinct(count(*)) from physique) 
    print 'il y a '+str(@v_nbFilmStock)+' film(s) en stock'
    return @v_nbFilmStock
end

//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcNbFilmStock
/* nombre de films loues */
create procedure ProcNbFilmLoue
as 
declare @v_nbFilmLoue integer 
begin 
    set @v_nbFilmLoue=(select distinct(count(*)) from louerPhys where dateFin is null)+(select distinct(count(*)) from louerNum) 
    print 'il y a '+str(@v_nbFilmLoue)+' film(s) loue(s)'
    return @v_nbFilmLoue
end

//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcNbFilmLouable
/* nombre de films louables */
create procedure ProcNbFilmLouable
as
declare @v_nbFilmLouable integer
begin
    set @v_nbFilmLouable=((select distinct(count(*)) from numérique )+(select distinct(count(*)) from physique where etat <= 5))-((select distinct(count(*)) from louerPhys where dateFin is null)+(select distinct(count(*)) from louerNum where dateFin is null))
    print 'il y a '+str(@v_nbFilmLoue)+' film(s) louables(s)'
    return @v_nbFilmLouable
end
////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure trendingDRM
/*trending drm */
create procedure trendingDRM
AS
Declare @v_DRM TitreVF_t
Declare @v_count int
DECLARE C_DRM_trend CURSOR FOR
    select DRM, count(*)
        from Version
        group by DRM
    order by count(*) desc
BEGIN
    open C_DRM_trend
    FETCH NEXT FROM C_DRM_trend into @v_DRM, @v_count
        if @@FETCH_STATUS <> 0
                print 'Aucun DRM trENDing'
        Else
         BEGIN
        print 'DRM trENDing: '
        while @@FETCH_STATUS = 0
                 BEGIN
                print left(@v_DRM + replicate('.',52),52) +': '+ convert(varchar, @v_count)
                FETCH NEXT FROM C_DRM_trend into @v_DRM, @v_count
                 END
         END
        CLOSE C_DRM_trend
        DEALLOCATE C_DRM_trend
END
/////////////////////////////////////////////////////////////////////////////
drop procedure etatDRM
/*avg durable par DRM*/
create procedure etatDRM
AS
Declare @v_DRM DRM_t
Declare @v_avg int
DECLARE C_etatDRM CURSOR FOR
    select DRM, avg(Etat)
        from Version v,Physique p
        where v.DateV=p.DateV and v.edition=p.edition
        group by DRM
    order by avg(Etat) desc
BEGIN
    open C_etatDRM
    FETCH NEXT FROM C_etatDRM into @v_DRM, @v_avg
        if @@FETCH_STATUS <> 0
        print 'Aucun DRM'
        Else
         BEGIN
        print 'DRM trENDing: '
        while @@FETCH_STATUS = 0
                 BEGIN
                print left(@v_DRM + replicate('.',52),52) +': '+ convert(varchar, @v_avg)
                FETCH NEXT FROM C_etatDRM into @v_DRM, @v_avg
                 END
         END
        CLOSE C_etatDRM
        DEALLOCATE C_etatDRM
END
/////////////////////////////////////////////////////////////////////////////

