DATA  creditcard;
INFILE 'C:\Users\sbran\OneDrive\Desktop\PredictiveData\creditcard.csv' DLM =',' MISSOVER firstobs = 2;
INPUT MDR Acc Age Income Avgexp	Ownrent	Selfempl;
RUN;

PROC print DATA = creditcard (obs=100);
RUN;
/* Q1 */
PROC FREQ DATA=creditcard;
TABLE MDR Acc Ownrent Selfempl;
RUN;

PROC MEANS DATA=creditcard;
VAR MDR Acc Age Income Ownrent Selfempl Avgexp;
RUN;

/* Q2 */
PROC CORR DATA = creditcard;
VAR MDR Acc Age Income Ownrent Selfempl;
RUN;

/* Q3 */

PROC REG DATA = creditcard;
MODEL Avgexp = MDR Acc Age Income Ownrent Selfempl /INFLUENCE;
output out=checkoutlier dffits=dffit cookd=CooksD;
RUN;
PROC SORT data = checkoutlier;
BY descending CooksD;
RUN;
proc print  data = checkoutlier;
where CooksD > (4/100);
RUN;
/* remove the outliers */
data  creditcard;
set checkoutlier;
if dffit > 0.4898 THEN DELETE;
RUN;
/* finding best model using AIC */
PROC REG DATA = creditcard;
MODEL Avgexp = MDR Acc Age Income Ownrent Selfempl/ selection=adjrsq sse aic;
RUN;
PROC REG DATA = creditcard;
MODEL Avgexp = Acc Income Ownrent;
RUN;
/* Q4 */
PROC REG DATA = creditcard;
Orig: MODEL Avgexp = MDR Acc Age Income Ownrent Selfempl /stb;
 ods select ParameterEstimates;
RUN;

/* Q5 */
DATA  creditcardnew;
set creditcard;
Income2 = Income * Income;
RUN;
PROC REG DATA = creditcardnew;
MODEL Avgexp = Income Income2;
RUN;
/*Q6 */
DATA  creditcardnew;
set creditcard;
AgeIncome = Income * Age;
RUN;
PROC REG DATA = creditcardnew;
MODEL Avgexp = Age Income AgeIncome;
RUN;
/* Q7 */
PROC REG DATA = creditcard;
MODEL Avgexp = MDR Acc Age Income Ownrent Selfempl /VIF COLLIN;
RUN;
/* Q8 */
PROC model data=creditcard;
parms b0 b1 b2 b3 b4 b5 b6;
Avgexp = b0 + b1*Acc + b23*age + b4*Income + b5*Ownrent + b6*Selfempl;
fit Avgexp/white;
run;



/*trial */
PROC REG DATA = creditcard;
MODEL Avgexp = MDR Acc Age Income Ownrent/white;
RUN;
PROC model data=creditcard;
parms b0 b1 b2 b3 b4 b5;
income2 = 1/income;
Avgexp = b0 + b1*MDR + b2*Acc + b3*age + b4*Income + b5*Ownrent;
fit Avgexp/white pagan=(1 MDR ACC AGE Income Ownrent);
weight income2;

run;
