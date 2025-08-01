-- EJERCICIOS
-- 1. Crea un evento que aumente la superficie de los países en 5% cada año.

drop event aumentarSuperficie;

delimiter $$
create event actualizarSuperficie
on schedule every 1 minute
starts current_timestamp
ends current_timestamp + interval 10 minute
do
begin
	update world.world_temp set SurfaceArea = SurfaceArea * power(1.05, 1/(365*24*60));
end $$
delimiter ;

show events;

select surfaceArea from world.country C;
select surfaceArea from world.world_temp CT;

-- 2. Crea un evento que registre en una tabla la cantidad de países por continente cada mes.

CREATE TABLE IF NOT EXISTS registroContinentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Continente VARCHAR(50),
    Cantidad_Paises INT,
    Fecha_Registro DATETIME
);

DELIMITER $$

create event registrarCantidadPaises
on schedule every 1 month
starts current_timestamp
ends current_timestamp + interval 10 minute
DO
BEGIN
    INSERT INTO world.registroContinentes (Continente, Cantidad_Paises, Fecha_Registro)
    SELECT Continent, COUNT(*), NOW()
    FROM world.world_temp
    GROUP BY continent;
END$$
DELIMITER ;

show events;
drop table registroContinentes;
SELECT * FROM world.registroContinentes;

-- 3. Programa un evento que guarde un registro de cambios de población cada semana.
CREATE TABLE IF NOT EXISTS registroPoblacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CodigoPais CHAR(3),
    NombrePais VARCHAR(100),
    Poblacion INT,
    Fecha_Registro DATETIME
);

DELIMITER $$

create event cambiosPoblacion
on schedule every 1 week
starts current_timestamp
ends current_timestamp + interval 10 minute
do
begin
	insert into world.registroPoblacion(CodigoPais, NombrePais, Poblacion, Fecha_Registro)
	select Code, Name, Population, NOW()
	FROM world.world_temp;
end$$
delimiter ;

drop event cambiosPoblacion;
drop table registroPoblacion;
select * from world.registroPoblacion;

-- 4. Crea un evento que elimine países sin ciudades registradas cada 3 meses. 
-- Este evento debe dejar una traza de cuáles fueron los países eliminados en otra tabla.
CREATE TABLE IF NOT EXISTS registroEliminados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    CodigoPais CHAR(3),
    NombrePais VARCHAR(100),
    Fecha_Eliminacion DATETIME
);

DELIMITER $$
create event eliminarPaisesSinCiudad
on schedule every 1 minute
starts current_timestamp
ends current_timestamp + interval 10 minute
do 
begin
	insert into world.registroEliminados (CodigoPais, NombrePais, Fecha_Eliminacion)
    select c.Code, c.Name, NOW()
    from world.world_temp c
    left join world.city ci ON c.Code = ci.CountryCode
    where ci.ID is null;
   
   	DELETE c
    FROM world.world_temp c
    LEFT JOIN world.city ci ON c.Code = ci.CountryCode
    WHERE ci.ID IS NULL;
end $$
delimiter ;

drop event eliminarPaisesSinCiudad;
drop table registroEliminados;
select * from registroEliminados;

-- 5. Crear un evento que elimine y mueva a otra tabla todos los datos de los  países que se independizaron hace más de 500 años.
-- Este evento ocurre cada viernes.
create table country_temp as 
select *
from world.country;

delimiter $$
create event eliminar_paises_antiguos
on schedule at current_timestamp + interval 20 second
do
begin
	
	delete from world.country_temp where indepYear < year(CURRENT_DATE()) - 500;
	
end $$
delimiter ;