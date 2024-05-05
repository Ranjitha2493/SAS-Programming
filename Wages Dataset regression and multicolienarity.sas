DATA wagedata;
INFILE "C:\Users\sbran\OneDrive\Desktop\PredictiveData\wages.csv" DLM = ',' missover firstobs = 2;
INPUT wageid year edu hr wage famearn selfempl salaried married numkid age locunemp;
logwage = log(wage);
RUN;

PROC PRINT data = wagedata (obs = 10);
run;
/*to find best model using aic */
proc reg data = wagedata;
model logwage = edu hr famearn selfempl salaried married numkid age locunemp /  selection=adjrsq sse aic;
RUN;
/*Q1 */
proc reg data = wagedata;
model logwage = edu hr famearn selfempl salaried married numkid age locunemp/VIF COLLIN;
RUN;
/*Q2 */
/* create age, hr and numkid squared variable */
data wagenonlinear;
set wagedata;
age2 = age * age;
hr2 = hr * hr;
numkid2 = numkid * numkid;
famearn2 = famearn * famearn;
RUN;
/* reg with age2 term */
proc reg data = wageagenonlinear;
model logwage = age age2/VIF COLLIN ;
RUN;
/* reg with hr2 term */
proc reg data = wagenonlinear;
model logwage = hr hr2/VIF COLLIN ;
RUN;
/* reg with numkid2 term */
proc reg data = wagenonlinear;
model logwage = numkid numkid2/VIF COLLIN ;
RUN;

/* reg with famearning term */
proc reg data = wagenonlinear;
model logwage = famearn famearn2 /VIF COLLIN ;
RUN;

/* Q3 */
/* Finding the best model*/
proc reg data = wagenonlinear;
model logwage = edu hr famearn selfempl salaried married numkid age locunemp age2 hr2 numkid2 famearn2 / selection=adjrsq sse aic ;
RUN;
/* finding correlation between the independent variable */
proc corr data = wagenonlinear;
var edu hr famearn selfempl salaried married numkid age locunemp age2 famearn2;
RUN;

proc reg data = wagenonlinear;
model logwage = edu hr famearn selfempl salaried married numkid age locunemp age2 famearn2 /VIF COLLIN;
RUN;

/*correcting multicolinearity */
proc reg data = wagenonlinear;
model logwage = edu hr famearn selfempl salaried married numkid age locunemp /VIF COLLIN;
RUN;
/* Q5 */
proc panel data = wagenonlinear;       
id wageid year;       
model logwage = edu hr famearn selfempl salaried married numkid age locunemp / FIXONE FIXTWO RANONE RANTWO;    
run;
