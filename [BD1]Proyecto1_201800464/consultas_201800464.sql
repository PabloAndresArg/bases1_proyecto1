-- use database PorsiAcaso




/*
    CONSULTA 1:
    Desplegar para cada elección el país y el partido político que obtuvo mayor
    porcentaje de votos en su país. Debe desplegar el nombre de la elección, el
    año de la elección, el país, el nombre del partido político y el porcentaje que
    obtuvo de votos en su país.
*/


select eleccion.nombre as eleccion_ , pais.nombre as PAIS , eleccion.anio as anio , partido.nombre as NOmbre_partido ,  Round(MAX(todos_los_paises.porcentaje),5) as porcentaje
FROM (
    select distinct ele.nombre as nombre , ele.anio as year, pais.nombre as pais_ , par.id as partido_id,( SUM((conteo.analfabetos + conteo.alfabetos)/tot.total) *100) as porcentaje 
        FROM ( -- SACO LA CANTIDAD DE total VOTOS POR PAIS , ANIO y partido
            select e.nombre as elect , e.anio as year, pais.nombre as country,sum(cv.analfabetos + cv.alfabetos)  as total   
            from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep
            where pais.id = r.pais_id 
            and r.id = d.region_id
            and d.id = m.departamento_id
            and e.id = ep.Eleccion_id
            and p.id = ep.partido_id
            and cv.eleccion_partido_id = ep.id
            and cv.municipio_id = m.id
            GROUP BY e.nombre , e.anio, pais.nombre 
        )  tot ,
        Eleccion ele , Pais  , Conteo_Voto conteo , Region reg , Departamento dep , Municipio mun ,Partido par , Eleccion_Partido   elep
        where pais.id = reg.pais_id 
        and reg.id = dep.region_id
        and dep.id = mun.departamento_id
        and ele.id = elep.Eleccion_id
        and par.id = elep.partido_id
        and conteo.eleccion_partido_id = elep.id
        and conteo.municipio_id = mun.id
        and pais.nombre = tot.country -- para que sea lo de adentro igual a lo de afuera y hagan match :v
        GROUP BY ele.nombre , ele.anio,  pais.nombre ,  par.id   
    ) todos_los_paises , pais , eleccion , partido
where pais.nombre = todos_los_paises.pais_
AND eleccion.nombre = todos_los_paises.nombre
AND eleccion.anio = todos_los_paises.year
AND partido.id = todos_los_paises.partido_id
AND todos_los_paises.porcentaje = porcentaje
GROUP BY eleccion.nombre  ,  pais.nombre  , eleccion.anio , partido.nombre 
order by porcentaje DESC FETCH FIRST 2 ROW ONLY
;





/*
    CONSULTA 2:
    Desplegar total de votos y porcentaje de votos de mujeres por
    departamento y paï¿½s. El ciento por ciento es el total de votos de mujeres por
    paï¿½s
*/



select tot.total as TOTAL_VOTOS ,sex.sexo, pais.nombre , dep.nombre , round( (sum((conteo.analfabetos + conteo.alfabetos)/tot.total) ) * 100,3)  as porcentaje FROM
(
    select pais.id,  pais.nombre as country, sexo.sexo as sexo, sum(cv.analfabetos + cv.alfabetos)  as total   
    from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep ,sexo  
    where pais.id = r.pais_id  and r.id = d.region_id and d.id = m.departamento_id and e.id = ep.Eleccion_id and p.id = ep.partido_id and cv.eleccion_partido_id = ep.id
    and cv.municipio_id = m.id
    and cv.Sexo_id = sexo.id
    and sexo.sexo = 'mujeres'
    GROUP BY pais.id , pais.nombre , sexo.sexo
) tot, Pais  , Conteo_Voto conteo , Region reg  , Municipio mun , sexo sex , departamento dep
where  pais.id  = reg.pais_id 
and reg.id = dep.region_id
and tot.country = pais.nombre
and dep.id = mun.departamento_id
and conteo.municipio_id = mun.id
and conteo.Sexo_id = sex.id
and sex.sexo = 'mujeres'
GROUP BY  tot.total , sex.sexo, pais.nombre , dep.nombre 
order by pais.nombre ASC
;


