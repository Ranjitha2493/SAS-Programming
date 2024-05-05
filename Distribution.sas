
/*	Question - 1a	*/
/*	1000 Random samples using NORMAL distribution 	*/
DATA NormalDistribution;
do i = 1 to 1000;
 Values=rand('NORMAL',90,8);
OUTPUT;
END;
RUN;
/* 	View 10 observations of  NormalDistribution dataset	 */
PROC PRINT DATA=NormalDistribution (obs = 10);
RUN;
/* 	Generating histogram from the NormalDistribution 	*/
PROC SGPLOT DATA= NormalDistribution;
TITLE "Histogram for Normal Distribution";
HISTOGRAM Values;
RUN;

/*	Question 1b */
/* 1000 Random samples using EXPONENTIAL distribution */
DATA ExponentialDistribution;
DO i = 1 TO 1000;
 Values=rand('EXPONENTIAL')/8;
OUTPUT;
END;
RUN;
/* View 10 observations of  ExponentialDistribution dataset */
PROC PRINT DATA=ExponentialDistribution (obs =10);
RUN;
/* Generating histogram from the ExponentialDistribution output */
PROC SGPLOT DATA= ExponentialDistribution;
TITLE "Historgram for Exponential Distribution";
HISTOGRAM Values;
RUN;

/*	Question 1c	 */
/* 1000 Random samples using BINOMIAL distribution */
DATA BinomialDistribution;
do i = 1 to 1000;
 Values=rand('BINOMIAL',0.2,200);
OUTPUT;
END;
RUN;
/* View 10 observations of BinomialDistribution dataset  */
PROC PRINT DATA=BinomialDistribution (obs = 10);
RUN;
/* Generating histogram from the BINOMDIST function output */
PROC SGPLOT DATA= BinomialDistribution;
TITLE "Historgram for Binomial Distribution";
HISTOGRAM Values;
RUN;

/*	Question 1d	 */
/* 1000 Random samples using POISSON distribution */

DATA PoissionDistribution;
do i = 1 to 1000;
 Values=rand('POISSON',8);
OUTPUT;
END;
RUN;
/* View 10 observations of PoissionDistribution dataset  */
PROC PRINT DATA=PoissionDistribution (obs = 10);
RUN;
/* Generating histogram from the PoissionDistribution output */
PROC SGPLOT DATA= PoissionDistribution;
TITLE "Historgram for Poission Distribution";
HISTOGRAM Values;
RUN;
/*	Question 1e	 */
/* 1000 Random samples using using GAMMA distribution */
DATA GammaDistribution;
do i = 1 to 1000;
 Values=rangam(3,8);
OUTPUT;
END;
RUN;
/* View 10 observations of GammaDistribution dataset*/
PROC PRINT DATA=GammaDistribution (obs = 10);
RUN;
/* Generating histogram from the GammaDistribution output */
PROC SGPLOT DATA= GammaDistribution;
TITLE "Historgram for Gamma Distribution";
HISTOGRAM Values;
RUN;
