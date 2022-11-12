**************************************************;
*** CREATION OF COHORT FOR AHT TRAJECTORIES ***;
**************************************************;

*ELIZABETH;
*merge AHT cohort and Census data;
DATA h4p_aht_init_cohort2000_2018;
set "P:\Nyamwange, Elizabeth\summer research\datasets\h4p_aht_init_cohort2000_2018";
RUN;

proc contents data=h4p_aht_init_cohort2000_2018;
run;

DATA SES_variables;
set "P:\Nyamwange, Elizabeth\summer researcg\datasets\SES_variables";
RUN;

DATA SES_variables;
set SES_variables;
run;

DATA SES_variables;
set SES_variables;
run;

proc contents data=SES_variables;
run;

proc print data=SES_variables (obs=500);
var zip;
run;

DATA h4p_aht_init_cohort2000_2018;
set h4p_aht_init_cohort2000_2018;
zip=substr(Zip_Delivery,1,5);
run;



proc contents data=h4p_aht_init_cohort2000_2018;
run;

proc print data=h4p_aht_init_cohort2000_2018 (obs=500);
var Zip_Delivery zip;
run;

proc sort data=h4p_aht_init_cohort2000_2018;
by zip;
run;

proc sort data=SES_variables;
by zip;
run;

data AHT_merged;
merge h4p_aht_init_cohort2000_2018 (in=inh4p_aht_init_cohort2000_2018) SES_variables (in=inSES_variables);
by zip;
if inh4p_aht_init_cohort2000_2018 and inSES_variables;
run;

proc print data=AHT_merged (obs=100);
run;

proc contents data=AHT_merged;
run;

data AHT_merged;
set AHT_merged;
if SES_Flag=1;
run;

data "P:\Straub, Loreen\summer student\datasets\AHT_merged";
set AHT_merged;
run;


**LOREEN**;

***DOWNLOAD ALL FILES FOR PROC TRAJ***;
*follow instructions to download all packages on https://www.andrew.cmu.edu/user/bjones/download.htm;


* for simplicity, start with all pregnancies with preterm=0 to make sure everyone has same length of pregnancy;
data traj_term;
set AHT_merged;
where preterm=0;
run;

* check distribution of Any_AHT_PDC_preg_M<x> Intervals;

ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\distribution_PCD_variables.csv";
proc means data=traj_term mean std Min P5 P25 P50 P75 P90 P95 P99 Max;
var 
AnyAHT_PDC_Preg_M1_M5
AnyAHT_PDC_Preg_M6
AnyAHT_PDC_Preg_M7
AnyAHT_PDC_Preg_M8
AnyAHT_PDC_Preg_M9
;
run;
ods csv close;

* create gestational intervals;
data traj_term;
set traj_term;
gest_interval_M1_M5=1;
gest_interval_M6=2;
gest_interval_M7=3;
gest_interval_M8=4;
gest_interval_M9=5;
run;

* save as permanent file;
data "P:\Straub, Loreen\summer student\datasets\traj_term";
set traj_term;
run;

*******************
***PROC TRAJ*******
*******************;
data traj_term;
set traj_term;
run;

proc contents data=traj_term;
run;


*** START WITH 5 GROUP MODEL -- can decide whether we want to rerun for other number of groups ***;
proc traj data=traj_term outplot=op_5 outstat=os_5 out=of_5 outest=oe_5 ITDETAIL;
id Patient_Id;
Var AnyAHT_PDC_Preg_M1_M5
AnyAHT_PDC_Preg_M6
AnyAHT_PDC_Preg_M7
AnyAHT_PDC_Preg_M8
AnyAHT_PDC_Preg_M9;
Indep gest_interval_M1_M5
gest_interval_M6
gest_interval_M7
gest_interval_M8
gest_interval_M9;
model cnorm;
max 100;
ngroups 5;
order 3 3 3 3 3;
run;

ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\proc_traj_term_5groups.csv";
proc print data=op_5 noobs;
run;
ods trace on;
ods csv close;

* Calculate mean predicted probabilities;
DATA fivegroups;
	SET of_5;
RUN;

proc sort data=fivegroups;
by GROUP;
run;
proc means data=fivegroups mean std median q1 q3;
var GRP1PRB GRP2PRB GRP3PRB GRP4PRB GRP5PRB;
by GROUP;
run;

DATA "P:\Straub, Loreen\summer student\datasets\fivegroups";
	SET fivegroups;
RUN;


* calculate number of women in each group;
data fivegroups;
set "P:\Straub, Loreen\summer student\datasets\fivegroups";
run;

ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\number_women_per_group_5groups.csv";
proc freq data=fivegroups;
table GROUP /nopercent nocol norow;
title "fivegroups";
run;

ods csv close;

* calculate mean PDC in each group;
ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\mean_PDC_per_group_5groups.csv";

proc means data=fivegroups mean std median q1 q3;
var GRP1PRB GRP2PRB GRP3PRB GRP4PRB GRP5PRB ;
by GROUP;
title "fivegroups";
run;
ods csv close;


*** REPEAT FOR 4 GROUP MODEL ***;
proc traj data=traj_term outplot=op_4 outstat=os_4 out=of_4 outest=oe_4 ITDETAIL;
id Patient_Id;
Var AnyAHT_PDC_Preg_M1_M5
AnyAHT_PDC_Preg_M6
AnyAHT_PDC_Preg_M7
AnyAHT_PDC_Preg_M8
AnyAHT_PDC_Preg_M9;
Indep gest_interval_M1_M5
gest_interval_M6
gest_interval_M7
gest_interval_M8
gest_interval_M9;
model cnorm;
max 100;
ngroups 4;
order 3 3 3 3;
run;

ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\proc_traj_term_4groups.csv";
proc print data=op_4 noobs;
run;
ods trace on;
ods csv close;