/*
    CONSULTA 3: (alcaldias = municipios ? ) 
    
    Desplegar el nombre del paï¿½s, nombre del partido polï¿½tico y nï¿½mero de
    alcaldï¿½as de los partidos polï¿½ticos que ganaron mï¿½s alcaldï¿½as por paï¿½s.
*/

SELECT * FROM(     
    select ganadores_por_muni.anio,ganadores_por_muni.pais,ganadores_por_muni.partido , COUNT(ganadores_por_muni.partido)  as alcaldias 
        ,ROW_NUMBER() OVER(PARTITION BY ganadores_por_muni.anio,ganadores_por_muni.pais  ORDER BY COUNT(ganadores_por_muni.partido)  desc) as enumeracion_Puesto -- PARA SACAR EL PARTIDO CON QUE HA GANADO MAS VECES
        FROM( -- mas votos obtuvo por municipio , pais y por partido 
        
                select e.anio as anio , pa.nombre as pais ,  m.nombre as municipio , p.nombre as partido  , sum(cv.analfabetos + cv.alfabetos) as votos_obtenidos,
                ROW_NUMBER() OVER(PARTITION BY e.anio , pa.nombre , m.nombre ORDER BY sum(cv.alfabetos + cv.analfabetos) desc) as enumeracion
                FROM Eleccion e 
                INNER JOIN Eleccion_Partido  ep ON  e.id = ep.Eleccion_id
                INNER JOIN Partido p ON p.id = ep.Partido_id
                INNER JOIN Conteo_Voto cv ON cv.eleccion_partido_id = ep.id
                INNER JOIN Municipio m  ON  cv.Municipio_id = m.id
                INNER JOIN Departamento d  on  m.Departamento_id = d.id 
                INNER JOIN Region r ON  d.Region_id = r.id
                INNER JOIN Pais pa ON  pa.id = r.Pais_id 
                GROUP BY e.anio , pa.nombre , m.nombre , p.nombre
                order by pa.nombre ASC
                
        ) ganadores_por_muni
    where enumeracion = 1
    GROUP BY ganadores_por_muni.anio,ganadores_por_muni.pais,ganadores_por_muni.partido 
    ORDER BY ganadores_por_muni.pais ASC 
)  where enumeracion_Puesto = 1; -- pido solo los que mas veces han ganado











/*
    CONSULTA 4:
    Desplegar todas las regiones por paï¿½s en las que predomina la raza indï¿½gena.
    Es decir, hay mï¿½s votos que las otras razas.
*/

select  indigena.pais , indigena.region , indigena.tot_votos as votos_raza_indigena , indigena.raza as RAZA_DOMINANTE
FROM 
(
    select raza.raza as raza  ,  r.nombre as region ,  pais.nombre as pais , SUM(cv.alfabetos +  cv.analfabetos)as tot_votos
    FROM  Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep , raza 
    WHERE  e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and  cv.eleccion_partido_id = ep.id 
    and raza.id = cv.raza_id and raza.raza = 'INDIGENAS'
    GROUP BY raza.raza , r.nombre , pais.nombre order by pais.nombre desc
) indigena ,
(
    select raza.raza as raza ,  r.nombre as region ,  pais.nombre as pais , SUM(cv.alfabetos +  cv.analfabetos )as tot_votos
    FROM  Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep , raza 
    WHERE  e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and  cv.eleccion_partido_id = ep.id 
    and raza.id = cv.raza_id and raza.raza = 'GARIFUNAS'
    GROUP BY raza.raza , r.nombre , pais.nombre order by pais.nombre desc
) GARIFUNAS ,
(
    select raza.raza as raza ,  r.nombre as region ,  pais.nombre as pais , SUM(cv.alfabetos +  cv.analfabetos )as tot_votos
    FROM  Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep , raza 
    WHERE  e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and  cv.eleccion_partido_id = ep.id 
    and raza.id = cv.raza_id and raza.raza = 'LADINOS'
    GROUP BY raza.raza , r.nombre , pais.nombre order by pais.nombre desc
) LADINOS
WHERE  indigena.region = LADINOS.region and indigena.pais = LADINOS.pais  AND indigena.region = GARIFUNAS.region and indigena.pais = GARIFUNAS.pais 
AND indigena.tot_votos > GARIFUNAS.tot_votos AND indigena.tot_votos > LADINOS.tot_votos
GROUP BY indigena.region, indigena.pais , indigena.tot_votos , indigena.raza
ORDER BY indigena.pais; 










