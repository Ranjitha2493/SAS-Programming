/* Q1 */
PROC IMPORT out = WORK.catalogtesting datafile = 'C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\catalog.xls' DBMS = EXCEL REPLACE;
SHEET = 'testing' ; GETNAMES=YES;
MIXED=NO;
RUN; 
PROC CONTENTS DATA = catalogtesting;
RUN;
PROC PRINT DATA = catalogtesting (obs=10);
RUN;
/* Q2 */
DATA catalogtestingnew;
SET catalogtesting;
if money > 20.0 then prospect = 1;
else prospect = 0;
RUN;
PROC PRINT data = catalogtestingnew (obs =10);
RUN;

/* Q3 */
Data catalogtestingmore;
set catalogtesting (where = (money >20.0));
prospect = 1;
RUN;
Data catalogtestingless;
set catalogtesting (where = (money <=20.0));
prospect = 0;
RUN;
Data catalognew;
merge catalogtestingmore catalogtestingless;
BY CustomerID;
RUN;
PROC PRINT data = catalognew (obs =100);
RUN;
/* Q4 */
DATA  totalorders;
set catalogtestingmore;
retain MaxOrders;
MaxOrders = Max(MaxOrders,NGIF);
toalorder + NGIF;
RUN;
PROC PRINT data = catalogtestingmore;
sum NGIF;
run;
PROC PRINT data = totalorders (obs=10);
run;
/* Q5 */
Proc sort data=catalogtesting OUT=Catlog_sort (keep=CustomerID RAMN RFA1);
BY RFA1;
Run;

PROC print data = ArrayStore;
run;
DATA ArrayStore;
SET Catlog_sort end=last ;
BY RFA1;
array Level[4];
RETAIN _ALL_;
IF first.RFA1 THEN
DO i = 1 to 4; 
Level[i] = 0;
END;

Level[1] = RFA1;
Level[2] = Level[2] + RAMN ;
Level[3] = Level[3] + 1;
Level[4] = Level[2]/Level[3];

IF last THEN OUTPUT;
KEEP _ALL_;

RUN;
DATA Q5;
SET ArrayStore (keep = Level1 Level2 Level3 Level4);
RUN;
PROC PRINT DATA=Q5;
Title 'average order amount per customer';
Run; 
DATA ArrayStore;
SET Catlog_sort ;
BY RFA1;

array mean_purchase_by_rfa{4};
array temp_array{4} _temporary_;
set work.Catlog_sort end=last;
BY RFA1;
if first.rfa1 then
	do;
		rfasum = 0;
		customersum = 1;
		rfasum + ramn;
	end;
else do;
	if last.rfa1 then
		do;
			temp_array{rfa1} = rfasum/customersum;
	end;
	else
		do;
			customersum + 1;
			rfasum + ramn;
		end;
	end;
keep mean_purchase_by_rfa1-mean_purchase_by_rfa4;
if last then
do;
do i = 1 to 4;
mean_purchase_by_rfa{i} = temp_array{i};
end;
output;
end;
run;

/*Q6 */
DATA morethantwoorders;
set catalogtesting (where = (NGIF >=2));
KEEP CustomerID NGIF money order;
RUN;

PROC sort data = morethantwoorders OUT = sortdata;
BY NGIF money;
RUN;
libname morethan 'C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS';
proc export data = sortdata outfile = "C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\morethan\sortdata.txt" DBMS=TAB replace;
putnames = yes;                 
run;
PROC PRINT DATA = sortdata (obs=10);
RUN;

/*Q7 */
proc means data=sortdata;
Run;

/*Q1 */
proc import datafile = "C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\survey.xls"
dbms = xls
out = work.survey
replace;
sheet = "Sheet1";
getnames = yes;
mixed = no;
run;
%macro chartonumeric;
%do i=1 %to 15;
new_y&i = input(y&i, 8.);
%end;
%mend chartonumeric;
%macro renamecols;
%do i=1 %to 15;
new_y&i = y&i
%end;
%mend renamecols;
data survey1;
set work.survey;
%chartonumeric;
drop y1-y15;
rename %renamefields;
run;
proc delete data=work.survey;
run;
PROC PRINCOMP DATA=survey1 OUT=pcadat OUTSTAT=stadat plots=all;
var y1-y15;
RUN;
/*Q2 */
PROC CORR data = pcadat;
VAR ID prin1-prin4;
RUN;

PROC REG DATA = pcadat;
MODEL ID = prin1-prin4;
RUN;
/* */
/* records where NGIF >=2*/
data morethan2;
set catalogtesting;
where NGIF>=2;
Run;
/*Sortdata */
Proc sort data=morethan2 OUT=sortdata;
By NGIF Money;
Run;
/*create a library*/
libname morethan 'C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\morethan';
/*create a file in above created lib*/
data morethan.sortdata1;
set sortdata;
File 'C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\morethan\morethantwo.txt' dsd dlm=tab;
PUT CustomerID NGIF money order;
RUN;
/*take the saved data from file to sas */
Data morethan.printdata;
infile 'C:\Users\sbran\OneDrive\Desktop\AdvanceBAwithSAS\morethan\morethantwo.txt' dsd dlm=tab;
input CustomerID NGIF money order;
Run;
/*print first 10 observations */
proc print data=morethan.printdata(obs=10);
Run;
