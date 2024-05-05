proc import datafile = 'C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS/Churn_telecom.csv'
 out = churndata
 dbms = CSV ;
run;

proc contents data = churndata;
run;

PROC MEANS data = churndata; 
class churn;
output out = meandata ; 
RUN;

PROC CONTENTS DATA= meandata; RUN;
/*Transposing the means data*/
DATA NM; SET meandata; RUN;
PROC TRANSPOSE DATA = NM; RUN;
PROC PRINT DATA = NM (OBS = 10);RUN;
/*Setting Transposed dataset to TNM*/
DATA TNM; SET WORK.DATA1; RUN;
PROC CONTENTS DATA = TNM; RUN;
/*Calculating percentage Means difference in the variables*/
DATA AOC; SET TNM;
avg = (COL1 + COL2)/2; RUN;
DATA PCT; SET AOC;
PCT = ABS(((COL1 - COL2)/avg)*100); RUN;
/*Sorting the percentage means difference in descending order*/
PROC SORT DATA = PCT; BY DESCENDING PCT; RUN;
PROC CONTENTS DATA = PCT; RUN;
PROC PRINT DATA = PCT (OBS = 10);RUN;


/*sampling 70000 records*/
proc surveyselect data=churndata method=srs n=70000
                  seed=39667 out=randomsample;
run;

PROC CONTENTS DATA = randomsample; RUN;
/*remaining 30000 records*/
Proc SQL;
  Create Table holdoutsample As
    Select t1.*
    From churndata t1
    Where t1.customer_id not in (select customer_id from randomsample);
quit;
PROC CONTENTS DATA = holdoutsample; RUN;


PROC LOGISTIC data=randomsample descending;
MODEL churn = change_rev blck_dat_Mean drop_dat_Mean roam_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean callwait_Mean eqpdays;
RUN;
