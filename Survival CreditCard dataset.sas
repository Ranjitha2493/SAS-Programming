data creditcard;
set 'C:\Users\sbran\OneDrive\Desktop\PredictiveData\CC_data_22.sas7bdat';
if tottrans = 0 then active = 0;
else active = 1;
climit = limit/10000;
ttrans = tottrans/10000;
profit = totfc + (0.016 * tottrans);
if profit <0 then profit =0;
run;

proc print data = creditcard (obs = 100);
run;

/* Q1 */
PROC QLIM data = creditcard;
*class rewards;
Model profit = age ttrans rewards climit numcard ds ts net platinum standard quantum sectorC sectorB sectorD sectorE sectorF;
endogenous profit ~ censored(lb=0);
Run;

PROC MEANS data = creditcard;
run;



/* Q2 */
proc qlim data=creditcard; 
Model active = age rewards climit numcard ds ts net platinum standard quantum sectorB sectorC sectorD sectorE sectorF /discrete;
Model totfc = age ttrans rewards climit numcard ds ts net platinum standard quantum sectorB sectorC sectorD sectorE sectorF / select (active = 1) ;
run;


/* Q3 */
DATA survivalcredit;
SET creditcard;
IF dur = 37 THEN censor = 1;
ELSE censor = 0;
RUN;

proc phreg data=survivalcredit;
model dur *censor(1)= age ttrans rewards climit numcard ds ts net platinum standard quantum sectorB sectorC sectorD sectorE sectorF;
run;

/* Q4 */

PROC LIFEREG data =survivalcredit outest=liferegdata;
model dur *censor(1)= age ttrans rewards climit numcard ds ts net platinum standard quantum sectorB sectorC sectorD sectorE sectorF/ dist=WeiBull;
output out=b xbeta=lp;
run;

/* Q5 */
proc lifetest data=survivalcredit plots=(s) graphics outsurv=a method=KM;
time dur*censor(1);
strata sectorA;
run;


