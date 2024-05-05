proc import out=tele datafile="C:\Ranjitha\Education\Spring 2022\Predictive Analytics using SAS\Churn_telecom.csv" dbms=csv replace;
getnames=yes;run;
data a1;
set tele;
if churn=0;run;
data a2;
set tele;
if churn=1;run;
proc means data=a1 mean;output out=b1(drop=type freq)mean=;run;
proc transpose data=b1 out=out1;
run;
data out1; 
set out1; 
rename NAME = name 
COL1=nonchurn_mean;  
RUN;
proc print data=out1;run;
 
proc means data=a2 mean;output out=b2(drop=type freq)mean=;run;
proc transpose data=b2 out=out2;
run;
data out2; 
set out2; 
rename NAME = name 
       COL1=churn_mean;  
RUN;
proc print data=out2;run;
proc sort data=out1;by name;run;
proc sort data=out2;by name;run;
data new;
merge out1 out2;by name;run;
data new1;
set new;
percentdiff = ((churn_mean - nonchurn_mean)/churn_mean)*100;
keep name churn_mean nonchurn_mean percentdiff ;run;
 
data new1;
set new1;
abspercentdiff = abs(percentdiff);run;
 
proc sort data=new1; by descending abspercentdiff;run;
proc print data=new1 ;run;
proc corr data=tele;
var change_rev change_mou blck_dat_Mean blck_dat_Range retdays drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean mou_cdat_Mean callfwdv_Mean ccrndmou_Mean cc_mou_Mean opk_dat_Mean plcd_dat_Mean callwait_Mean comp_dat_Mean roam_Mean;
run;
proc means data=tele nmiss;
var change_rev blck_dat_Mean retdays drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean callwait_Mean roam_Mean;
run;
proc means data=tele nmiss max min range;
run;
proc surveyselect data=tele rat=0.7 
out= tele_select outall 
method=srs seed=39647; 
run;
data estimation test; 
set tele_select; 
if selected =1 then output estimation; 
else output test; 
run;
proc logistic data=estimation descending;
  model churn = change_rev change_mou blck_dat_Mean drop_dat_Mean mou_opkd_Mean threeway_Mean custcare_Mean callfwdv_Mean opk_dat_Mean callwait_Mean;
output out=esti1 predicted=pchurn;
score data=test out=tes;
run;

/* HIT Ratio on main sample*/
data pesti;set esti1;
pred_churn=0;
if pchurn >0.5 then pred_churn=1;run;
proc freq data=pesti;
tables churn*pred_churn/norow nocol nopercent;run;
/* Hit Ratio test dataset */
data ptest;set tes;
pred_churn=0;
if P_1>0.5 then pred_churn=1;run;
proc freq data=ptest;
tables churn*pred_churn/norow nocol nopercent;run;