/*  CONSULTA  5:
    Desplegar el porcentaje de mujeres universitarias y hombres universitarios
    que votaron por departamento, donde las mujeres universitarias que
    votaron fueron mï¿½s que los hombres universitarios que votaron
*/
select tbMujeres.departamento , 
CONCAT (round((tbMujeres.totalVotos/(tbHombres.total+tbMujeres.total)) *100,1),' %') as Porcentaje_Mujeres, 
CONCAT (round((tbHombres.totalVotos /(tbHombres.total+tbMujeres.total)) *100 ,1) , ' %')  as Porcentaje_Hombres , 
tbMujeres.totalVotos votos_mujeres , tbHombres.totalVotos votos_Hombres
from(
select d.nombre as departamento ,s.sexo as  sexo, sum(cv.universitarios) as totalVotos  , sum(cv.alfabetos + cv.analfabetos) as total
from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep, sexo s
where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
and cv.Sexo_id = s.id and cv.eleccion_partido_id = ep.id
and m.Departamento_id = d.id and cv.Municipio_id = m.id 
and s.sexo = 'mujeres'
group by d.nombre,s.sexo
) tbMujeres , 
(
select d.nombre as departamento ,s.sexo as  sexo, sum(cv.universitarios) as totalVotos  , sum(cv.alfabetos + cv.analfabetos) as total
from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep, sexo s
where e.id = ep.Eleccion_id and p.id = ep.Partido_id 
and cv.Sexo_id = s.id and  cv.eleccion_partido_id = ep.id
and pais.id = r.Pais_id and d.Region_id = r.id
and m.Departamento_id = d.id and cv.Municipio_id = m.id 
and s.sexo = 'hombres'
group by d.nombre,s.sexo
) tbHombres 
where tbMujeres.departamento = tbHombres.departamento and tbMujeres.totalVotos > tbHombres.totalVotos;








/*  CONSULTA 6: 
Desplegar el nombre del paï¿½s, la regiï¿½n y el promedio de votos por
departamento. Por ejemplo: Si la regiï¿½n tiene tres departamentos, se debe
sumar todos los votos de la regiï¿½n y dividirlo dentro de tres (nï¿½mero de
departamentos de la regiï¿½n).
*/


SELECT conteo_regiones.pais , conteo_regiones.region , 
TRUNC((sum(conteo_regiones.votos) / COUNT(conteo_regiones.departamento))) as Promedio_Votos
from ( 
    select  pais.nombre as pais , r.nombre as region , d.nombre as departamento , SUM(cv.analfabetos +  cv.alfabetos)  as votos -- TENGO EL TOTAL DE VOTOS POR PAIS,REGION,DEP
    FROM Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep
    where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id
    group by pais.nombre , r.nombre , d.nombre
) conteo_regiones
GROUP BY conteo_regiones.pais, conteo_regiones.region ORDER BY conteo_regiones.pais  DESC;


