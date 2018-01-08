drop procedure ProcAbonneAdresse

create procedure ProcAbonneAdresse
@P_numero Numero_t
as
declare @v_adresse adresse_t
begin
	set @v_adresse=(select adresse
	    		from abonne
			where numero=@P_numero)
	if @v_adresse is null
	   print 'L adresse de l abonne numero '+@P_numero+' n est pas renseignee'
	else
	   print 'L adresse de l abonne numero '+@P_numero+' est '+@v_adresse
end

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
	   
create type Langue_t from Varchar(25)

drop procedure ProcLangueBandeSon

create procedure ProcLangueBandeSon
@P_titre TitreVF_t
as
declare @v_langue Langue_t

declare C_langueBS cursor for
select langue
from langue l,vocaliser v
where l.langue=v.langue and v.titreVF=@P_titre

begin

open C_langueBS
fetch next from C_langueBS into @P_titre

if @@FETCH_STATUS <> 0
   print 'Aucune langue disponible pour la bande son du film '+@P_titre
else
   print 'Liste des langues disponibles pour le film '+@P_titre
   while @@FETCH_STATUS == 0
   begin
	print @v_langue
	fetch next from C_langueBS into @v_langue
   end
end
close C_langueBS
deallocate C_langueBS

end

drop procedure ProcLangueSousTitre

create procedure ProcLangueSousTitre
@P_titre TitreVF_t
as
declare @v_langue Langue_t

declare C_langueST cursor for
select langue
from langue l,sous_titrer s
where l.langue=s.langue and v.titreVF=@P_titre

begin

open C_langueST
fetch next from C_langueBS into @P_titre

if @@FETCH_STATUS <> 0
   print 'Aucune langue disponible pour la bande son du film '+@P_titre
else
   print 'Liste des langues disponibles pour le film '+@P_titre
   while @@FETCH_STATUS == 0
   begin
	print @v_langue
	fetch next from C_langueST into @v_langue
   end
end
close C_langueST
deallocate C_langueST

end

create type DateLoc_t from date

drop procedure ProcLocPhys

create procedure ProcLocPhys
@P_dateDebut Dateloc_t
as
declare @v_numero Numero_t

declare C_locPhys cursor for
select numero
from abonne a,louerPhys l
where a.numero=l.numero and l.DateDebut=@dateDebut

begin

open C_locPhys
fetch next from C_locPhys into @v_numero

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a effectue de location physique le '+@P_dateDebut
else
   print 'Liste des abonnes qui ont effectue au moins une location physique le '+@P_dateDebut
   while @@FETCH_STATUS == 0
   begin
	print @v_numero
	fetch next from C_locPhys into @v_numero
   end
end
close C_locPhys
deallocate C_locPhys

end

drop procedure ProcLocNum

create procedure ProcLocNum
@P_dateDebut Dateloc_t
as
declare @v_numero Numero_t

declare C_locNum cursor for
select numero
from abonne a,louerPhys l
where a.numero=l.numero and l.DateDebut=@dateDebut

begin

open C_locNum
fetch next from C_locNum into @v_numero

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a effectue de location numerique le '+@P_dateDebut
else
   print 'Liste des abonnes qui ont effectue au moins une location numerique le '+@P_dateDebut
   while @@FETCH_STATUS == 0
   begin
	print @v_numero
	fetch next from C_locNum into @v_numero
   end
end
close C_locNum
deallocate C_locNum

end

drop procedure ProcRetourLocPhys

create procedure ProcRetourLocPhys
@P_dateFin Dateloc_t
as
declare @v_numero Numero_t

declare C_locPhys cursor for
select numero
from abonne a,louerPhys l
where a.numero=l.numero and l.DateFin=@dateFin

begin

open C_retourLocPhys
fetch next from C_retourLocPhys into @v_numero

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a une location physique a rendre le '+@P_dateFin
else
   print 'Liste des abonnes qui doivent rentre leur(s) location(s) physique(s) le '+@P_dateFin
   while @@FETCH_STATUS == 0
   begin
	print @v_numero
	fetch next from C_retourLocPhys into @v_numero
   end
end
close C_retourLocPhys
deallocate C_retourLocPhys

end

drop procedure ProcRetourLocNum

create procedure ProcRetourLocNum
@P_dateFin Dateloc_t
as
declare @v_numero Numero_t

declare C_locPhys cursor for
select numero
from abonne a,louerNum l
where a.numero=l.numero and l.DateFin=@dateFin

begin

open C_retourLocNum
fetch next from C_retourLocNum into @v_numero

if @@FETCH_STATUS <> 0
   print 'Aucun abonne n a une location numerique a rendre le '+@P_dateFin
else
   print 'Liste des abonnes qui doivent rentre leur(s) location(s) numerique(s) le '+@P_dateFin
   while @@FETCH_STATUS == 0
   begin
	print @v_numero
	fetch next from C_retourLocNum into @v_numero
   end
end
close C_retourLocNum
deallocate C_retourLocNum

end















































