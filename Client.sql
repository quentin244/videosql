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
create type Langue_t from Varchar(25)
create type DateLoc_t from datetime
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure CheckAbo
/*Prend Prenom Nom est liste abonne*/
create procedure CheckAbo
@P_Prenom prenom_t, @P_Nom nom_t
AS
Declare @V_Prenom prenom_t, @V_Nom nom_t, @V_DateNaiss dateNaiss_t, @V_Abonnement Abonnement_t, @V_num Numero_t, @V_adr adresse_t,@V_tel telephone_t, @V_Renouvellement renouvellement_t, @V_anciennete anciennete_t, @V_politique politique_t
Declare C_check Cursor for
	select Numero, Nom, Prenom, Nom_Abonnement, Téléphone, DateNaiss, Adresse, Ancienneté, Politique, Renouvellement
	from Abonné
	where Nom = @P_Nom AND Prenom = @P_Prenom
BEGIN
OPEN C_check
Fetch next from C_check into @V_num, @V_Nom, @V_Prenom, @V_Abonnement, @V_tel, @V_DateNaiss, @V_adr, @V_anciennete, @V_politique, @V_Renouvellement

IF @@FETCH_STATUS <> 0
	print 'Aucun adherent correspondant'
ELSE
	BEGIN
	    While @@FETCH_STATUS = 0
		BEGIN
   		 print str(@V_num)+' '+@V_Nom+' '+@V_Prenom+' '+@V_Abonnement+' '+str(@V_tel)+' '+@V_DateNaiss+' '+@V_adr+' '+str(@V_anciennete)+' '+@V_politique+' '+@V_Renouvellement;
   		 FETCH NEXT FROM C_check into @V_num, @V_Nom, @V_Prenom, @V_Abonnement, @V_tel, @V_DateNaiss, @V_adr, @V_anciennete, @V_politique, @V_Renouvellement
		END
	END
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure EstAbo
/*Prend une clef primaire d'abonne et print si elle est dans la bdd*/
create procedure EstAbo
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t, @P_Abonnement Abonnement_t, @P_num Numero_t, @P_adr adresse_t,
@P_tel telephone_t, @P_Renouvellement renouvellement_t, @P_anciennete anciennete_t, @P_politique politique_t
AS
Declare @v_Numero Numero_t
Declare @true tinyint
Declare @abonne tinyint

BEGIN
    IF (Exists (select * from Abonné where Numero=@P_num and Adresse = @P_adr and Téléphone = @P_tel and 
    Renouvellement=@P_Renouvellement and Ancienneté=@P_Anciennete and Politique=@P_politique and 
    Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss and Nom_Abonnement = @P_Abonnement))
	begin
		print 'Le client '+@P_prenom+' '+@P_nom+' est abonne';
		return 1;
	end
	ELSE
	begin
   		print 'Le client '+@P_prenom+' '+@P_nom+' n est pas abonne';
		return 0;
	end
End
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCavantAbo
/*list caract d'un abonnement*/
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
/*list abonne en retard*/
create procedure PROCretardNum
AS
DECLARE @v_num Numero_t

DECLARE C_retardNum CURSOR FOR
select numero
from Abonné,Abonnement,LouerNum
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
exec PROCretardNum
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCretardPhys
/*list abonne en retard*/
create procedure PROCretardPhys
AS
DECLARE @v_num Numero_t
DECLARE @v_nom Nom_t
DECLARE @v_prenom prenom_t
DECLARE @v_dateNaiss dateNaiss_t

Declare @v_DureeLocAutor DateV_t = (select DureeLoc From Abonné, Abonnement where Abonné.Nom_Abonnement = Abonnement.Nom and Abonné.Nom =@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss)
Declare @v_DateFinPrevu DateV_t = @P_DateDebut + @v_DureeLocAutor

DECLARE C_retardPhys CURSOR FOR
select Nom, Prenom, DateNaiss
from Abonné,Abonnement,LouerNum
where Abonnement.nom=Abonne.nom_Abonnement and LouerPhys.Numero=Abonne.numero
and Abonnement.LocationMax+LouerPhys.DateDebut >=Abonnement.DureeLoc

BEGIN

OPEN C_retardPhys
FETCH NEXT FROM C_retardPhys into @v_nom, @v_prenom, @v_dateNaiss

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Liste des abonnes avec un retard en cours'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_nom + ' '+ @v_prenom
   	 FETCH NEXT FROM C_retardPhys into @v_nom, @v_prenom, @v_dateNaiss
    END
END
CLOSE C_retardPhys
DEALLOCATE C_retardPhys
END
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROCrenouvellementAbo
/*list doit payer*/
create or alter procedure PROCrenouvellementAbo
AS
DECLARE @v_nom Nom_t
DECLARE @v_prenom prenom_t
DECLARE @v_dateNaiss dateNaiss_t
DECLARE C_renouvellement CURSOR FOR
	select Nom, Prenom, DateNaiss
	from Abonné
	where renouvellement < getdate()
