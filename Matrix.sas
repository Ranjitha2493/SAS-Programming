/*Q1*/

proc iml;
A={1 1 1 1 , 1 1 -1 -1, 1 -1 1 -1,1 -1 -1 1};
b = {14, -4, -2, 0};

W = inv(A) * b;
print A;
print b;
TITLE "System of equation";
print W;

quit;





/*Q2*/

data qI2;
input ID Y X1 X2 X3;
datalines;
1 3 4 5 1
2 8 5 4 1
3 9 2 1 1
4 7 6 4 0
5 5 3 6 0
6 4 7 3 0
;
proc reg data=qI2;
model Y = X1 X2 X3;
run;









/*adding explicitly the intercept values in X0*/

data qI2;
input ID Y X0 X1 X2 X3;
datalines;
1 3 1 4 5 1
2 8 1 5 4 1
3 9 1 2 1 1
4 7 1 6 4 0
5 5 1 3 6 0
6 4 1 7 3 0
;

/*recreating using iml*/
PROC IML;
/*Read data into IML */
use qI2;
read all;
*combine X0 X1 X2 X3 into matrix x;
x = X0 || X1 || X2 || X3;

b = INV(x` * x) * (x`*y);
/*parameter estimates*/
TITLE "Parameter Estimates using PROC IML";
print b;

quit;

/*Q3*/

PROC IML;
A = {1 2 3 4,
5 6 7 8,
9 10 11 12};

/*a.count the number of rows*/
r = nrow(A);
c = ncol(A);
print c;
TITLE "Number of Rows";
print r;


/*b. creating sub matrix */

s = A[1:3, 1:2];
TITLE "SUB Matrix";
print s;
quit;
