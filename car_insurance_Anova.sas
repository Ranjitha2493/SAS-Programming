DATA a1;
INFILE "C:\Users\sbran\OneDrive\Desktop\PredictiveData\car_insurance_19.csv" DLM = ',' MISSOVER FIRSTOBS = 2;
Length State $ 10 EffectiveToDate $ 11;
INPUT Customer $ State $ CustomerLifetimeValue Response $ Coverage $ Education $ EffectiveToDate $	EmploymentStatus $	Gender $ Income	LocationCode $	MaritalStatus $	MonthlyPremiumAuto	MonthsSinceLastClaim MonthsSincePolicyInception	NumberofOpenComplaints	NumberofPolicies	PolicyType $ Policy $ RenewOfferType $ SalesChannel $ TotalClaimAmount	VehicleClass $ VehicleSize $;
RUN;

PROC PRINT DATA = a1 (obs=10); RUN;
PROC MEANS; VAR CustomerLifetimeValue; CLASS RenewOfferType state; RUN;

proc glm data=a1;
   class Education MaritalStatus;
   model CustomerLifetimeValue=Education MaritalStatus income ;
run;

PROC FREQ data=a1;
    TABLE RenewOfferType*Response / CHISQ;
RUN;

data a11; set a1; if Coverage = 'Premium' then DELETE; run;
Proc ttest data=a11 sides = L;var Income;
class Coverage;
run;

PROC means data = a1; VAR TotalClaimAmount; CLASS MaritalStatus;
proc anova data = a1;
class MaritalStatus;
model TotalClaimAmount = MaritalStatus;
run;
PROC means data = a1; VAR TotalClaimAmount; CLASS MaritalStatus; 
data a11; set a1; if MaritalStatus = 'Divorced' then DELETE; run;
PROC ttest data = a11 ; var TotalClaimAmount; class MaritalStatus; run;

proc glm data=a1;
   class MaritalStatus Gender;
   model TotalClaimAmount=MaritalStatus Gender / solution;
run;
