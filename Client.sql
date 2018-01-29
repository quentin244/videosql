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
	print 'Aucun abonné correspondant'
ELSE
	BEGIN
	    While @@FETCH_STATUS = 0
		BEGIN
   		 print str(@V_num)+' '+@V_Nom+' '+@V_Prenom+' '+@V_Abonnement+' '+str(@V_tel)+' '+ convert(varchar,@V_DateNaiss)+' '+@V_adr+' '+str(@V_anciennete)+' '+str(@V_politique)+' '+convert(varchar,@V_Renouvellement);
   		 FETCH NEXT FROM C_check into @V_num, @V_Nom, @V_Prenom, @V_Abonnement, @V_tel, @V_DateNaiss, @V_adr, @V_anciennete, @V_politique, @V_Renouvellement
		END
	END
	CLOSE C_check
DEALLOCATE C_check
END
exec CheckAbo 'Thebase','Whenday'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure EstAbo
/*Prend une clef primaire d'abonne et print si elle est dans la bdd*/
create procedure EstAbo
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
Declare @v_Numero Numero_t
Declare @true tinyint
Declare @abonne tinyint

BEGIN
    IF (Exists (select * from Abonné where Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss))
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

exec EstAbo 'Thebase','Whenday','1984-11-08'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure AvantAbo
/*list caract d'un abonnement*/
create procedure AvantAbo
@P_abo Abonnement_t
AS
DECLARE @v_prix PrixAbonnement_t = (select prix from Abonnement where nom=@P_abo)
DECLARE @v_nb NbFilms_t = (select LocationMax from Abonnement where nom=@P_abo)
DECLARE @v_dureeLoc Duree_t = (select DureeLoc from Abonnement where nom=@P_abo)

BEGIN
    print 'Avec l abonnement '+@P_abo+' pour' + str(@v_prix)+' euros on peut louer '+ str(@v_nb)+' films pendant une duree de '+str(@v_dureeLoc)+' jours'
END

exec AvantAbo 'Asticot'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure AvantAboTout
/*Liste des abonnes avec un retard en cours*/
create procedure AvantAboTout
AS
Declare @v_nom Abonnement_t
DECLARE @v_prix PrixAbonnement_t
DECLARE @v_nb NbFilms_t
DECLARE @v_dureeLoc Duree_t

DECLARE C_Abo CURSOR FOR
Select Nom, prix, LocationMax, DureeLoc
From Abonnement
BEGIN

OPEN C_Abo
FETCH NEXT FROM C_Abo into @v_nom, @v_prix, @v_nb, @v_dureeLoc
IF @@FETCH_STATUS <> 0
    print 'Aucun abonnement repertorié'
ELSE
BEGIN
    While @@FETCH_STATUS = 0
    BEGIN
   	 print 'Avec l abonnement '+@v_nom+' pour' + str(@v_prix)+' euros on peut louer '+ str(@v_nb)+' films pendant une duree de '+str(@v_dureeLoc)+' jours'
   	 FETCH NEXT FROM C_Abo into @v_nom, @v_prix, @v_nb, @v_dureeLoc
    END
END
CLOSE C_Abo
DEALLOCATE C_Abo
END

exec AvantAboTout
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RetardNum
/*list abonne en retard*/
create procedure RetardNum
AS
DECLARE @v_num Numero_t
DECLARE @v_nom Nom_t
DECLARE @v_prenom prenom_t
DECLARE @v_dateNaiss dateNaiss_t

DECLARE C_retardNum CURSOR FOR
Select Nom, Prenom, DateNaiss
From LouerNum
where(DateFin >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerNum.prenom and Abonné.nom = LouerNum.nom and Abonné.DateNaiss = LouerNum.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))
OR (getdate() >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerNum.prenom and Abonné.nom = LouerNum.nom and Abonné.DateNaiss = LouerNum.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))))

BEGIN

OPEN C_retardNum
FETCH NEXT FROM C_retardNum into @v_nom, @v_prenom, @v_dateNaiss

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Liste des abonnes avec un retard en cours'
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_nom + ' '+ @v_prenom
   	 FETCH NEXT FROM C_retardNum into @v_nom, @v_prenom, @v_dateNaiss
    END
END
CLOSE C_retardNum
DEALLOCATE C_retardNum

END

