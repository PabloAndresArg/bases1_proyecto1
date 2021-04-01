
-- CARGA DE DATOS

-- limpio mis tablas
truncate table Conteo_Voto;
truncate table Eleccion_Partido;
truncate table Partido;
truncate table Eleccion;
truncate table Raza; 
truncate table sexo;
truncate table Municipio;
truncate table Departamento; 
truncate table region;
truncate table Pais;


-- carga de paises -registros 6
insert into Pais(nombre) select distinct pais from temp;

-- carga de regiones -registros 22
insert into Region(nombre,Pais_id) select distinct temp.region , Pais.id
FROM  temp, Pais  where temp.pais = Pais.nombre;

-- carga departamentos - registros 81
INSERT INTO departamento(nombre,region_id)
SELECT DISTINCT t.departamento, r.id 
FROM temp t, region r, pais p
WHERE t.pais = p.nombre
AND r.pais_id = p.id
AND t.region = r.nombre;
 






-- municipios  - registros 1170
insert into Municipio(nombre , Departamento_id )
select distinct t.municipio , d.id
from temp t ,region r ,  departamento d , pais p
where t.departamento = d.nombre
and t.region = r.nombre 
and r.Pais_id = p.id and p.nombre = t.pais;




-- sexo registros 2
insert into Sexo(sexo) 
select distinct sexo from temp
;

-- raza registros 3
insert into Raza(raza) 
(select distinct raza from temp )
;


-- eleccion registros 2 
insert into Eleccion(nombre,anio) select distinct temp.nombre_eleccion,anio_eleccion from temp;

-- partido resgistros - 18
insert into Partido(partido, nombre) select distinct partido,nombre_partido from temp;


-- partido resgistros - 18
insert into Eleccion_Partido(Eleccion_id,partido_id)
select distinct e.id , p.id
from Partido p , Eleccion e , temp t
where e.nombre = t.nombre_eleccion
and e.anio = t.anio_eleccion
and p.nombre = t.nombre_partido
and p.partido = t.partido;




-- CONTEO VOTOS  la cantidad de todos los datos de la tabla temp 20970
insert into Conteo_Voto(
alfabetos , analfabetos , primaria , nivel_medio , universitarios,
Raza_id , Sexo_id , Municipio_id , Eleccion_Partido_id
)
SELECT alfabetos, analfabetos, primaria, nivel_medio, universitario, raz.id, s.id, m.id, ep.id
FROM temp t, raza raz, sexo s, 
partido p, Eleccion_Partido ep, eleccion e, 
municipio m, departamento d, region r, pais a
WHERE raz.raza = t.raza
AND s.sexo = t.sexo
AND ep.partido_id = p.id
AND ep.eleccion_id = e.id
AND p.partido = t.partido
AND p.nombre = t.nombre_partido
AND e.nombre = t.nombre_eleccion
AND e.anio = t.anio_eleccion
AND m.nombre = t.municipio
AND m.departamento_id = d.id
AND d.nombre = t.departamento
AND d.region_id = r.id
AND r.nombre = t.region
AND r.pais_id = a.id
AND a.nombre = t.pais;







