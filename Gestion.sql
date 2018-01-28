SET DATEFORMAT ymd;  
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VerifStockPhys
/* Prend la clef primaire d'un film et print si il louable/deja/pas */
create procedure VerifStockPhys
@P_IdPhys id_t, @P_filmVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
as
declare @v_DateFin date = (select DateFin from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
Declare @v_Etat Etat_t = (select Etat from Physique where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition)
BEGIN
	if(@v_Etat<5)
	BEGIN
		print 'Ce film est en stock'
		if (exists (select * from LouerPhys where id = @P_IdPhys and TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition))
		Begin
			if (@v_DateFin is null)
			begin
				print 'ce film est deja louer'
				Return 0
			end
			else
			begin
				print 'ce film est disponible'
				Return 1
			end
		End
		else
		begin
			print 'ce film est disponible'
			Return 1
		End
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
BEGIN
	IF (not exists(select * from Numérique where TitreVF = @P_filmVF and DateV = @P_Date and Edition = @P_Edition))
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
drop procedure PEGIreminder
/* lie au trigger PEGI  */
create procedure PEGIreminder
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
	Else 
		Return 0
END


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LocationPhys

create procedure LocationPhys
@v_Id id_t, @v_TitreVF TitreVF_t, @v_Date DateV_t, @v_Edition Edition_t, @P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @v_Force int
AS
Declare @v_DateDebut DateV_t = (select CAST(getdate() AS DATE))
Declare @v_NumAbo Numero_t = (select Numero from Abonné where Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_NbLocAutor int= (select LocationMax from Abonnement, Abonné where Abonné.Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and Nom_Abonnement = Abonnement.Nom)
Declare @v_NbLocReel int = (select count(*)From LouerPhys where Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and DateDebut is null)

DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
	if(@v_NbLocAutor <= @v_NbLocReel)
	Begin
		print ('Vous utilise tout vos emprunt autorisé. pour emprunter plus upgrader votre abonement');
	End
	else
	begin
		exec @return_status_Stock = VerifStockPhys @v_Id, @v_TitreVF, @v_Date, @v_Edition
		if(@return_status_Stock = 0)
		BEGIN
			print ('Aucun Film en stock Annulé');
		END
		else
		BEGIN
			if(@v_Force <> 2)
			BEGIN
				exec @return_status_PEGI = PEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
				if(@return_status_PEGI = 1)
				BEGIN
					print ('Vous n''avez pas l''age requis. Insertion Annulé');
				END
				else
				Begin
					Insert into LouerPhys values (@v_DateDebut,NULL, @v_Id, @v_TitreVF,@v_Date, @v_Edition,@P_Nom, @P_Prenom, @P_DateNaiss, @v_Force)
					Print 'La location a bien été enregistré'
				End
			END
			else
			BEGIN
				exec PEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
				Insert into LouerPhys values (@v_DateDebut,NULL, @v_Id, @v_TitreVF,@v_Date, @v_Edition,@P_Nom, @P_Prenom, @P_DateNaiss, @v_Force)
				Print 'La location a bien été enregistré'
			END
		END
	END
END


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LocationNum

create procedure LocationNum
@v_IdLocation id_t, @v_TitreVF TitreVF_t, @v_Date DateV_t, @v_Edition Edition_t, @P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @v_Force int
AS
Declare @v_DateDebut DateV_t = (select CAST(getdate() AS DATE))
Declare @v_NumAbo Numero_t = (select Numero from Abonné where Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_NbLocAutor int= (select LocationMax from Abonnement, Abonné where Abonné.Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and Nom_Abonnement = Abonnement.Nom)
Declare @v_NbLocReel int = (select count(*)From LouerNum where Nom = @P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and DateDebut is null)

DECLARE @return_status_PEGI int;
DECLARE @return_status_Stock int;     
BEGIN 
if(@v_NbLocAutor <= @v_NbLocReel)
	Begin
		print ('Vous utilise tout vos emprunt autorisé. pour emprunter plus upgrader votre abonement');
	End
	else
	begin
	exec @return_status_Stock = VerifStockNum @v_TitreVF, @v_Date, @v_Edition
	if(@return_status_Stock = 0)
	BEGIN
		print ('Aucun Film en stock Annulé');
	END
	else
	BEGIN
		if(@v_Force <> 2)
		BEGIN
			exec @return_status_PEGI = PEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
			if(@return_status_PEGI = 1)
			BEGIN
				print ('Vous n''avez pas l''age requis. Insertion Annulé');
			END
			else
			Begin
				Insert into LouerNum values (@v_IdLocation, @v_DateDebut,NULL, @v_TitreVF,@v_Date, @v_Edition,@P_Nom, @P_Prenom, @P_DateNaiss, @v_Force)
				Print 'La location a bien été enregistré'
			End
		END
		else
		BEGIN
			exec PEGIreminder @v_TitreVF, @v_Date, @v_Edition, @v_NumAbo
			Insert into LouerNum values (@v_IdLocation, @v_DateDebut,NULL, @v_TitreVF,@v_Date, @v_Edition,@P_Nom, @P_Prenom, @P_DateNaiss, @v_Force)
			Print 'La location a bien été enregistré'
		END
	END
END
end


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure FilmNonLouable
/* liste les films trop use pour etre loue */
create procedure FilmNonLouable
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
drop procedure PrixPhys
/*prend deux annees et liste les films dedans avec leurs prix correspondant*/
create procedure PrixPhys
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
drop procedure PrixNum
/*prend deux annees et liste les films dedans avec leurs prix correspondant*/
create procedure PrixNum
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
drop procedure Achat
/*prend l'id d'un film est le suppr*/
create procedure Achat
@P_Id id_t
AS
Declare @v_Edition Edition_t
Declare @v_TitreVF TitreVF_t
Declare @v_DateV DateV_t
set @v_Edition = (Select Edition From Physique Where id = @P_Id);
set @v_TitreVF = (Select TitreVF From Physique where id = @P_Id);
set @v_DateV = (Select DateV From Physique Where id = @P_Id);
BEGIN
	if (Exists(select * From Physique where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV))
	Begin
		if (Exists(select * From LouerPhys where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV and DateFin is null))
			Print 'Le Film '+ str(@P_Id) + ' Est en cours de location'
		else
		Begin
			delete From Physique Where id = @P_Id and Edition = @v_Edition and TitreVF = @v_TitreVF and DateV = @v_DateV;
			print'Le film a bien ete supprimé'
		End
	End
	ELSE
	Print 'Le Film '+ str(@P_Id) + ' n''existe pas'
End

exec Achat 11
select * from Physique
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
    	print 'Moyenne d''usure par film: '
    	while @@FETCH_STATUS = 0
   		 BEGIN
        	print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_avg)
        	FETCH NEXT FROM C_durable into @v_TitreVF, @v_avg
   		 END
   	 END
	CLOSE C_durable
	DEALLOCATE C_durable
END

exec durable
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure DRMreminder
/*trigger print DRM*/
create procedure DRMreminder
@P_TitreVF TitreVF_t, @P_Date DateV_t, @P_Edition Edition_t
AS 
Declare @v_DRM varchar(25) = (Select DRM From Version WHERE TitreVF=@P_TitreVF and DateV = @P_Date and Edition = @P_Edition)
BEGIN
	Print 'DRM : ' + @v_DRM
	Return 1
END

exec ProcDRMreminder 'Protéger et Servir', '1974-05-12', 'Bonus'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure DureeMaxLoc

create procedure DureeMaxLoc
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

exec ProcDureeMaxLoc 'Asticot'
///////////////////////////////////////////////
drop procedure NbFilmEnStock
/*nombre de films en stock */
create procedure NbFilmEnStock
AS 
Declare @v_nbFilmStock smallint
BEGIN
	set @v_nbFilmStock=(select distinct(count(*)) from physique)+(select distinct(count(*)) from Numérique)
	Print 'il y a '+str(@v_nbFilmStock)+' films en stock'
	Return @v_nbFilmStock
END

exec procNbFilmEnStock
//////////////////////////////////////////////////
drop procedure NbFilmLoue
/* nombre de films loues */
create procedure NbFilmLoue
as
declare @v_nbFilmLoue smallint

begin
	set @v_nbFilmLoue=(select distinct(count(*)) from louerPhys where datefin is null)+(select distinct(count(*)) from louerNum where datefin is null)
	print 'il y a '+str(@v_nbFilmLoue)+' film(s) loue(s)'
	return @v_nbFilmLoue
end

exec NbFilmLoue
//////////////////////////////////////////////
drop procedure NbFilmLouable

create procedure NbFilmLouable
as
declare @v_nbFilmLouable smallint

begin
	set @v_nbFilmLouable=(select distinct(count(*)) from physique where etat <= 5)+(select count(*) from Numérique)+(select count(*) from louerPhys where datefin is not null)+(select distinct(count(*)) from louerNum where datefin is not null)
	print 'il y a '+str(@v_nbFilmLouable)+' film(s) louables(s)'
end

exec NbFilmLouable
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure FilmLouer

create procedure FilmLouer
AS 
Declare @v_TitreVF TitreVF_t
DECLARE C_Film CURSOR FOR
	select distinct(LouerPhys.TitreVF)
	from LouerPhys, LouerNum
	where (LouerPhys.DateFin is NULL)
	or(LouerNum.DateFin is NULL)
BEGIN
	open C_Film
	FETCH NEXT FROM C_Film into @v_TitreVF
	if @@FETCH_STATUS <> 0
		print 'Aucun Film louer'
	Else
	BEGIN

		print 'Film en cours de location le ' + convert(varchar, CAST(getdate() AS DATE)) + ':'
		while @@FETCH_STATUS = 0
		BEGIN
			print  ' ' + @v_TitreVF 
			FETCH NEXT FROM C_Film into @v_TitreVF
		END
	END
	CLOSE C_Film
	DEALLOCATE C_Film
END

exec FilmLouer
select * from LouerPhys
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RenduLocationPhys

create procedure RenduLocationPhys
@P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @P_Id id_t, @P_DateDebut DateV_t
AS
Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor
Declare @v_Date DateV_t = (select CAST(getdate() AS DATE))
Declare @v_DateRendu DateV_t
BEGIN
if (exists(select * from LouerPhys where Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and id = @P_Id and DateDebut =@P_DateDebut ))
Begin
Set @v_DateRendu = (select DateFin from LouerPhys where Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and id = @P_Id and DateDebut =@P_DateDebut )
if (@v_DateRendu is NULL)
	BEGIN
		update LouerPhys set DateFin = @v_Date 
		where Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss 
		and id = @P_Id and DateDebut =@P_DateDebut 
	END
	ELSE
	BEGIN
		print  'ERREUR : ce fim a deja une date de rendu'  
	END
End
Else
begin 
print 'La location n''existe pas'
end
END

exec RenduLocationPhys 'Albert','Camus','1952-01-01', '21','2017-06-30'
select * from LouerPhys
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RenduLocationNum

create procedure RenduLocationNum
@P_IdLocation id_t
AS
Declare @v_Date DateV_t = (select CAST(getdate() AS DATE))
Declare @v_DateRendu DateV_t
BEGIN
if (exists(select * from LouerNum where IdLocation =@P_IdLocation ))
Begin
Set @v_DateRendu = (select DateFin from LouerNum where IdLocation =@P_IdLocation)
if (@v_DateRendu is NULL)
	BEGIN
		update LouerNum set DateFin = @v_Date 
		where IdLocation =@P_IdLocation
	END
	ELSE
	BEGIN
		print  'ERREUR : ce fim a deja une date de rendu'  
	END
End
Else
begin 
print 'La location n''existe pas'
end
END

exec RenduLocationNum 111
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure DateFinPrevu

create procedure DateFinPrevu
@P_Nom Nom_t, @P_Prenom Prenom_t, @P_DateNaiss dateNaiss_t, @P_TitreVF TitreVF_t, @P_DateDebut DateV_t
AS
Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor
BEGIN
	print @P_TitreVF + ' doit etre rendu le ' + convert(varchar, @v_DateFinPrevu)
END

exec PROCDateFinPrevu 'Weshwesh','lesamis','1995-26-04', 'Protéger et Servir','2017-01-01'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure NbFilmStock
/* nombre de films en stock */
create procedure NbFilmStock 
as 
declare @v_nbFilmStock integer 
begin 
    set @v_nbFilmStock=(select distinct(count(*)) from numérique )+(select distinct(count(*)) from physique) 
    print 'il y a '+str(@v_nbFilmStock)+' film(s) en stock'
    return @v_nbFilmStock
end

exec NbFilmStock
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
        print 'Location par DRM: '
        while @@FETCH_STATUS = 0
                 BEGIN
                print left(@v_DRM + replicate('.',52),52) +': '+ convert(varchar, @v_count)
                FETCH NEXT FROM C_DRM_trend into @v_DRM, @v_count
                 END
         END
        CLOSE C_DRM_trend
        DEALLOCATE C_DRM_trend
END

exec trendingDRM
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
        print 'Moyenne d''etat par DRM: '
        while @@FETCH_STATUS = 0
                 BEGIN
                print left(@v_DRM + replicate('.',52),52) +': '+ convert(varchar, @v_avg)
                FETCH NEXT FROM C_etatDRM into @v_DRM, @v_avg
                 END
         END
        CLOSE C_etatDRM
        DEALLOCATE C_etatDRM
END

exec etatDRM
/////////////////////////////////////////////////////////////////////////////
drop procedure trendingGestionnaire
/*print trending*/
create procedure trendingGestionnaire
AS
Declare @v_TitreVF TitreVF_t
Declare @v_countLoc int
Declare @v_countStock int
DECLARE C_Film_trendLoc CURSOR FOR
    select TitreVF, count(*)
	from LouerPhys
	group by TitreVF
DECLARE C_Film_trendStock CURSOR FOR
    select TitreVF, count(*)
	from Physique
	group by TitreVF
BEGIN
    open C_Film_trendLoc
    open C_Film_trendStock
    FETCH NEXT FROM C_Film_trendLoc into @v_TitreVF, @v_countLoc
    FETCH NEXT FROM C_Film_trendStock into @v_TitreVF, @v_countStock
	if @@FETCH_STATUS <> 0
    	print 'Aucun Film trENDing'
	Else
   		BEGIN
    	print 'Film trENDing: '
    	while @@FETCH_STATUS = 0
   			BEGIN
			print left(@v_TitreVF + replicate('.',52),52) +': '+ convert(varchar, @v_countLoc) + ' loué'+ ': '+ convert(varchar, @v_countStock) + ' en stock'
        	FETCH NEXT FROM C_Film_trendLOC into @v_TitreVF, @v_countLoc
 			FETCH NEXT FROM C_Film_trendStock into @v_TitreVF, @v_countStock
   			END
   		END
	CLOSE C_Film_trendLoc
	DEALLOCATE C_Film_trendLoc
	CLOSE C_Film_trendStock
	DEALLOCATE C_Film_trendStock	
END

exec trendingGestionnaire
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LocPhys

create procedure LocPhys
@P_dateDebut Dateloc_t
as
declare @v_Nom Nom_t
declare @v_Prenom Prenom_t

declare C_locPhys cursor for
	select Abonné.Nom, Abonné.Prenom
	from LouerPhys, Abonné
	where Abonné.Nom = LouerPhys.Nom
	And Abonné.Prenom = LouerPhys.Prenom
	And Abonné.DateNaiss = LouerPhys.DateNaiss
	And LouerPhys.DateDebut=@P_dateDebut
begin

open C_locPhys
fetch next from C_locPhys into @v_Nom, @v_Prenom 

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a effectue de location physique le '+convert(varchar,@P_dateDebut)
else
	begin
	print 'Liste des abonnes qui ont effectue au moins une location physique le '+convert(varchar,@P_dateDebut)
	while @@FETCH_STATUS = 0
		begin
		print @v_Nom + ' ' + @v_Prenom 
		fetch next from C_locPhys into @v_Prenom, @v_Nom
		end
	end
close C_locPhys
deallocate C_locPhys
end

exec LocPhys '2017-08-12'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LocNum

create procedure LocNum
@P_dateDebut Dateloc_t
as
declare @v_Nom Nom_t
declare @v_Prenom Prenom_t

declare C_locNum cursor for
	select Abonné.Nom, Abonné.Prenom
	from LouerNum, Abonné
	where Abonné.Nom = LouerNum.Nom
	And Abonné.Prenom = LouerNum.Prenom
	And Abonné.DateNaiss = LouerNum.DateNaiss
	And LouerNum.DateDebut=@P_dateDebut

begin

open C_locNum
fetch next from C_locNum into  @v_Prenom, @v_Nom

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a effectue de location numerique le '+convert(varchar,@P_dateDebut)
else
	begin
	print 'Liste des abonnes qui ont effectue au moins une location numerique le '+convert(varchar,@P_dateDebut)
	while @@FETCH_STATUS = 0
		begin
		print @v_Nom + ' ' + @v_Prenom 
		fetch next from C_locNum into  @v_Prenom, @v_Nom
		end
	end
close C_locNum
deallocate C_locNum
end

exec LocNum '2017-01-01'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RetourLocPhys

create procedure RetourLocPhys
@P_dateFin DateV_t
as
declare @v_numero Numero_t

declare @v_nom Nom_t
declare @v_prenom Prenom_t
declare @v_dateNaiss dateNaiss_t

declare C_retourLocPhys cursor for
select distinct (Nom), Prenom, DateNaiss
from LouerPhys
where DateFin=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))

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
drop procedure RetourLocNum

