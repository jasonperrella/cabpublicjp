CREATE TEMPORARY TABLE t1 (municipality text, countyname text, x3 integer, total4 integer, evs5 integer, x6 text);

\copy t1 (municipality, countyname, x3, total4, evs5, x6) FROM '../doc/EVOwnershipData.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW temp AS SELECT countyname, SUM(total4) "totalcars" FROM t1 GROUP BY countyname;
CREATE VIEW temp2 AS SELECT countyname, SUM(evs5) "evs" FROM t1 GROUP BY countyname;
CREATE VIEW temp3 AS SELECT * FROM temp NATURAL JOIN temp2 ORDER BY countyname ASC;

CREATE TEMPORARY TABLE t2 (mun1 text, countyname text, mil3 bigint, yea4 text, x5 text, x6 text, x65 text, x7 text, x8 text, x9 text, x10 text, x11 text, x12 text, x13 text, mil5 text, x14 text, x16 text, x17 text);

\copy t2 (mun1, countyname, mil3, yea4, x5, x6, x65, x7, x8, x9, x10, x11, x12, x13, mil5, x14, x16, x17) FROM '../doc/VehicleMilesTraveled.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW temp4 AS SELECT countyname, SUM(mil3) "totalmiles" FROM t2 GROUP BY countyname ORDER BY countyname ASC;

CREATE TEMPORARY TABLE t3 (mun2 text, countyname text, mac text, yea4 integer, total integer);

\copy t3 FROM '../doc/CommunityScaleGHGEmissions.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW temp5 AS SELECT countyname, SUM(total)"totalemissions" FROM t3 GROUP BY countyname ORDER BY countyname ASC; 

INSERT INTO COUNTY (Name) SELECT (countyname) FROM temp3;
UPDATE COUNTY SET Total_Vehicles = t.totalcars, EVs = t.evs FROM temp3 t WHERE COUNTY.name = t.countyname;

UPDATE COUNTY SET Name = 'Atlantic' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1);
UPDATE COUNTY SET Name = 'Bergen' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 1);
UPDATE COUNTY SET Name = 'Burlington' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 2);
UPDATE COUNTY SET Name = 'Camden' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 3);
UPDATE COUNTY SET Name = 'Cape May' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 4);
UPDATE COUNTY SET Name = 'Cumberland' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 5);
UPDATE COUNTY SET Name = 'Essex' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 6);
UPDATE COUNTY SET Name = 'Gloucester' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 7);
UPDATE COUNTY SET Name = 'Hudson' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 8);
UPDATE COUNTY SET Name = 'Hunterdon' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 9);
UPDATE COUNTY SET Name = 'Mercer' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 10);
UPDATE COUNTY SET Name = 'Middlesex' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 11);
UPDATE COUNTY SET Name = 'Monmouth' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 12);
UPDATE COUNTY SET Name = 'Morris' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 13);
UPDATE COUNTY SET Name = 'Ocean' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 14);
UPDATE COUNTY SET Name = 'Passaic' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 15);
UPDATE COUNTY SET Name = 'Salem' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 16);
UPDATE COUNTY SET Name = 'Somerset' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 17);
UPDATE COUNTY SET Name = 'Sussex' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 18);
UPDATE COUNTY SET Name = 'Union' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 19);
UPDATE COUNTY SET Name = 'Warren' WHERE name = (SELECT name FROM county ORDER BY name LIMIT 1 OFFSET 20);

UPDATE COUNTY SET Total_Miles_Traveled = t4.totalmiles FROM temp4 t4 WHERE COUNTY.name = t4.countyname;
UPDATE COUNTY SET Total_Emissions = t5.totalemissions FROM temp5 t5 WHERE COUNTY.name = t5.countyname;
UPDATE COUNTY SET Name = UPPER(Name);


CREATE TABLE cz ( zipcode text, town text, x3 text, x4 text, county text);
\copy cz FROM '../doc/CountyZipcode.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW cz_county AS SELECT county, zipcode FROM cz;
INSERT INTO COUNTY_ZIPCODE SELECT * FROM cz_county;
CREATE VIEW zipcodetown AS SELECT zipcode, town FROM cz;






CREATE TEMPORARY TABLE energy (mun2 text, countyname text, mpo3 text, yea4 integer, x5 text, x6 text, x7 text, x8 text, x9 text, totalelec bigint , x11 text, x12 text, x13 text, x14 text, x15 text, totalgas bigint);
\copy energy FROM '../doc/AggComData.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW en AS SELECT mun2, countyname, totalelec, totalgas FROM energy;
UPDATE en SET countyname = UPPER(countyname);
INSERT INTO TOWN_ENERGY (Municipality, County_Name, Total_Electricity , Total_Natural_Gas) SELECT * FROM en;

CREATE TEMPORARY TABLE charge (x1 text, x2 text, address text, x4 text, x5 text, zipcode text, x7 text, x8 text);
\copy charge FROM '../doc/EVChargeLocations.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW chargeloc AS SELECT DISTINCT address, zipcode FROM charge INNER JOIN county_zipcode ON zipcode = county_zipcode.zip_code;
create view tmp2 as select address, zipcode, countyname from chargeloc inner join county_zipcode on chargeloc.zipcode = county_zipcode.zip_code;
INSERT INTO EV_CHARGER(Address, Zip_Code, County_Name) SELECT * FROM tmp2;

CREATE  TABLE gas (address text, x2 text, x3 text, zipcode text, county text, x6 text);
\copy gas FROM '../doc/GasStations.csv' DELIMITER ',' CSV HEADER;
CREATE VIEW locs AS SELECT DISTINCT address, zipcode FROM gas INNER JOIN county_zipcode ON zipcode = county_zipcode.zip_code;
create view tmp as select address, zipcode, countyname from locs inner join county_zipcode on zipcode = county_zipcode.zip_code;
INSERT INTO GAS_STATION(Address, Zip_Code, County_Name) SELECT  * FROM tmp;

create view gascount as select county_name, count(*) gasstations from gas_station group by county_name;
create view chargecount as select county_name, count(*) evcount from ev_charger group by county_name;
create view ratio as select * from chargecount natural join gascount ;
create view r2 as select county_name, round(((evcount * 1.0 / gasstations * 1.0) * 100), 2) evgasratio  from ratio order by county_name;
select * from r2;