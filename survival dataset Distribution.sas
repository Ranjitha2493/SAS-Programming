/* Question 01 */
/* Part 01 */
/* Creating macro for the rand function */
%MACRO Distribution(dist= ,formula=, label=);
DATA &dist;
%DO i=1 %to 1000;
values=RAND&formula;
OUTPUT;
%END;
RUN;
/*Generating Histograms*/
PROC SGPLOT DATA=&dist;
TITLE"PLOT of &dist distribution";
HISTOGRAM values/ TRANSPARENCY=0.75 FILLATTRS=(COLOR=RED);
DENSITY values/ TYPE=NORMAL LINEATTRS=(COLOR=BLUE) LEGENDLABEL=&label;
RUN;

%MEND Distribution;
/*Invoking the Macros*/
%Distribution (dist=normal,formula=('NORMAL',90,8),label="normal")
%Distribution (dist=exponential,formula=('exponential')/8,label='exponential')
%Distribution (dist=binomial,formula=('binomial',.2,200),label='binomial')
%Distribution (dist=poisson,formula=('poisson',8),label='poisson')
%Distribution (dist=gamma,formula=('gamma',3,8),label='gamma')
RUN;

/* Q2 */
/* Gamma Distribution */
DATA gammadata;
call streaminit(123);
do i=1 to 1000;
values=rand('GAMMA', 1,5);
output;
end;
RUN;
/* Histogram for Gamma Distribution */
proc sgplot data=gammadata ;
TITLE "PLOT of Gamma Distribution";
HISTOGRAM values / transparency=0.75 fillattrs=(color=blue);
density values / type=normal lineattrs=(color=red) legendlabel='Gamma';
RUN ;
/* Exponential Distribution  */
DATA expdata;
call streaminit(123);
do i=1 to 1000;
values=rand('EXPONENTIAL')/5;
output;
end;
RUN;
/* Histogram for Exponential Distribution */
proc sgplot data=expdata;
TITLE "PLOT of Exponential Distribution";
HISTOGRAM values / transparency=0.75 fillattrs=(color=red);
density values / type=normal lineattrs=(color=blue) legendlabel='Exp';
RUN ;

/* part 2 */
/*	 Q1 */

DATA survival;
SET 'C:\Ranjitha\Education\Spring 2022\Advance BA with SAS\Part 2\survival.sas7bdat';
RUN;
/* View 10 observations in dataset */
PROC PRINT data = survival (obs = 10);
TITLE "Original Dataset";
RUN;
/* calculating customer loss for each year*/
DATA survived_losscust;
set survival;
Lost = -1*dif(Customers);
RUN;
/* remove year 0 and create servived dataset*/
data survived;
set survived_losscust;
if year<>0;
run;
PROC PRINT data = survived;
TITLE "Data set after Transformation";
RUN;

/*Q2*/
data survival;
SET 'C:\Ranjitha\Education\Spring 2022\Advance BA with SAS\Part 2\survival.sas7bdat';
run;

/* Calculating the lost customers*/ 
data s1 (drop = last);
set survival;
retain last;
if year > 0 then Lost = last - customers;
last = customers;
if year > 0;
output;
run;

data s2;
set s1 end = last_record;
if last_record;
year = year + 1;
Lost = customers;
customers = 0;
run;

data s4;
set s1 s2;
run;

PROC PRINT data = s4;
RUN;

proc nlmixed data = s4;
parms a = 1 b = 1;
if customers > 0 then ll = lost * log(BETA(a + 1, b + Year - 1)/BETA(a, b));
else ll =lost * log(BETA(a, b + (Year - 1))/BETA(a, b));
model lost ~ general(ll);
run;

/*Q3*/
DATA simulated (DROP = X) ;
CALL streaminit(123);
DO i=1 to 1000; /* simulate 1000 customers */
DO t=1 to 12; /* t represent period */
theta = rand('beta',0.668,3.806);
x=rand('BERNOULLI',theta); /* use the theta we got */
IF x=1 THEN leave;
END;
OUTPUT;
END;
RUN;

PROC PRINT DATA = simulated (obs = 10);
TITLE "Simulated data";
RUN;

/* Aggregate Simulated Data */
PROC sql;  /* count how many customers leave in each period */
create table sumtable as
  select t as period, count(i) as lost from simulated
    group by t;
QUIT;
 
DATA sumtable2;
  set sumtable;
  retain remain 1000;
  remain = remain - lost;
RUN;


proc print data = sumtable2 ;
TITLE "Aggregate Simulated Data ";
RUN;


/* Graph Population-level Survival */

PROC sgplot data=sumtable2;
  scatter x = period y = remain;
RUN;
