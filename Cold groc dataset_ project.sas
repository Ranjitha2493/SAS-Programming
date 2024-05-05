/* import cereal data set*/
data  cereal;
infile 'C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS\Project dataset\coldcer_groc_1114_1165.txt' missover firstobs =2;
input IRI_KEY WEEK SY $ GE $ VEND $ ITEM $ UNITS DOLLARS F $ D PR;
IF LENGTH(SY) = 1 THEN SY= cats('0',SY) ;
IF LENGTH(GE) = 1 THEN GE= cats('0',GE) ;
IF LENGTH(VEND) = 4 THEN VEND= cats('0',VEND) ;
IF LENGTH(ITEM) = 1 THEN ITEM= cats('0000',ITEM) ;
IF LENGTH(ITEM) = 2 THEN ITEM= cats('000',ITEM) ;
IF LENGTH(ITEM) = 3 THEN ITEM= cats('00',ITEM) ;
IF LENGTH(ITEM) = 4 THEN ITEM= cats('0',ITEM) ;
UPC = CATS(SY,'-',GE,'-',VEND,'-',ITEM);
if F ='NONE' then  Feature = 0;
ELSE Feature = 1;
IF  D = 1 or D = 2 then Display = 1;
ELSE Display = 0;
run;

proc print data = cereal (obs = 10);
run;


/* import calendar */

PROC IMPORT OUT=iriweek
		DATAFILE="C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS\Project dataset\IRI week translation.xls"
		DBMS=EXCEL REPLACE;
	RANGE="Sheet1$";
	GETNAMES=YES;
	MIXED=YES;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
run;

proc print data = iriweek (obs = 10);
run;

/*import store*/

data  store;
infile 'C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS\Project dataset\Delivery_Stores' missover firstobs =2;
input IRI_KEY OU $ EST_ACV Market_Name $ 20-36 open clsd MskdName $ ;
run;


proc print data = prodcereal (obs = 10);
run;

/* import ceral information*/
PROC IMPORT OUT=prodcereal
		DATAFILE="C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS\Project dataset\prod_cereal.xls"
		DBMS=EXCEL REPLACE;
	RANGE="Sheet1$";
	GETNAMES=YES;
	MIXED=YES;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
run;

data prodcereall;
set prodcereal;
ounce = VOL_EQ * 16 ;
if find(L5,'KELLOGG') then L5='KELLOGGS';
else if find(L5,'GENERAL MILLS') then L5 ='GENERAL MILLS';
else if find(L5,'GENERAL MLL') then L5 ='GENERAL MILLS';
else if find(L5,'HEALTH VALLEY') then L5 ='HEALTH VALLEY';
else if find(L5,'KASHI')then L5 ='KASHI';
else if find(L5,'NATURES P')then L5 ='NATURES PATH';
else if find(L5,'POST') then L5 ='POST';
else if find(L5,'QUAKER') then L5 ='QUAKER';
else if find(L5,'MALT') then L5 ='MALT O MEAL';
else if find(FLAVOR_SCENT,'APPLE') then FLAVOR_SCENT='Fruit';
else if find(FLAVOR_SCENT,'BANANA') then FLAVOR_SCENT ='Fruit';
else if find(FLAVOR_SCENT,'BERRY') then FLAVOR_SCENT ='BERRY';
else if find(FLAVOR_SCENT,'BLUEBERRY') then FLAVOR_SCENT ='BERRY';
else if find(FLAVOR_SCENT,'CINNAMON ')then FLAVOR_SCENT ='CINNAMON ';
else if find(FLAVOR_SCENT,'CRANBERRY')then FLAVOR_SCENT ='BERRY';
else if find(FLAVOR_SCENT,'HONEY') then FLAVOR_SCENT ='HONEY';
else if find(FLAVOR_SCENT,'ORANGE') then FLAVOR_SCENT ='ORANGE';
else if find(FLAVOR_SCENT,'STRAWBERRY') then FLAVOR_SCENT ='STRAWBERRY';
else if find(FLAVOR_SCENT,'CHOCOLATE') then FLAVOR_SCENT ='CHOCOLATE';
else if find(FLAVOR_SCENT,'COCOA') then FLAVOR_SCENT ='COCOA';
else if find(FLAVOR_SCENT,'FRUIT') then FLAVOR_SCENT ='FRUIT';
else if find(FLAVOR_SCENT,'PECAN') then FLAVOR_SCENT ='NUTS';
else if find(FLAVOR_SCENT,'RAISIN') then FLAVOR_SCENT ='NUTS';
else if find(FLAVOR_SCENT,'ALMOND') then FLAVOR_SCENT ='NUTS';
else if find(FLAVOR_SCENT,'CASHEW') then FLAVOR_SCENT ='NUTS';