/*
    CONSULTA 7:
    Desplegar el nombre del municipio y el nombre de los dos partidos polï¿½ticos
    con mï¿½s votos en el municipio, ordenados por paï¿½s.
*/



select  tabla_aux.*
FROM(
    select m.nombre as Municipio ,pa.nombre as Pais , p.nombre as Partido, sum(cv.alfabetos + cv.analfabetos) as Votos_obtenidos,
    ROW_NUMBER() OVER(PARTITION BY Pa.nombre , m.nombre ORDER BY sum(cv.alfabetos + cv.analfabetos) desc) as enumeracion
    /* ROW_NUMBER() OVER: enumera al pais,municipio cada vez que alguno cambia reinicia el index */
    FROM Eleccion e
    INNER JOIN Eleccion_Partido  ep ON  e.id = ep.Eleccion_id
    INNER JOIN Partido p ON p.id = ep.Partido_id
    INNER JOIN Conteo_Voto cv ON cv.eleccion_partido_id = ep.id
    INNER JOIN Municipio m  ON  cv.Municipio_id = m.id
    INNER JOIN Departamento d  on  m.Departamento_id = d.id
    INNER JOIN Region r ON  d.Region_id = r.id
    INNER JOIN Pais pa ON  pa.id = r.Pais_id
    group by
    m.nombre, pa.nombre,p.nombre
) tabla_aux
where
tabla_aux.enumeracion <= 2; -- solo deja jalar la enumeracion si esta afuera ya que espera a que se cree el group by













/*
    CONSULTA 8:
    Desplegar el total de votos de cada nivel de escolaridad (primario, medio,
    universitario) por paï¿½s, sin importar raza o sexo
*/

SELECT pa.nombre as PAIS ,  SUM(cv.primaria) as Primaria , SUM(cv.nivel_medio) as Nivel_medio, sum(cv.universitarios) as Universitario  
from Conteo_Voto cv 
INNER JOIN municipio m   ON m.id = cv.municipio_id   
INNER JOIN departamento d ON d.id = m.departamento_id
INNER JOIN region r ON r.id = d.region_id 
INNER JOIN Pais pa  ON r.pais_id = pa.id
Group by pa.nombre 
; 








/*
    CONSOLUTA 9:
    Desplegar el nombre del paï¿½s y el porcentaje de votos por raza
*/


select pais.nombre , raza.raza , CONCAT(round((aux.total_por_raza/sin_importar_raza)*100 , 3) , '%') as porcentaje
FROM (
select pais.nombre as PAIS_,  raza.raza as razaEspecifica , sum(cv.analfabetos + cv.alfabetos) as total_por_raza
from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep , raza
where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id AND raza.id = cv.raza_id
GROUP BY  pais.nombre ,  raza.raza 
) aux ,
(
select pais.nombre as PAIS_ , sum(cv.analfabetos + cv.alfabetos) as sin_importar_raza
from Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep 
where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id 
GROUP BY  pais.nombre
) aux2
,
pais , raza
WHERE 
aux.razaEspecifica = raza.raza AND  aux.PAIS_ = pais.nombre 
AND aux2.Pais_ = aux.pais_ and pais.nombre = aux2.pais_
GROUP BY  pais.nombre , raza.raza,(aux.total_por_raza/sin_importar_raza) 
ORDER BY pais.nombre;











/*
CONSULTA 10:
Desplegar el nombre del paï¿½s en el cual las ELECCIONES han sido mï¿½s
peleadas. Para determinar esto se debe calcular la diferencia de porcentajes
de votos entre el partido que obtuvo mï¿½s votos y el partido que obtuvo
menos votos. (La diferencia mï¿½s pequeï¿½a).
*/

