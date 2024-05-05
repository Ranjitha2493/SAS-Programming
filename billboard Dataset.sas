/*import billboard dataset */

DATA billboard;
SET 'C:\Ranjitha\Education\Spring 2022\Advance BA with SAS\billboard.sas7bdat';
RUN;

PROC PRINT DATA = billboard;
RUN;

/* The NBD Model*/

PROC NLMixed DATA=Billboard;
/*assigning random value for alpha and r*/
PARMS alpha = 1 r = 0.5;
/*lambda from Gamma distribution with parameters r and alpha*/
ll=peoplecount*log((GAMMA(r+exposures))/(GAMMA(r)*fact(exposures))*((alpha/(alpha+1))**r)*((1/(alpha+1))**exposures));
MODEL peoplecount ~ GENERAL(ll);
RUN;

/*import kc dataset */
DATA kc;
SET 'C:\Ranjitha\Education\Spring 2022\Advance BA with SAS\kc.sas7bdat';
RUN;


/* The Poisson Regression Model*/
proc nlmixed data=kc;
  /* m stands for lambda */
  parms m0=1 b1=0 b2=0 b3=0 b4=0;
  m=m0*exp(b1*income+b2*sex+b3*age+b4*HHSize);
  ll = total*log(m)-m-log(fact(total));
  model total ~ general(ll);
run;

/* The NBD Regression Model*/

proc nlmixed data=kc;
  parms r=1 a=1 b1=0 b2=0 b3=0 b4=0;
  expBX=exp(b1*income+b2*sex+b3*age+b4*HHSize);
  ll = log(gamma(r+total))-log(gamma(r))-log(fact(total))+r*log(a/(a+expBX))+total*log(expBX/(a+expBX));
  model total ~ general(ll);
run;


/*part 2 */

/* Load dataset books to SAS */
PROC IMPORT OUT=books
		DATAFILE="C:\Ranjitha\Education\Spring 2022\Advance BA with SAS\books.xlsx"
		DBMS=EXCEL REPLACE;
	RANGE="Sheet1$";
	GETNAMES=YES;
	MIXED=YES;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
run;
proc print data = books (obs = 10);
run;

/*Q1*/
/*creating the count dataset to get the count if cutomers have purchased only from barnesandn*/
data  countdata;
set books;
if domain = "barnesandnoble.com" then bncount = qty;
ELSE bncount = 0;
RUN;

PROC SQL;
CREATE TABLE bncount AS
SELECT  userid, education, region, hhsz, age, income, child, race, country, sum(bncount)AS BNPurchase
from countdata
group by  userid, education, region, hhsz, age, income, child, race, country;
QUIT;

/*Printing the first 10 observations */
PROC PRINT data = bncount (obs = 10);
RUN;



/*Q2*/

PROC SQL;
CREATE TABLE nbddata AS
select BNPurchase , count (userid) as countuser
from bncount
group by BNPurchase;
QUIT;

PROC PRINT data = nbddata (obs= 10);
run;

PROC NLMixed DATA=nbddata;
/*assigning random value for alpha and r*/
PARMS alpha = 1 r = 1;
/*lambda from Gamma distribution with parameters r and alpha*/
ll=countuser*log((GAMMA(r+BNPurchase))/(GAMMA(r)*fact(BNPurchase))*((alpha/(alpha+1))**r)*((1/(alpha+1))**BNPurchase));
MODEL countuser ~ GENERAL(ll);
RUN;

/*Q3 */
/*
p(x(t) = 0.810325
e(x(t) = 0.7485

reach = 100* 1-0.810325 = 18.9675
avg frequency = 0.7485/(1-0.810325) = 3.9462

GRPs: 100*E(x(1)) = 100*0.7485 = 74.85
*/


data  sbncount;
set bncount;
if region = 1 then region1 = 1; else region1 = 0;
if region = 2 then region2 = 1; else region2 = 0;
if region = 3 then region3 = 1;else region3 = 0;
if region = 4 then region4 = 1;else region4 = 0;
if race = 1 then race1 = 1 ;else race1 =0;
if race = 2 then race2 = 1 ;else race2 =0;
if race = 3 then race3 = 1 ;else race3 =0;
if race = 5 then race5 = 1 ;else race5 =0;
run;
proc print data = sbncount (obs=10);
run;
/*Q4*/
/* The Poisson Regression Model*/
proc nlmixed data=sbncount;
  /* m stands for lambda */
/* as for categorical variables race */
  parms m0=1 b1=0 b3=0 b4=0 b5=0 b6=0 b8=0 b9=0 b10=0 b11=0 b12=0 b13=0 b14=0;
  m=m0*exp(b1*education + b3*hhsz+ b4*age + b5*income + b6*child + b8*country + b9*region2 + b10*region3+ b11*region4 + b12*race2 +b13*race3 + b14*race5);  
  ll = BNPurchase*log(m)-m-log(fact(BNPurchase));
  model BNPurchase ~ general(ll);
run;

/*Q5*/

  expBX=exp(b1*education +  b4*age + b5*income + b6*child + b7* race+ b8*country);
  ll = log(gamma(r+BNPurchase))-log(gamma(r))-log(fact(BNPurchase))+r*log(alpha/(alpha+expBX))+BNPurchase*log(expBX/(alpha+expBX));

  /*Q6*/

/* The NBD Regression Model*/
  proc nlmixed data=sbncount;
  parms r=1 a=1 b1=0 b3=0 b4=0 b5=0 b6=0 b8=0 b9=0 b10=0 b11=0 b12=0 b13=0 b14=0;
  expBX=exp(b1*education + b3*hhsz+ b4*age + b5*income + b6*child + b8*country + b9*region2 + b10*region3+ b11*region4 + b12*race2 +b13*race3 + b14*race5);
  ll = log(gamma(r+BNPurchase))-log(gamma(r))-log(fact(BNPurchase))+r*log(a/(a+expBX))+BNPurchase*log(expBX/(a+expBX));
  model BNPurchase ~ general(ll);
run;

/*Q7 */
 /* variables significant in possion regression but not in NBD regression*/
