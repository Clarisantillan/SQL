-- creo la base de datos --
create database if not exists youtube;

-- aclaro que usare esta base de datos --
use youtube;

-- primera vista a la db --
SELECT 
   *
FROM
    statistics;

-- guardo el procedimiento --

DELIMITER //
create procedure limp()
BEGIN
   select * from statistics;
END //
DELIMITER ;

CALL limp();-- llamo al prodecimiento

SELECT 
    Title, COUNT(*) AS cantidad_duplicados
FROM
    statistics
GROUP BY Title
HAVING COUNT(*) > 1;

--  obtengo el total de duplicados con una subquery --
SELECT 
    COUNT(*) AS total_duplicados
FROM
    (SELECT 
        Title, COUNT(*) AS cantidad_duplicados
    FROM
        statistics
    GROUP BY Title
    HAVING COUNT(*) > 1) AS subquery;

-- tratamiento a los duplicados --
rename table statistics to duplicados;

-- tabla temporal --
create temporary table temp_limpieza as
select distinct * from duplicados;

-- comparo la cantidad --
SELECT COUNT(*) AS original FROM duplicados;
SELECT COUNT(*) AS original FROM temp_limpieza;

-- guardo los datos de mi tabla temporal en una permanente --
CREATE TABLE statistics AS SELECT * FROM
    temp_limpieza;
call limp();

drop table duplicados;

-- desactivo modo seguro --
set sql_safe_updates =0;

-- reviso los tipos de datos --
describe statistics;

select Youtuber from statistics
where length(Youtuber) - length(trim(Youtuber)) > 0;

-- error de tipeo o codificacion --
SELECT * FROM statistics
 WHERE Youtuber LIKE '%½%';
 
 -- modifico los errorer --
UPDATE statistics
SET Youtuber = REPLACE(Youtuber, '½', ' '),
    Title = REPLACE(Title, '½', ' ')
WHERE (Youtuber LIKE '%½%'or Title LIKE '%½%');

UPDATE statistics
SET Youtuber = REPLACE(Youtuber, 'ï¿', ' '),
    Title = REPLACE(Title, 'ï¿', ' ')
WHERE (Youtuber LIKE '%ï¿%'or Title LIKE '%ï¿%');

UPDATE statistics
SET Youtuber = REPLACE(Youtuber, 'ýý', ' '),
    Title = REPLACE(Title, 'ýý', ' ')
WHERE (Youtuber LIKE '%ýý %'or Title LIKE '%ýý%');

UPDATE  statistics
SET Youtuber= REPLACE(REPLACE(REPLACE(REPLACE( Youtuber, 'ý', ''), '/', ''), ']', ''), 'ï', '')
WHERE Youtuber LIKE '%ý%' OR Youtuber LIKE '%/%' OR Youtuber LIKE '%]%' OR Youtuber LIKE '%ï%';

UPDATE  statistics
SET Title= REPLACE(REPLACE(REPLACE(REPLACE( Title, 'ý', ''), '/', ''), ']', ''), 'ï', '')
WHERE Title LIKE '%ý%' OR Title LIKE '%/%' OR Title LIKE '%]%' OR Title LIKE '%ï%';

-- tratamiento a celdas con espacios --
update statistics 
set Title = trim(Title)
where length(Title) -length(trim(Title)) > 0;

update statistics 
set Youtuber = trim(Youtuber)
where length(Youtuber) -length(trim(Youtuber)) > 0;


-- busco 2 o mas espacios consecutivos en una cadena --
select Title from statistics 
where Title regexp '\\s[2,]';

call limp();

alter table statistics modify column subscribers int;

-- concateno la fecha (se encuentra separada)

SELECT
    STR_TO_DATE(CONCAT(created_year, '-', 
        CASE 
            WHEN created_month = 'Jan' THEN '01'
            WHEN created_month = 'Feb' THEN '02'
            WHEN created_month = 'Mar' THEN '03'
            WHEN created_month = 'Apr' THEN '04'
            WHEN created_month= 'May' THEN '05'
            WHEN created_month = 'Jun' THEN '06'
            WHEN created_month = 'Jul' THEN '07'
            WHEN created_month = 'Aug' THEN '08'
            WHEN created_month = 'Sep' THEN '09'
            WHEN created_month= 'Oct' THEN '10'
            WHEN created_month = 'Nov' THEN '11'
            WHEN created_month = 'Dec' THEN '12'
        END, '-', created_date), '%Y-%m-%d') AS date_created
FROM statistics;

-- Añado una nueva columna de fecha
ALTER TABLE statistics
ADD COLUMN date_created DATE;

-- Modifico agregando los registros
UPDATE statistics
SET date_created =  STR_TO_DATE(CONCAT(created_year, '-', 
        CASE 
            WHEN created_month = 'Jan' THEN '01'
            WHEN created_month = 'Feb' THEN '02'
            WHEN created_month = 'Mar' THEN '03'
            WHEN created_month = 'Apr' THEN '04'
            WHEN created_month= 'May' THEN '05'
            WHEN created_month = 'Jun' THEN '06'
            WHEN created_month = 'Jul' THEN '07'
            WHEN created_month = 'Aug' THEN '08'
            WHEN created_month = 'Sep' THEN '09'
            WHEN created_month= 'Oct' THEN '10'
            WHEN created_month = 'Nov' THEN '11'
            WHEN created_month = 'Dec' THEN '12'
        END, '-', created_date), '%Y-%m-%d');

-- Elimino las columnas de año, mes y dia
ALTER TABLE statistics
DROP COLUMN created_year,
DROP COLUMN created_month,
DROP COLUMN created_date;

ALTER TABLE statistics CHANGE `rank` `ranking` int;

ALTER TABLE statistics MODIFY COLUMN `video views` VARCHAR(255);
ALTER TABLE statistics CHANGE `video views` `video_views` VARCHAR(255);
-- Luego de realizar un analisis tomare las siguientes columnas para trabajar en visualizacion
select ranking, Youtuber, subscribers, category, channel_type, video_views, Title,Country, video_views_for_the_last_30_days,highest_yearly_earnings,lowest_yearly_earnings,subscribers_for_last_30_days,Population,Latitude,Longitude,date_created,Urban_population 
from statistics
order by ranking;

call limp();

select channel_type, count(*) as cantidad_canales from statistics
group by channel_type
order by cantidad_canales desc;