exec RetardNum
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RetardPhys
/*list abonne en retard*/
create procedure RetardPhys
AS
DECLARE @v_num Numero_t
DECLARE @v_nom Nom_t
DECLARE @v_prenom prenom_t
DECLARE @v_dateNaiss dateNaiss_t

DECLARE C_retardPhys CURSOR FOR
Select Nom, Prenom, DateNaiss
From LouerPhys
where (DateFin >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))
OR (getdate() >=(Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom)))

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

exec RetardPhys
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RetardNumPers

create procedure RetardNumPers
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
DECLARE @v_TitreVf TitreVF_t

DECLARE C_retardNum CURSOR FOR
Select TitreVF
From LouerNum
where Nom = @P_Prenom
And Prenom = @P_Nom
And DateNaiss = @P_DateNaiss
And(DateFin >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerNum.prenom and Abonné.nom = LouerNum.nom and Abonné.DateNaiss = LouerNum.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))
OR (getdate() >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerNum.prenom and Abonné.nom = LouerNum.nom and Abonné.DateNaiss = LouerNum.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))))

BEGIN

OPEN C_retardNum
FETCH NEXT FROM C_retardNum into @v_TitreVf

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Les retard de ''abonne' + @P_Prenom + ' '+ @P_Nom
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_TitreVf
   	 FETCH NEXT FROM C_retardNum into @v_TitreVf
    END
END
CLOSE C_retardNum
DEALLOCATE C_retardNum

END


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RetardPhysPers

create procedure RetardPhysPers
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
DECLARE @v_TitreVf TitreVF_t

DECLARE C_retardPhys CURSOR FOR
Select TitreVF
From LouerPhys
where Nom = @P_Prenom
And Prenom = @P_Nom
And DateNaiss = @P_DateNaiss
And ((DateFin >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom)))
OR (getdate() >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))))

BEGIN

OPEN C_retardPhys
FETCH NEXT FROM C_retardPhys into @v_TitreVf

IF @@FETCH_STATUS <> 0
    print 'Aucun abonne n a de retard'
ELSE
BEGIN
    print 'Les retard de ''abonne' + @P_Prenom + ' '+ @P_Nom
    While @@FETCH_STATUS = 0
    BEGIN
   	 print @v_TitreVf
   	 FETCH NEXT FROM C_retardPhys into @v_TitreVf
    END
END
CLOSE C_retardPhys
DEALLOCATE C_retardPhys
END


//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure RenouvellementAbo
/*list doit payer*/
create procedure RenouvellementAbo
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
			IF(Exists(select * from LouerNum where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss and DateFin is null or DateFin > GETDATE()))
			Begin
   				print 'attention : location en cours pour l abonne '+@v_nom+ ' '+@v_prenom
			End
			ELSE
			Begin
				IF(Exists(select * from LouerPhys where Nom=@v_nom and Prenom=@v_prenom and DateNaiss= @v_dateNaiss and DateFin is null or DateFin > GETDATE()))
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

exec RenouvellementAbo
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure Abonner
/*insert dans abonne*/
create procedure Abonner
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

exec Abonner 'Quentin','Joubert','1997-02-04','Asticot',069, '37 rue louis Morard 75014 Paris',069,'2019-08-01',1,1
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure AbonneAdresse

create procedure AbonneAdresse
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

exec AbonneAdresse 069
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure ModifierAbo

create procedure ModifierAbo
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t, @P_Abonnement Abonnement_t
AS
BEGIN
IF(Exists(select * from Abonné where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss))
Begin
	IF(@P_Abonnement = 'NULL')
	BEGIN
		IF(Exists(select * from LouerNum where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss and DateFin is null or DateFin > GETDATE()))
		Begin
   			print 'attention : l''abonne a des location en cours '
		End
		ELSE
		Begin
			IF(Exists(select * from LouerPhys where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss and DateFin is null or DateFin > GETDATE()))
			Begin
   				print 'attention : l''abonne a des location en cours' 
			End
			ELSE
			Begin
				delete from Abonné where Nom=@P_Nom and Prenom=@P_Prenom and DateNaiss= @P_DateNaiss
   				print 'L''abonnée a bien ete supprimer'
			END
		End
	End
	ELSE
	Begin
		update Abonné set Nom_Abonnement = @P_Abonnement, Renouvellement = GETDATE() 
		where Nom=@P_Nom and Prenom = @P_Prenom and DateNaiss = @P_DateNaiss
   		print 'Les modification ont bien ete enregistré'
	END
