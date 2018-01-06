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
drop procedure PROCrealisateur
/* prend un real et liste ses films en stock*/ 
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
/* prend un act et liste ses films en stock*/ 
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
/* Prend un film est liste ses distinctions*/
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
drop procedure AfficheEdition
/*Prend un film et print les editions en stock*/
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
/*prend prenom,nom d'un real et print ses films*/
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
drop procedure trending
/*print trending*/
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
drop procedure PROCfilmVo
/*print titre VO*/
create procedure PROCfilmVo
@P_filmVF Film_t
AS
DECLARE @P_titreVO TitreVO_t
BEGIN
    SET @P_titreVO=(select titreVO from Film where TitreVF=@P_filmVF);
    print @P_filmVF+' a pour titre en original '+@P_titreVO
END
//////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCduree
/*liste les films d'un real de plus de 2h*/
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
/*redit*/
create procedure ProcVraiNom
@P_filmVF Film_t
as
Declare @v_titreVO Film_t
BEGIN
    set @v_titreVO=(select titreVO from Film where @P_filmVF=titreVF)
    print 'le titre original du film '+@P_filmVF+' est '+@v_titreVO
END
//////////////////////////////////////////////////////////////////////////////////////////////////
