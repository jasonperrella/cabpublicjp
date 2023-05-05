CREATE TABLE COUNTY (
Name VARCHAR(255) ,
Total_Miles_Traveled bigint,
Total_Vehicles INT,
EVs INT,
Total_Emissions bigint,
CONSTRAINT PK_NameMun PRIMARY KEY (Name)
);

CREATE TABLE TOWN_ENERGY (
Municipality VARCHAR(255) ,
Total_Electricity bigint,
Total_Natural_Gas bigint,
County_Name VARCHAR(255),
CONSTRAINT PK_Mname PRIMARY KEY (County_Name, Municipality),
CONSTRAINT FK_Cname FOREIGN KEY (County_Name) REFERENCES COUNTY (Name)
);

CREATE TABLE COUNTY_ZIPCODE (
CountyName VARCHAR(255),
Zip_Code text ,
CONSTRAINT PK_ZipName PRIMARY KEY (CountyName, Zip_Code),
CONSTRAINT FK_Cname FOREIGN KEY (CountyName) REFERENCES COUNTY(Name)
);


CREATE TABLE EV_CHARGER (
Address text ,
Zip_Code text ,
County_Name VARCHAR(255),
FOREIGN KEY (County_Name, Zip_Code) REFERENCES COUNTY_ZIPCODE(CountyName, Zip_Code),
CONSTRAINT PK_AddZip PRIMARY KEY (Address, Zip_Code) 
);



CREATE TABLE GAS_STATION (
Address VARCHAR(255) ,
Zip_Code text ,
County_Name VARCHAR(255),
FOREIGN KEY (County_Name, Zip_Code) REFERENCES COUNTY_ZIPCODE(CountyName, Zip_Code),
  PRIMARY KEY (Address, Zip_Code)
);