create procedure RetourLocNum
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

exec VerifStockPhys ''
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure TitrefilmEnStockNum

create procedure TitrefilmEnStockNum
AS
DECLARE @v_film film_t

DECLARE C_TitreStockNum CURSOR FOR
select distinct(titreVF)
from Numérique

BEGIN
OPEN C_TitreStockNum
FETCH NEXT FROM C_TitreStockNum into @v_film

IF @@FETCH_STATUS <> 0
    print 'Aucun film en stock numerique'
ELSE
BEGIN
    print 'Liste des films en stock Numerique sont :'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film
   	 FETCH NEXT FROM C_TitreStockNum into @v_film
    END
END
CLOSE C_TitreStockNum
DEALLOCATE C_TitreStockNum

END

exec TitrefilmEnStockNum
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure TitrefilmEnStockPhys

create procedure TitrefilmEnStockPhys
AS
DECLARE @v_film film_t
DECLARE @v_Support film_t

DECLARE C_TitreStockPhys CURSOR FOR
select distinct (titreVF), Support
from Physique
where id not in (select id from LouerPhys where DateFin is Null)
and id not in (select  id from Physique where Etat = 5)

BEGIN
OPEN C_TitreStockPhys
FETCH NEXT FROM C_TitreStockPhys into @v_film, @v_Support

