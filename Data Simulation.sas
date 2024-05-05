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
 NOTE: We are printing 10 observations of simulated data. 
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