END
Else
print 'L''abonnée n''existe pas'
End

exec ModifierAbo 'Quentin', 'Joubert', '1997-02-04', 'NULL'
exec ModifierAbo 'Camus','Albert','1952-01-01', 'NULL'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LitigePhys
/*list retard de plus de 7j*/
create procedure LitigePhys
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
Declare @v_TitreVF TitreVF_t
DECLARE C_LitigePhys CURSOR FOR 
Select TitreVF
From LouerPhys
where Nom = @P_Prenom
And Prenom = @P_Nom
And DateNaiss = @P_DateNaiss
And DateFin >=((DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerPhys.prenom and Abonné.nom = LouerPhys.nom and Abonné.DateNaiss = LouerPhys.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom)) +7)
begin 
OPEN C_LitigePhys
	FETCH NEXT FROM C_LitigePhys into @v_TitreVF
	IF @@FETCH_STATUS <> 0
	Begin
		print 'Aucun litige de plus d''une semaine'
	End
	ELSE
	BEGIN
	print 'L abonne numero '+@P_Prenom + @P_Nom+' a du retard de plus d une semaine sur :'
		While @@FETCH_STATUS = 0
		BEGIN
		print @v_TitreVF
		FETCH NEXT FROM C_LitigePhys into @v_TitreVF
		End
	END
	CLOSE C_LitigePhys
	DEALLOCATE C_LitigePhys
end

exec LitigePhys 'Albert','Camus','1952-01-01'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure LitigeNum
/*list retard de plus de 7j*/
create procedure LitigeNum
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
Declare @v_TitreVF TitreVF_t
DECLARE C_LitigeNum CURSOR FOR 
Select TitreVF
From LouerNum
where Nom = @P_Prenom
And Prenom = @P_Nom
And DateNaiss = @P_DateNaiss
And DateFin >=(DateDebut + (Select DureeLoc From Abonnement, Abonné where Abonné.prenom = LouerNum.prenom and Abonné.nom = LouerNum.nom and Abonné.DateNaiss = LouerNum.DateNaiss And Abonné.Nom_Abonnement = Abonnement.Nom))+7
begin 
OPEN C_LitigeNum
	FETCH NEXT FROM C_LitigeNum into @v_TitreVF
	IF @@FETCH_STATUS <> 0
	Begin
		print 'Aucun litige de plus d''une semaine'
	End
	ELSE
	BEGIN
	print 'L abonne numero '+@P_Prenom + @P_Nom+' a du retard de plus d une semaine sur :'
		While @@FETCH_STATUS = 0
		BEGIN
		print @v_TitreVF
		FETCH NEXT FROM C_LitigeNum into @v_TitreVF
		End
	END
	CLOSE C_LitigeNum
	DEALLOCATE C_LitigeNum
end

exec LitigeNum 'Allo','Mais','1929-21-06'
//////////////////////////////////////////////////////////////////////////////////////////////////
drop procedure FilmLouerClient

create procedure FilmLouerClient
@P_Prenom prenom_t, @P_Nom nom_t, @P_DateNaiss dateNaiss_t
AS
Declare @v_TitreVF TitreVF_t
Declare @v_DateDebut date

DECLARE C_Locphys CURSOR FOR 
Select TitreVF, DateDebut
From LouerPhys
where Nom = @P_Prenom
And Prenom = @P_Nom
And DateNaiss = @P_DateNaiss
And DateFin is null
begin 
OPEN C_Locphys
	FETCH NEXT FROM C_Locphys into @v_TitreVF, @v_DateDebut
	IF @@FETCH_STATUS <> 0
	Begin
		print 'Aucune location en cours'
	End
	ELSE
	BEGIN
	print 'L abonne numero '+@P_Prenom + @P_Nom+' a en cours de location :'
		While @@FETCH_STATUS = 0
		BEGIN
		print @v_TitreVF + ' ' + convert(Varchar, @v_DateDebut) 
		FETCH NEXT FROM C_Locphys into @v_TitreVF, @v_DateDebut
		End
	END
	CLOSE C_Locphys
	DEALLOCATE C_Locphys
end

exec FilmLouerClient 'Albert','Camus','1952-01-01'