IF @@FETCH_STATUS <> 0
    print 'Aucun film en stock Physique'
ELSE
BEGIN
    print 'Liste des films en stock physique sont :'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_film + ' ' + @v_Support
   	 FETCH NEXT FROM C_TitreStockPhys into @v_film, @v_Support
    END
END
CLOSE C_TitreStockPhys
DEALLOCATE C_TitreStockPhys

END

exec TitrefilmEnStockPhys
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VersionFilmPhys

create procedure VersionFilmPhys
@P_film film_t, @P_Support film_t
AS
DECLARE @v_id id_t
DECLARE @v_DateV DateV_t
DECLARE @v_Edition Edition_t

DECLARE C_TitreStockPhys CURSOR FOR
select id, DateV, Edition
from Physique
where TitreVF = @P_film and Support = @P_Support
and id not in (select id from LouerPhys where DateFin is Null)
and id not in (select  id from Physique where Etat = 5)


BEGIN
OPEN C_TitreStockPhys
FETCH NEXT FROM C_TitreStockPhys into @v_id, @v_DateV, @v_Edition

IF @@FETCH_STATUS <> 0
    print 'Aucun film en stock Physique disponible'
ELSE
BEGIN
    print 'Les version actuelement disponible du film ' + @P_film + ' en '+ @P_Support +' sont  :'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print 'Id :' +str(@v_id) + ' Date : '+convert(varchar, @v_DateV) + ' Edition : '+@v_Edition
   	 FETCH NEXT FROM C_TitreStockPhys into @v_id, @v_DateV, @v_Edition

    END
END
CLOSE C_TitreStockPhys
DEALLOCATE C_TitreStockPhys

END

exec VersionFilmPhys 'Avatar', 'DVD'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure VersionFilmNum

create procedure VersionFilmNum
@P_film film_t
AS
DECLARE @v_DateV DateV_t
DECLARE @v_Edition Edition_t

DECLARE C_TitreStockNum CURSOR FOR
select DateV, Edition
from Numérique
where TitreVF = @P_film

BEGIN
OPEN C_TitreStockNum
FETCH NEXT FROM C_TitreStockNum into @v_DateV, @v_Edition

IF @@FETCH_STATUS <> 0
    print 'Aucun film en stock Physique'
ELSE
BEGIN
    print 'Les version actuelement disponible du film ' + @P_film + ' sont  :'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print ' Date : '+convert(varchar, @v_DateV) + ' Edition : '+@v_Edition
   	 FETCH NEXT FROM C_TitreStockNum into @v_DateV, @v_Edition

    END
END
CLOSE C_TitreStockNum
DEALLOCATE C_TitreStockNum
END

exec VersionFilmNum 'Avatar'
//////////////////////////////////////////////////////////////////////////////////////////////////