select mayor.anio,  mayor.pais ,CONCAT(ROUND((mayor.votos/total.TOTAL_ELECCION)*100,2),' %') as Mayor ,  CONCAT (ROUND((menor.votos/total.TOTAL_ELECCION)*100,2),' %') as Menor 
,  ROUND(((mayor.votos - menor.votos)/total.TOTAL_ELECCION)*100,2) as DIFERENCIA
FROM 
(-- sacar la mayor cantidad de votos por partido-pais
    select aux.*
    FROM(
        select e.anio as anio , pais.nombre as pais ,  p.nombre as partido , sum(cv.analfabetos + cv.alfabetos) as votos ,
        ROW_NUMBER() OVER(PARTITION BY   e.anio ,pais.nombre ORDER BY sum(cv.alfabetos + cv.analfabetos) DESC) as enumeracion
        FROM Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep 
        where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
        and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id 
        GROUP BY  e.anio ,pais.nombre, p.nombre order by  sum(cv.analfabetos + cv.alfabetos) DESC
        ) aux
    where aux.enumeracion = 1
) mayor , 
(-- menor cantidad cantidad de votos por partido-pais
    select aux.*
    FROM(
    select e.anio as anio , pais.nombre as pais ,  p.nombre as partido , sum(cv.analfabetos + cv.alfabetos) as votos,
    ROW_NUMBER() OVER(PARTITION BY   e.anio ,pais.nombre ORDER BY sum(cv.alfabetos + cv.analfabetos) ASC) as enumeracion
    FROM Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep 
    where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id 
    GROUP BY  e.anio ,pais.nombre, p.nombre order by  sum(cv.analfabetos + cv.alfabetos)  ASC
    )aux where aux.enumeracion = 1 
) menor
,(-- el total en esa eleccion
    select e.anio as anio , pais.nombre as pais , sum(cv.analfabetos + cv.alfabetos) as TOTAL_ELECCION 
    FROM Eleccion e , Pais  , Conteo_Voto cv , Region r , Departamento d , Municipio m ,Partido p , Eleccion_Partido   ep 
    where e.id = ep.Eleccion_id and p.id = ep.Partido_id and pais.id = r.Pais_id and d.Region_id = r.id
    and m.Departamento_id = d.id and cv.Municipio_id = m.id and cv.eleccion_partido_id = ep.id 
    GROUP BY  e.anio , pais.nombre
)total
WHERE  mayor.anio = menor.anio and mayor.anio = total.anio and menor.anio = total.anio AND mayor.pais = menor.pais  AND mayor.pais = total.pais 
order by  ((mayor.votos - menor.votos)/total.TOTAL_ELECCION)  ASC  FETCH FIRST 1 ROW ONLY;















/*
CONSULTA 11:
Desplegar el total de votos y el porcentaje de votos emitidos por mujeres
indï¿½genas alfabetas.
*/

SELECT s.sexo as  sexo, sum(cv.alfabetos) as totalVotos  , ROUND( (sum(cv.alfabetos/todo.TotalTodo) *100 ) ,2) as porcentaje
from ( select sum(cv.alfabetos+cv.analfabetos) as TotalTodo from Conteo_Voto cv, sexo,raza  where   raza.id = cv.Raza_id and sexo.id   = cv.sexo_id -- devuelve el total de todo  sin filtro de raza ni distintivo de genero
) todo , Conteo_Voto cv, sexo s,raza ra
where   ra.id = cv.Raza_id and s.id   = cv.sexo_id  and s.sexo ='mujeres' and ra.raza='INDIGENAS'
group by s.sexo;











/*
CONSULTA 12:
Desplegar el nombre del paï¿½s, el porcentaje de votos de ese paï¿½s en el que
han votado mayor porcentaje de analfabetas. (tip: solo desplegar un nombre
de paï¿½s, el de mayor porcentaje).

*/