BEGIN
	OPEN C_renouvellement
	FETCH NEXT FROM C_renouvellement into @v_nom, @v_prenom, @v_dateNaiss
	IF @@FETCH_STATUS <> 0
	Begin
		print 'Aucun Abonne n a besoin de renouveler son abonnement'
	End
	ELSE
	BEGIN
		While @@FETCH_STATUS = 0
		BEGIN
			IF(Exists(select * from LouerNum where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss and DateFin is not null or DateFin < GETDATE()))
			Begin
   				print 'attention : location en cours pour l abonne '+@v_nom+ ' '+@v_prenom
			End
			ELSE
			Begin
				IF(Exists(select * from LouerPhys where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss and DateFin is not null or DateFin < GETDATE()))
				Begin
   					print 'attention : location en cours pour l abonne '+@v_nom+ ' '+ @v_prenom
				End
				ELSE
				Begin
   					IF((GETDATE()-(select renouvellement from Abonné where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss))>7)
   					BEGIN
   						delete from Abonné where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss
   						delete from Personne where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss
   					END
   					ELSE
					Begin
   						print 'L abonne '+@v_nom+ ' '+ @v_prenom+' doit renouveller son abonnement' 
					End
				End
			End
			FETCH NEXT FROM C_renouvellement into @v_nom, @v_prenom, @v_dateNaiss
		END
	END
	CLOSE C_renouvellement
	DEALLOCATE C_renouvellement
END

//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROClitigePhys
/*list retard de plus de 7j*/
create procedure PROClitigePhys
@P_numClient Numero_t
AS
Declare @v_nb int
Declare @politique tinyint
begin 
	set @politique=0
	set @v_nb=(select*
	from Film,Version,Physique,LouerPhys,Abonnement,Abonne
	where Film.titreVF=Version.titreVF and Version.dateV=Numerique.dateV and Physique.dateV=louerPhys.dateV and Physique.edition=louerPhys.edition and LouerPhys.numero=Abonne.numero
	and Physique.id=LouerPhys.id and Abonne.nom_abonnement=Abonnement.nom and Abonne.numero=@P_numclient and (getdate()-7>datedebut + dureeloc))
	
	if @v_nb >= 1
		set @politique=@politique+1
		print 'L abonne numero '+str(@P_numClient)+' a du retard de plus d une semaine'
end
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure PROClitigeNum
/*list retard de plus de 7j*/
create procedure PROClitigeNum
@P_numClient Numero_t
AS
Declare @v_nb int
Declare @politique tinyint
begin 
	set @politique=0
	set @v_nb=(select*
	from Film,Version,Numérique,LouerNum,Abonnement,Abonné
	where Film.titreVF=Version.titreVF and Version.dateV=Numerique.dateV and Numerique.dateV=louerNum.dateV and Numerique.edition=louerNum.edition and LouerNum.numero=Abonne.numero
	and Abonne.nom_abonnement=Abonnement.nom and Abonne.numero=@P_numclient and (getdate()-7>datedebut + dureeloc))
	
	if @v_nb >= 1
		set @politique=@politique+1
		print 'L abonne numero '+str(@P_numClient)+' a du retard de plus d une semaine'
end
exec PROClitigeNum 99
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcAbonner
/*insert dans abonne*/
create procedure ProcAbonner
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t, @P_Abonnement Abonnement_t, @P_num Numero_t, @P_adr adresse_t,
@P_tel telephone_t, @P_Renouvellement renouvellement_t, @P_anciennete anciennete_t, @P_politique politique_t
as
BEGIN
	if (exists( select * from Abonné where Prenom = @P_Prenom and Nom = @P_Nom and DateNaiss = @P_DateNaiss))
		BEGIN
			update Abonné set Nom_Abonnement = @P_Abonnement, Renouvellement = @P_Renouvellement 
			where Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss
		END
	else
		BEGIN
			if(Exists(select * from Personne where Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss))
				insert into Abonné values(@P_num,@P_adr,@P_tel,@P_Renouvellement,@P_anciennete,@P_politique,@P_Nom,@P_Prenom,@P_DateNaiss,@P_Abonnement)
			else
			begin
				insert into Personne values (@P_Nom, @P_Prenom, @P_DateNaiss)
				insert into Abonné values(@P_num,@P_adr,@P_tel,@P_Renouvellement,@P_anciennete,@P_politique,@P_Nom,@P_Prenom,@P_DateNaiss,@P_Abonnement)
			end
		END
END

exec ProcAbonner 'Quentin', 
'Joubert',
'1997-02-04',
'Asticot', 
99, 
'37 rue louis Morard 75014 Paris', 
069, 
'2019-08-01', 
1,
1

//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ProcAbonneAdresse

create procedure ProcAbonneAdresse
@P_numero Numero_t
as
declare @v_adresse adresse_t
begin
	set @v_adresse=(select adresse
	    		from abonné
			where numero=@P_numero)
	if @v_adresse is null
	   print 'L adresse de l abonne numero '+str(@P_numero)+' n est pas renseignee'
	else
	   print 'L adresse de l abonne numero '+str(@P_numero)+' est '+@v_adresse
end

create or alter procedure PROCModifierAbo
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t, @P_Abonnement Abonnement_t
AS
BEGIN
	IF(@P_Abonnement = 'NULL')
	Begin
		delete from Abonné where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss
   		delete from Personne where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss

   		print 'Les modification on bien ete enregistré'
	END
	ELSE
	Begin
		update Abonné set Nom_Abonnement = @P_Abonnement, Renouvellement = GETDATE() 
			where Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss

   		print 'Les modification on bien ete enregistré'
	END
END