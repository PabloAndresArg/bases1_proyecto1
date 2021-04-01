OPTIONS (SKIP=1)
LOAD DATA
INFILE 'Fuente.csv'

into table temp
fields terminated by ';'
optionally enclosed by '"'
(nombre_eleccion,
anio_eleccion,
pais,
region,
departamento,
municipio,
partido,
nombre_partido,
sexo,
raza,
analfabetos,
alfabetos,
sexo_2,
raza_2,
primaria,
nivel_medio,
universitario
)