* Calculate mean predicted probabilities;
DATA fourgroups;
	SET of_4;
RUN;

proc sort data=fourgroups;
by GROUP;
run;
proc means data=fourgroups mean std median q1 q3;
var GRP1PRB GRP2PRB GRP3PRB GRP4PRB;
by GROUP;
run;

DATA "P:\Straub, Loreen\summer student\datasets\fourgroups";
	SET fourgroups;
RUN;


* calculate number of women in each group;
data fourgroups;
set "P:\Straub, Loreen\summer student\datasets\fourgroups";
run;

ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\number_women_per_group_4groups.csv";
proc freq data=fourgroups;
table GROUP /nopercent nocol norow;
title "fourgroups";
run;

ods csv close;

* calculate mean PDC in each group;
ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\mean_PDC_per_group_4groups.csv";

proc means data=fourgroups mean std median q1 q3;
var GRP1PRB GRP2PRB GRP3PRB GRP4PRB ;
by GROUP;
title "fourgroups";
run;
ods csv close;



**LIZ**;

********************************************
** MERGE data=fourgroups WITH full data set and assess mean PDC within each interval and for each group **
********************************************;

DATA =fourgroups;
set "P:\Straub, Loreen\summer student\datasets\fourgroups";
RUN;

data fourgroups_cut;
set fourgroups;
drop AnyAHT_PDC_preg_M1_M5
AnyAHT_PDC_preg_M6
AnyAHT_PDC_preg_M7
AnyAHT_PDC_preg_M8
AnyAHT_PDC_preg_M9 gest_interval_M1_M5
gest_interval_M6
gest_interval_M7
gest_interval_M8
gest_interval_M9;

proc sort data=fourgroups_cut;
by Patient_Id;
run;

proc sort data=traj_term;
by Patient_Id;
run;

data traj_merged;
merge traj_term (in=intraj_term) fourgroups_cut (in=infourgroups_cut);
by Patient_Id;
if intraj_term and infourgroups_cut;
run;

data "P:\Straub, Loreen\summer student\datasets\traj_merged";
set traj_merged;
run;


data traj_merged;
set traj_merged;
run;

proc print data=traj_merged (obs=10);
run;

proc export data=traj_merged
outfile="P:\Straub, Loreen\summer student\datasets\traj_merged.csv" dbms=csv replace;
run;

* calculate mean PDC in each interval separately for each group;
ods csv file="P:\Straub, Loreen\summer student\SAS_outputs\mean_PDC_per_interval_per_group.csv";

proc means data=traj_merged n mean stderr lclm uclm alpha=0.05;
class Group;
var AnyAHT_PDC_preg_M1_M5
AnyAHT_PDC_preg_M6
AnyAHT_PDC_preg_M7
AnyAHT_PDC_preg_M8
AnyAHT_PDC_preg_M9;
output out=PDC_4groups N=n MEAN=mean LCLM=lclm UCLM=uclm STDERR=stderr;
run;
ods csv close;


**************************************************;
*** SPAGHETTI PLOTS FOR INDIVIDUAL TRAJECTORIES WITHIN GROUPS ***;
**************************************************;

***GROUP1***;

*create datasets for random sample of 200 pregnancies per group;
proc sql outobs=200;
create table group1_sample as select *
from traj_merged
where group=1
order by ranuni (0);
quit;

* transform from wide to long form;
data group1_sample_long;
set group1_sample;
interval=AnyAHT_PDC_preg_M1_M5; time=1; t=1; output;
interval=AnyAHT_PDC_preg_M6; time=2; t=2; output;
interval=AnyAHT_PDC_preg_M7; time=3; t=3; output;
interval=AnyAHT_PDC_preg_M8; time=4; t=4; output;
interval=AnyAHT_PDC_preg_M9; time=5; t=5; output;
drop AnyAHT_PDC_preg_M1_M5
AnyAHT_PDC_preg_M6
AnyAHT_PDC_preg_M7
AnyAHT_PDC_preg_M8
AnyAHT_PDC_preg_M9;
run;

* keep only variables of interest;
data group1_sample_long;
set group1_sample_long;
keep Patient_Id interval time t;
run;

** REPEAT FOR OTHER GROUPS **
(...);


*create spaghetti plots with pre-specified grid values;
ods excel file="spaghettiplots.xlsx";
*ods graphics / GROUPMAX=7000 ANTIALIASMAX=133100;
proc sgplot data=group1_sample_long;
series x=time y=interval / group=<patid>;
xaxis label ="GA intervals";
yaxis label ="PDC" grid values = (0 to 100 by 10);
title 'Group 1';
run;

** REPEAT FOR OTHER GROUPS **
(...);
ods excel close;



**************************************************;
*** COHORT CHARACTERISTICS ***;
**************************************************;

* get data;
data traj_merged;
set "traj_merged";
run;

*FOR FULL COHORT;
ods csv file="characteristics_full_cohort.csv";
* proc means of continuous variables;
proc means data=traj_merged N mean std;
var <list all continuous variables here with space between variables>;
run;
	
* proc freq of categorical variables;
proc freq data=traj_merged;
tables <list all categorical variables here with space between variables>
/nopercent nocol norow;
run;

ods csv close;

*By trajectory group;
ods csv file="characteristics_traj_groups.csv";
* proc means of continuous variables;
proc means data=traj_merged N mean std;
var <list all continuous variables here with space between variables>;
class group;
run;
	
* proc freq of categorical variables;
proc freq data=traj_merged;
tables (<list all categorical variables here with space between variables>)*group
/nopercent nocol norow;
run;

ods csv close;
