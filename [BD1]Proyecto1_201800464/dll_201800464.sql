-- 201800464 PABLO ANDRES ARGUETA HERNANDEZ
-- createdatabase PorsiAcaso
-- use database PorsiAcaso

CREATE TABLE temp(
    nombre_eleccion varchar2(45) not null,
    anio_eleccion integer not null,
    pais varchar2(45) not null,
    region varchar2(45) not null,
    departamento varchar2(45) not  null,
    municipio  varchar2(45) not  null,
    partido  varchar2(45) not  null,
    nombre_partido varchar2(45) not null,
    sexo  varchar2(8) not null,
    raza varchar2(45) not null,
    analfabetos integer not null,
    alfabetos integer not null,
    sexo_2  varchar2(8) not null,
    raza_2 varchar2(45) not null,
    primaria INTEGER not null,
    nivel_medio integer not null,
    universitario integer not null
);
-- sqlldr CONTROL=carga.ctl
-- tengo que guardar mi archivo .csv a partir del de excel

select count(*) from temp ; 

drop table Conteo_Voto;
drop table Eleccion_Partido;
drop table Partido;
drop table Eleccion;
drop table Raza;
drop table Sexo;
drop table Municipio;
drop table Departamento;
drop table Region;
drop table Pais;

CREATE TABLE Pais(
    id INTEGER generated by DEFAULT on NULL as IDENTITY(start with 1 increment by 1),
    nombre varchar(45) not null,
    primary key(id)  
);
describe Pais;

CREATE TABLE Region(
    id INTEGER  generated by DEFAULT on NULL as IDENTITY(start with 1 increment by 1) PRIMARY KEY,
    nombre varchar(45) not null,
    Pais_id int not null,
    FOREIGN key (Pais_id) references Pais(id)
); 
describe Region;

CREATE table Departamento(
    id INTEGER  generated by DEFAULT on NULL as IDENTITY(start with 1 increment by 1) PRIMARY KEY,
    nombre varchar(45) not null,
    Region_id int not null,
    FOREIGN key (Region_id) references Region(id)
);
describe Departamento;
create table Municipio(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    nombre varchar(45) not null, 
    Departamento_id int not null,
    foreign key (Departamento_id) REFERENCES Departamento(id)
);
describe Municipio;

create table Sexo(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    sexo varchar(8) not null
);
describe Sexo;


create table Raza(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    raza varchar(45) not null
);
describe Raza;

create table Eleccion(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    nombre varchar(45) not Null,
    anio integer not null
);
describe Eleccion;

create table Partido(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    partido varchar(45) not Null,
    nombre varchar(45) not Null
);
describe Partido;

create table Eleccion_Partido(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
    Eleccion_id int not null,
    Partido_id int not null,
    foreign key (Eleccion_id) references Eleccion(id),
    foreign key (Partido_id) references Partido(id)
);
describe Eleccion_Partido;

create table  Conteo_Voto(
    id integer Generated by DEFAULT on null as identity(start with 1 increment by 1) primary key,
     alfabetos int not null ,
     analfabetos int not null ,
     primaria int not null ,
     nivel_medio int not null ,
     universitarios int not null ,
     Sexo_id int not null ,
     Municipio_id int not null , 
     Raza_id int not null ,
     Eleccion_Partido_id int not null ,
     FOREIGN key (Raza_id) references Raza(id),
     FOREIGN key (Sexo_id) references Sexo(id),
     FOREIGN key (Municipio_id) References Municipio(id),
     foreign key (Eleccion_Partido_id) references Eleccion_Partido(id)
);

describe Conteo_Voto;

commit; 