select * 
FROM (
    select  pais.nombre ,CONCAT(ROUND( (sum(cv.analfabetos/aux.CONTEO_TOTAL)) *100 , 3 ), ' %')as porcentaje_analfabetas_por_pais
    FROM Conteo_Voto cv 
    INNER JOIN municipio m  ON cv.municipio_id = m.id  
    INNER JOIN  departamento d ON  m.departamento_id = d.id 
    INNER JOIN region r ON  d.Region_id = r.id 
    INNER JOIN pais ON  r.Pais_id = pais.id
    INNER JOIN 
    (
        select  pais.nombre as pais_aux,  sum(cv.alfabetos + cv.analfabetos) as CONTEO_TOTAL
        from Conteo_Voto  cv
        INNER JOIN municipio m   ON m.id = cv.municipio_id   
        INNER JOIN departamento d ON d.id = m.departamento_id
        INNER JOIN region r ON r.id = d.region_id 
        INNER JOIN Pais   ON r.pais_id = pais.id
        INNER JOIN Eleccion_Partido   ep  ON cv.eleccion_partido_id = ep.id 
        INNER JOIN Eleccion e ON e.id = ep.Eleccion_id 
        INNER JOIN Partido p ON p.id = ep.Partido_id
        GROUP BY  pais.nombre 
    ) aux ON   pais.nombre = aux.pais_aux
    GROUP by pais.nombre , aux.CONTEO_TOTAL
    ORDER BY  porcentaje_analfabetas_por_pais desc
) aux WHERE ROWNUM = 1;









/*
    CONSULTA 13:
    Desplegar la lista de departamentos de Guatemala y nï¿½mero de votos
    obtenidos, para los departamentos que obtuvieron mï¿½s votos que el
    departamento de Guatemala
*/

    
 SELECT aux1.nombre , aux1.NUMERO_DE_VOTOS_OBTENIDOS
 from 
 (
    SELECT d.nombre , sum( cv.alfabetos + cv.analfabetos ) AS NUMERO_DE_VOTOS_OBTENIDOS
    FROM region r , departamento d , municipio m , Conteo_Voto cv  , pais
    WHERE r.pais_id = pais.id AND cv.municipio_id = m.id AND m.departamento_id = d.id AND  r.id = d.region_id 
    AND pais.nombre = 'GUATEMALA'
    GROUP BY d.nombre
) aux1,
(  -- SACANDO LA CANTIDAD TOTAL DE LOS VOTOS EN EL PAIS DE GUATEMALA Y EL DEPARTAMENTO GUATEMALA
    select SUM( cv.alfabetos + cv.analfabetos ) as total_votos 
    from  Conteo_Voto cv 
    INNER JOIN Municipio m ON cv.municipio_id =  m.id 
    INNER JOIN Departamento d  ON  m.departamento_id = d.id AND d.nombre = 'Guatemala'
    INNER JOIN Region r ON r.id = d.Region_id
    INNER JOIN Pais pa ON pa.nombre = 'GUATEMALA'
) guate
WHERE aux1.NUMERO_DE_VOTOS_OBTENIDOS > guate.total_votos ;















/*  CONSULTA 14:
    Desplegar el total de votos de los municipios agrupados por su letra inicial.
    Es decir, agrupar todos los municipios con letra A y calcular su nu½mero de
    votos, lo mismo para los de letra inicial B, y asï¿½ sucesivamente hasta la Z
*/

Select SUBSTR(LTRIM(REPLACE(m.nombre,' ','')),1,1) as  primerLetra , sum(cv.analfabetos + cv.alfabetos) as numvotos
FROM conteo_voto cv , municipio m 
where cv.municipio_id = m.id
group by SUBSTR(LTRIM(REPLACE(m.nombre,' ','')),1,1)
order by SUBSTR(LTRIM(REPLACE(m.nombre,' ','')),1,1) ASC ;



















-- revision de tablas por separado:
select * from Conteo_Voto;
select * from Eleccion_Partido;
select * from Partido;
select * from Eleccion;
select * from Raza; 
select * from sexo;
select * from Municipio;
select * from Departamento; 
select * from region;
select * from Pais;