RUN;

proc print data = prodcereall (obs=10);
run;


/*create dataset for analysis*/
	
	PROC SQL;
CREATE TABLE brand AS
SELECT c.week,c.IRI_KEY,c.units,c.dollars,c.f,c.d,p.L5,p.ounce,Dollars/(units*ounce) as priceperoz,s.market_name,s.mskdname,p.package,p.flavor_scent, c.feature, c.display
, p.vol_eq
from 
	cereal as c 
    inner join prodcereall p on c.upc = p.upc
	inner join store s on s.IRI_KEY = c.IRI_KEY;
QUIT;

/*get top brands based on sales*/
PROC SQL;
create table totsale as
SELECT L5, sum(priceperoz)AS totsales
from brand
group by L5;
QUIT;
RUN;


proc sort data = totsale;
by descending totsales ;
run;
/* top 5 brands on sales*/
proc sql;
create table brandgraph as
select * 
from totsale (obs = 5);
QUIT;
RUN;
/*Market Share for these 5 brands and location*/
PROC SQL;
Select b.l5,sum(totsales)/(select sum (totsales) from brandgraph)*100 as MS, bd.market_name
from brandgraph as b
inner join brand as bd on bd.l5 = b.l5
group by b.l5,bd.market_name;
QUIT;
RUN;

PROC SQL ;
CREATE TABLE  package  as 
SELECT sum(priceperoz) as totsales,package, flavor_scent,b.l5
from brand b
inner join brandgraph bd on bd.L5 = b.L5
group by b.L5,package,flavor_scent;
QUIT;
RUN;

proc sort data = package;
by descending totsales ;
run;
/*selecting only stores location where total sales is more than $10000*/
proc print data = package;
WHERE totsales>10000;
run;
/*calcualte weekly sales for the top selling brand General Mills*/

proc sql;
create table data as
select IRI_KEY,avg(dollars) as WeeklySales, avg(dollars/units*Vol_eq) as priceperunit,priceperoz, 
sum(units*Display)/sum(units) as ADisplay,sum(units*feature)/sum(units) as AFeature 
from brand
where L5='GENERAL MILLS'
group by IRI_KEY;
quit;


/*creating interaction term */

data cerreal;
set data;
priceperdisplay = priceperunit *ADisplay;
priceperfeature = priceperunit * AFeature;
fd = ADisplay * AFeature;
RUN;

proc print data = cerreal (obs=100);
run;
proc means data = cerreal;
var WeeklySales priceperunit;
run;

/*price elasticity*/
proc reg data = cerreal;
model WeeklySales = priceperunit Adisplay AFeature;
run;

proc reg data = cerreal;
model weeklysales = Adisplay AFeature fd;
run;
/* Poission regression count model*/
data countmodel;
set brand;
if market_name = 'LOS ANGELES' or market_name = 'NEW YORK' or market_name = 'DALLAS, TX' or market_name ='CHICAGO' or market_name = 'HOUSTON';
RUN;
proc sort data = countmodel;
by market_name;
RUN;
proc countreg data=countmodel;
class market_name / param = GLM;
   model  units = priceperoz market_name display /	dist=poisson ;
  output out = poisson pred = predicted;
 run;


proc corr data = poisson;
var units predicted; run;
