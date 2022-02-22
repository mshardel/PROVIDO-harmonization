****************************************************************
* 10/11/18
* This program creates harmonized variables in SOF to be merged
* with AGES, Health ABC, InCHIANTI, and MrOS for PROVIDO

*baseline visit: V4 (yr6) 
*follow-up visit: V5 (yr8) and V6 (yr10) 
****************************************************************;

options nofmterr;

libname y1        "C:\Users\shardellmd\Desktop\SOF\V1";
libname y2        "C:\Users\shardellmd\Desktop\SOF\V2yr2";
libname y3dot5	  "C:\Users\shardellmd\Desktop\SOF\V3yr3.5";		
libname y6        "C:\Users\shardellmd\Desktop\SOF\V4yr6"; *baseline;
libname y8        "C:\Users\shardellmd\Desktop\SOF\V5yr8"; *for follow-up;
libname y10       "C:\Users\shardellmd\Desktop\SOF\V6yr10"; *for follow-up;
libname y6meds        "C:\Users\shardellmd\Desktop\SOF\V4meds"; *med data;
libname y6dairy        "C:\Users\shardellmd\Desktop\SOF\V4dairy"; *dairy diet data;
libname y1mort   "C:\Users\shardellmd\Desktop\SOF\V1mortality"; *mortality dataset;

**V4 (y6) is baseline here. Identifying who is alive at study baseline;
data mortality;
set y1mort.t030519;
NEWV4DEATH =  V4DEATH;
NEWV4FOLALL = V4FOLALL;
drop V4DEATH V4FOLALL;
run;


**********************************************
* merging y1 (enrollment) data files and mortality
**********************************************;
data sof_y1;
merge mortality y1.v1demogr y1.v1anthro y1.v1qol y2.v2qol y1.v1meds y1.v1cogfxn y1.v1vital  y1.v1labdata y1.v1physperf y1.v1physfunc y1.v1fxfall y1.v1endpt y1.v1lifestyle y1.v1medhx y2.v2medhx;
by id;
run;


**********************************************
* merging y6 (V4, baseline) data files
**********************************************;
data sof_y6;
merge y6.v4physfunc  y6.v4physperf y6.v4fxfall y6.v4endpt y1.v1endpt y2.v2endpt y3dot5.v3endpt y6.v4dxhp y8.v5dxhp y10.v6dxhp y6.v4demogr
y6.v4anthro y6.v4qol y6.v4meds y6.v4medhx y6.v4cogfxn y1.v1vital y6.v4labdata  y6.v4lifestyle y6.v4medhx y6.T092816 y6meds.T102517 y6dairy.T121517; *these latter 3 datasets include the vitamin D, meds, and dairy questions;
by id;
run;


proc sort data=sof_y6;
by ID;
run;

proc sort data=sof_y1;
by ID;
run;


***************************************************************
* r1:
* Baseline data: Baseline versions of gait speed and other 
*                outcomes of interest
***************************************************************;

data r1;
merge sof_y6 sof_y1;
by ID;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 0;

*falls in past 12 mo;
FALL = V4FALL;

*number of falls in past 12 mo;
NUMFALLS= V4NFALL;

*self-reported walking disability 0.25 mile;
MOBDIS = (V4WLKR1 in (1, .J, .K));
if V4WLKR1 in (.,.A, .O) then MOBDIS=.;

*self-reported unable to walk 0.25 mile;
MOBDISUN = (V4WLK2 in (3));
if V4WLK2 in (.,.A, .O) then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS = (V4CLBR1 in (1, .J, .K));
if V4CLBR1 in (.,.A, .O) then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN = (V4CLB2 in (3));
if V4CLB2 in (.,.A, .O) then ADLSTEPSUN=.;

*self-reported bathing disability;
ADLBATHE =(V4WSHR1 in (1, .J, .K));
if V4WSHR1 in (.,.A, .O) then ADLBATHE=.;

*self-reported disability dressing;
ADLDRESS =(V4DRR1 in (1, .J, .K));
if V4DRR1 in (.,.A, .O) then ADLDRESS=.;

*self-reported transfering disability (bed/chair);
ADLTRANSFER =(V4BEDR1 in (1, .J, .K));
if V4BEDR1 in (.,.A, .O) then ADLTRANSFER=.;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability;
IADLSHOP =(V4SHR1 in (1, .J, .K));
if V4SHR1 in (.,.A, .O) then IADLSHOP=.;

*self-reported meal prep disability;
IADLMEAL =(V4CKR1 in (1, .J, .K));
if V4CKR1 in (.,.A, .O) then IADLMEAL=.;

*self-reported heavy housework disability;
IADLHVHOUSWK =(V4HHR1 in (1, .J, .K));
if V4HHR1 in (.,.A, .O) then IADLHVHOUSWK=.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (time to perform 5 chair stands);
CHAIRTIME = V4CHRTM; 

*knee ext strength (not assessed);
KNEEXT = .; 

*6m gait speed (m/sec);
GTSPEED6M = V4WLKSPD; 
*converting 6m to 4m using equation in Studenski JAMA 2011 paper;
GTSPEED4M = -0.0341 + GTSPEED6M*0.9816; 

*grip strength (kg);
MAXGRIP = V4GRPMAX; 
if V4GRPMAX in (., .A,.D, .O, .Q,.R,.U,.X,.Y) then MAXGRIP=.;

*Leg BMD BMD
BMDLEGDXA =.; 

*total hip BMD from DXA;
BMDHIPDXA=V6THD4;  * V5THD4; /*visit 4 BMD longitudinally adj for visit 6*/

*interview date;
VISITDATE = .;

*fractures (adjudicated) before V4 (either adjudicated btw enrollment and V4 or hx before enrollment;
TIMEFROMV1TOFRAC = V1HIPF;  *time from V1 to fracture;
TIMEFROMV1TOV4 = V1FOLALL-V4FOLALL; *time from V1 to V4;

FOLLOWUPTIME=0;

*history before v1 or anything between v1 and v4;
HIPFRACTURE = max(V1HIPI*((TIMEFROMV1TOV4)>=TIMEFROMV1TOFRAC),V1HIP50);

keep ID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER 
ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY 
CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA BMDHIPDXA HIPFRACTURE FOLLOWUPTIME;

run;


**********************************************
* using data from Year 8 (V5) and Year 10 (V6) 
* for follow-up (Round 2, r2)
* merging y8 (V5, baseline) data files for follow-up
**********************************************;

data sof_y8;
merge y8.v5physfunc  y8.v5physperf y8.v5fxfall y8.v5dxhp y10.v6dxhp y8.v5endpt y1.v1endpt y6.v4endpt;
by id;
run;


***************************************************************
* r2_y8:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   Y5 (V4) is baseline, so ideal follow-up is Y8 (V5). If not measured
                   at Y8 (V5), then use Y8 (V5) or Y10 (V6) or their average if both.
***************************************************************;

data r2_y8;
set sof_y8;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 3;

*falls in past 12 mo;
V5FALL = V5FALL;

*number of falls in past 12 mo;
V5NUMFALLS= V5NFALL;

*self-reported walking disability (0.25 mile);
V5MOBDIS = (V5WLKR1 in (1, .J, .K));
if V5WLKR1 in (.,.A, .O) then V5MOBDIS=.;

*self-reported unable to walk 0.25 mile;
V5MOBDISUN = (V5WLK2 in (3));
if V5WLK2 in (.,.A, .O) then V5MOBDISUN=.;

*self-reported stair climb disability (10 steps);
V5ADLSTEPS = (V5CLBR1 in (1, .J, .K));
if V5CLBR1 in (.,.A, .O) then V5ADLSTEPS=.;

*self-reported unable to climb 10 steps;
V5ADLSTEPSUN = (V5CLB2 in (3));
if V5CLB2 in (.,.A, .O) then V5ADLSTEPSUN=.;

*self-reported bathing disability;
V5ADLBATHE =(V5WSHR1 in (1, .J, .K));
if V5WSHR1 in (.,.A, .O) then V5ADLBATHE=.;

*self-reported disability dressing;
V5ADLDRESS =(V5DRR1 in (1, .J, .K));
if V5DRR1 in (.,.A, .O) then V5ADLDRESS=.;

*self-reported transfering disability (bed/chair);
V5ADLTRANSFER =(V5BEDR1 in (1, .J, .K));
if V5BEDR1 in (.,.A, .O) then V5ADLTRANSFER=.;

*self-reported toileting disability (not assessed);
V5ADLTOILET =.;

*self-reported light housework disability (not assessed);
V5ADLLTHOUSWK =.;

*self-reported shopping disability;
V5IADLSHOP =(V5SHR1 in (1, .J, .K));
if V5SHR1 in (.,.A, .O) then V5IADLSHOP=.;

*self-reported meal prep disability;
V5IADLMEAL =(V5CKR1 in (1, .J, .K));
if V5CKR1 in (.,.A, .O) then V5IADLMEAL=.;

*self-reported heavy housework disability;
V5IADLHVHOUSWK =(V5HHR1 in (1, .J, .K));
if V5HHR1 in (.,.A, .O) then V5IADLHVHOUSWK=.;

*self-reported traveling disability (not assessed);
V5IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (time to perform 5 chair stands);
V5CHAIRTIME = V5CHRTM; 

*knee ext strength (not assessed);
V5KNEEXT = .; 

*6m gait speed (m/sec);
V5GTSPEED6M = V5WLKSPD; 
*convert from 6m to 4m using equation in Studenski 2011 JAMA;
V5GTSPEED4M = -0.0341 + V5GTSPEED6M*0.9816;   

*grip strength (kg);
V5MAXGRIP = V5GRPMAX; 
if V5GRPMAX in (., .A,.D, .O, .Q,.R,.U,.X,.Y) then V5MAXGRIP=.;

*LEG DXA BMD (not assessed);
V5BMDLEGDXA =.; 

*total hip BMD from DXA;
V5BMDHIPDXA=V6THD5; /* visit 5 longitudinally adjusted for visit 6*/

*interview date (not publicly released);
V5VISITDATE = .;


*fractures (adjudicated) Between V4 and V5;
TIMEFROMV1TOFRAC = V1HIPF;  *time from V1 to fracture;
TIMEFROMV4TOFRAC = V4HIPF;  *time from V4 to fracture;
TIMEFROMV1TOV4 = V1FOLALL-V4FOLALL; *time from V1 to V4;
TIMEFROMV1TOV5 = V1FOLALL-V5FOLALL; *time from V1 to V5;
TIMEFROMV4TOV5 = V4FOLALL-V5FOLALL; *time from V4 to V5;

if V4FOLALL=. then TIMEFROMV1TOV4 = 6.25*365; *if no V4;
if V5FOLALL=. then  TIMEFROMV1TOV5 = TIMEFROMV1TOV4 + 2.25*365;

V5HIPFRACTURE = V1HIPI*((TIMEFROMV1TOV5-TIMEFROMV1TOV4)>=TIMEFROMV4TOFRAC);
if TIMEFROMV4TOFRAC=. then do;
 V5HIPFRACTURE = V1HIPI*((TIMEFROMV1TOFRAC>=TIMEFROMV1TOV4) & (TIMEFROMV1TOV5>=TIMEFROMV1TOFRAC));
 if TIMEFROMV1TOFRAC=. then HIPFRACTURE=0;
end;

keep ID YEAR V5VISITDATE V5FALL V5NUMFALLS V5MOBDIS V5MOBDISUN V5ADLSTEPS V5ADLSTEPSUN V5ADLBATHE V5ADLDRESS V5ADLTRANSFER 
V5ADLTOILET V5ADLLTHOUSWK V5IADLSHOP V5IADLMEAL V5IADLHVHOUSWK V5IADLMEAL V5IADLTRAVEL V5IADLMEDS V5IADLMONEY 
V5CHAIRTIME V5KNEEXT V5GTSPEED4M V5MAXGRIP V5BMDLEGDXA V5BMDHIPDXA V5HIPFRACTURE TIMEFROMV4TOV5;

run;


**********************************************
* merging y10 (V6, baseline) data files for follow-up
**********************************************;

data sof_y10;
merge y10.v6physfunc  y10.v6physperf y10.v6fxfall y10.v6dxhp y10.v6endpt y1.v1endpt y6.v4endpt;
by id;
run;


***************************************************************
* r2_y10:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   Y5 (V4) is baseline, so ideal follow-up is Y8 (V5). If not measured
                   at Y8 (V5), then use Y8 (V5) or Y10 (V6) or their average if both.
***************************************************************;

data r2_y10;
set sof_y10;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 3;

*falls in past 12 mo;
V6FALL = V6FALL;

*number of falls in past 12 mo;
V6NUMFALLS= V6NFALL;

*self-reported walking disability 0.25 mile;
V6MOBDIS = (V6WLKR1 in (1, .J, .K));
if V6WLKR1 in (.,.A, .O) then V6MOBDIS=.;

*self-reported unable to walk 0.25 mile;
V6MOBDISUN = (V6WLK2 in (3));
if V6WLK2 in (.,.A, .O) then V6MOBDISUN=.;

*self-reported stair climb disability (10 steps);
V6ADLSTEPS = (V6CLBR1 in (1, .J, .K));
if V6CLBR1 in (.,.A, .O) then V6ADLSTEPS=.;

*self-reported unable to climb 10 steps;
V6ADLSTEPSUN = (V6CLB2 in (3));
if V6CLB2 in (.,.A, .O) then V6ADLSTEPSUN=.;

*self-reported bathing disability (not assessed);
V6ADLBATHE =.;

*self-reported disability dressing (not assessed);
V6ADLDRESS =.;

*self-reported transfering disability (bed/chair) (not assessed);
V6ADLTRANSFER =.;

*self-reported toileting disability (not assessed);
V6ADLTOILET =.;

*self-reported light housework disability (not assessed);
V6ADLLTHOUSWK =.;

*self-reported shopping disability;
V6IADLSHOP =(V6SHR1 in (1, .J, .K));
if V6SHR1 in (.,.A, .O) then V6IADLSHOP=.;

*self-reported meal prep disability;
V6IADLMEAL =(V6CKR1 in (1, .J, .K));
if V6CKR1 in (.,.A, .O) then V6IADLMEAL=.;

*self-reported heavy housework disability;
V6IADLHVHOUSWK =(V6HHR1 in (1, .J, .K));
if V6HHR1 in (.,.A, .O) then V6IADLHVHOUSWK=.;

*self-reported traveling disability (not assessed);
V6IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
V6IADLMEDS = .;

*self-reported managing money disability (not assessed);
V6IADLMONEY =.;

*chair stands (time to perform 5 chair stands);
V6CHAIRTIME = V6CHRTM; 

*knee ext strength (not assessed);
V6KNEEXT = .; 

*6m gait speed (m/sec);
V6GTSPEED6M = V6WLKSPD; 
*convert from 6m to 4m using equation in Studenski 2011 JAMA;  
V6GTSPEED4M = -0.0341 + V6GTSPEED6M*0.9816; 

*grip strength (kg);
V6MAXGRIP = V6GRPMAX; 
if V6GRPMAX in (., .A,.D, .O, .Q,.R,.U,.X,.Y) then V6MAXGRIP=.;

*LEG DXA BMD (not assessed);
V6BMDLEGDXA =.; 

*total hip BMD from DXA;
V6BMDHIPDXA=V6THD;

*interview date (not publicly released);
V6VISITDATE = .;

*fractures (adjudicated) Between V4 and V6;
TIMEFROMV1TOFRAC = V1HIPF;  *time from V1 to fracture;
TIMEFROMV4TOFRAC = V4HIPF;  *time from V4 to fracture;
TIMEFROMV1TOV4 = V1FOLALL-V4FOLALL; *time from V1 to V4;
TIMEFROMV1TOV6 = V1FOLALL-V6FOLALL; *time from V1 to V6;
TIMEFROMV4TOV6 = V4FOLALL-V6FOLALL;

if V4FOLALL=. then TIMEFROMV1TOV4 = 6.25*365; *if no V4;
if V6FOLALL=. then  TIMEFROMV1TOV6 = TIMEFROMV1TOV4 + 4.25*365;

V6HIPFRACTURE = V1HIPI*((TIMEFROMV1TOV6-TIMEFROMV1TOV4)>=TIMEFROMV4TOFRAC);*((TIMEFROMV1TOFRAC>=TIMEFROMV1TOV3) & (TIMEFROMV1TOV4>=TIMEFROMV1TOFRAC)); *fractures between V1 and V3;
if TIMEFROMV4TOFRAC=. then do;
 V6HIPFRACTURE = V1HIPI*((TIMEFROMV1TOFRAC>=TIMEFROMV1TOV4) & (TIMEFROMV1TOV6>=TIMEFROMV1TOFRAC));
 if TIMEFROMV1TOFRAC=. then HIPFRACTURE=0;
end;

keep ID YEAR V6VISITDATE V6FALL V6NUMFALLS V6MOBDIS V6MOBDISUN V6ADLSTEPS V6ADLSTEPSUN V6ADLBATHE V6ADLDRESS V6ADLTRANSFER 
V6ADLTOILET V6ADLLTHOUSWK V6IADLSHOP V6IADLMEAL V6IADLHVHOUSWK V6IADLMEAL V6IADLTRAVEL V6IADLMEDS V6IADLMONEY 
V6CHAIRTIME V6KNEEXT V6GTSPEED4M V6MAXGRIP V6BMDLEGDXA V6BMDHIPDXA V6HIPFRACTURE TIMEFROMV4TOV6;

run;


proc sort data=r2_y8;
by ID;
run;

proc sort data=r2_y10;
by ID;
run;


data r2;
merge r2_y8 r2_y10;
by ID;

*Using data from V6 if V6 is closer to 3 yrs from V4 than V5;
if abs(TIMEFROMV4TOV6-365*3) < abs(TIMEFROMV4TOV5-365*3) then do; 

VISITDATE=V6VISITDATE; FALL =V6FALL; NUMFALLS=V6NUMFALLS; MOBDIS=V6MOBDIS; MOBDISUN=V6MOBDISUN;
ADLSTEPS=V6ADLSTEPS; ADLSTEPSUN=V6ADLSTEPSUN; ADLBATHE=V6ADLBATHE; ADLDRESS=V6ADLDRESS; ADLTRANSFER=V6ADLTRANSFER; 
ADLTOILET=V6ADLTOILET; ADLLTHOUSWK=V6ADLLTHOUSWK; IADLSHOP=V6IADLSHOP; IADLMEAL=V6IADLMEAL; IADLHVHOUSWK=V6IADLHVHOUSWK;
IADLMEAL=V6IADLMEAL; IADLTRAVEL=V6IADLTRAVEL; IADLMEDS=V6IADLMEDS; IADLMONEY=V6IADLMONEY; 
CHAIRTIME=V6CHAIRTIME; KNEEXT=V6KNEEXT; GTSPEED4M=V6GTSPEED4M; MAXGRIP=V6MAXGRIP; 
BMDLEGDXA=V6BMDLEGDXA; BMDHIPDXA=V6BMDHIPDXA; HIPFRACTURE=V6HIPFRACTURE; FOLLOWUPTIME=TIMEFROMV4TOV6; SOURCE=6;
end;

*Otherwise use data from V5 (V5 is closer to 3 yrs from V4 than V6);
else do;
VISITDATE=V5VISITDATE; FALL =V5FALL; NUMFALLS=V5NUMFALLS; MOBDIS=V5MOBDIS; MOBDISUN=V5MOBDISUN;
ADLSTEPS=V5ADLSTEPS; ADLSTEPSUN=V5ADLSTEPSUN; ADLBATHE=V5ADLBATHE; ADLDRESS=V5ADLDRESS; ADLTRANSFER=V5ADLTRANSFER; 
ADLTOILET=V5ADLTOILET; ADLLTHOUSWK=V5ADLLTHOUSWK; IADLSHOP=V5IADLSHOP; IADLMEAL=V5IADLMEAL; IADLHVHOUSWK=V5IADLHVHOUSWK;
IADLMEAL=V5IADLMEAL; IADLTRAVEL=V5IADLTRAVEL; IADLMEDS=V5IADLMEDS; IADLMONEY=V5IADLMONEY; 
CHAIRTIME=V5CHAIRTIME; KNEEXT=V5KNEEXT; GTSPEED4M=V5GTSPEED4M; MAXGRIP=V5MAXGRIP; 
BMDLEGDXA=V5BMDLEGDXA; BMDHIPDXA=V5BMDHIPDXA; HIPFRACTURE=V5HIPFRACTURE; FOLLOWUPTIME=TIMEFROMV4TOV5; SOURCE=5;
end;


keep ID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER 
ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY 
CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA BMDHIPDXA HIPFRACTURE FOLLOWUPTIME SOURCE;
run;


***************************************************************
* long:
* appending r2 to r1
***************************************************************;

data long;
set r1 r2; 
run;

***************************************************************
* r1_pred:
* Baseline data: exposure and covariates for adustment measured at V4 (y6)
* time-invariant data at V1 and med hx at V2 (latest time at or before V4)
* Mortality: Time to death or loss to follow-up (censoring)
* Baseline visit: enrollment (first) visit for participants
***************************************************************;

data r1_pred;
merge sof_y6 sof_y1 y3dot5.v3medhx;
by id;

**************************************
*EXPOSURE and BIOMARKER COVARIATES
*************************************;

*25(OH)D vitamin D;
SERUMVITD =  TOTD*2.496; /*convert from ng/mL to nmol/mL*/ 
if TOTD in (., .H, .N, .W) then SERUMVITD=.;

*serum calcium;
SERUMCALCIUM =  .; 

*PTH ;
PTH = .; 

*alkaline phosphatase;
ALK = .;

*bone-specific alkaline phosphatase; 
BONEALK = .;

*serum phosphorus ;
SERUMPHOS = .; 

*serum creatinine;
SCREA = .;

*klotho (not assessed);
PLASMAKLOTHO = .; 

***************
* DEMOGRAPHICS
***************;

AGE = V4AGE;
if V4AGE in (.,.H) thrn AGE=.;
FEMALE = 1;

WHITE = (V1RACE=1);
if V1RACE=. then WHITE=.;

*marital status;
CUMARRIED = (V4MARRY=1);
NEMARRIED = (V4MARRY =3);
FOMARRIED = (V4MARRY in (2,4));
if V4MARRY =. then do;
CUMARRIED =.; NEMARRIED = .; FOMARRIED =.;
end;

*education (years), coded as HS grad;
EDU = (V1EDUC>=12);
if V1EDUC in (.,.D,.G,.M,.R) then edu=.;


***************
* LIFESTYLE
***************;

*calcium intake from food (mg/d);
CALCIUMFOOD = V4CAWK21/7; /*converting from week to day*/
if V4CAWK21=. then CALCIUMFOOD=.;

*phosphorus intake (mg/d);
PHOSFOOD = .;

*protein intake (g/d);
PROTEINFOOD = V4PRWK21/7; /*converting from week to day*/
if V4PRWK21=. then PROTEINFOOD=.;


**dairy (servings/day);
*cottage cheese;
COTTCHSDAYS = 1*(V4COTTPE="DAY") + 7*(V4COTTPE="WEEK")+ 30.5*(V4COTTPE="MONTH") + 365*(V4COTTPE="YEAR");
COTTCHSSIZE = 0.5*(V4COTTSS=0) + 1*(V4COTTSS=1) + 1.5*(V4COTTSS=2);
COTCHSVDAYS = V4COTTHO*COTTCHSSIZE/COTTCHSDAYS;
*other cheese;
OTHCHSDAYS = 1*(V4CHESPE="DAY") + 7*(V4CHESPE="WEEK")+ 30.5*(V4CHESPE="MONTH") + 365*(V4CHESPE="YEAR");
OTHCHSSIZE = 0.5*(V4CHESSS=0) + 1*(V4CHESSS=1) + 1.5*(V4CHESSS=2);
OTHCHSVDAYS = V4CHESHO*OTHCHSSIZE/OTHCHSDAYS;
*milk;
MILKDAYS = 1*(V4MILKPE="DAY") + 7*(V4MILKPE="WEEK")+ 30.5*(V4MILKPE="MONTH") + 365*(V4MILKPE="YEAR");
MILKSIZE = 0.5*(V4MILKSS=0) + 1*(V4MILKSS=1) + 1.5*(V4MILKSS=2);
MILKSVDAYS = V4MILKHO*MILKSIZE/MILKDAYS;
*cream;
CREAMDAYS = 1*(V4CREAPE="DAY") + 7*(V4CREAPE="WEEK")+ 30.5*(V4CREAPE="MONTH") + 365*(V4CREAPE="YEAR");
CREAMSIZE = 0.5*(V4CREASS=0) + 1*(V4CREASS=1) + 1.5*(V4CREASS=2);
CREAMSVDAYS = V4CREAHO*CREAMSIZE/CREAMDAYS;
*yogurt;
YOGUDAYS = 1*(V4YOGUPE="DAY") + 7*(V4YOGUPE="WEEK")+ 30.5*(V4YOGUPE="MONTH") + 365*(V4YOGUPE="YEAR");
YOGUSIZE = 0.5*(V4YOGUSS=0) + 1*(V4YOGUSS=1) + 1.5*(V4YOGUSS=2);
YOGUSVDAYS = V4YOGUHO*YOGUSIZE/YOGUDAYS;

*dairy intake (servings/day);
DAIRYINTAKE= SUM(COTCHSVDAYS,OTHCHSVDAYS,MILKSVDAYS,CREAMSVDAYS,YOGUSVDAYS);
if DAIRYINTAKE=. & PROTEINFOOD >. THEN DAIRYINTAKE=0;

*vitamin D intake;
VITDFOOD = .;

*alcohol intake (drink/d);
ALCINTAKE=V4DRWK30/7;/*converting from week to day*/

*Smoking (current, former, never);
CURSMOKE = (V4SMOK=1);
FORMSMOKE = (V4SMOK=0 & V1SMOKE>0);
if V4SMOK=. then do;
CURSMOKE=.; FORMSMOKE=.;
end;

*calcium supplements y/n; 
CALCSUP = (V4CAL=1);
if CALCSUP =. then CALCSUP=.;

*vitamin D supplements y/n;
VITDSUP = (V4VTD=1);
if VITDSUP =. then VITDSUP=.;

*kcal/wk light/5/60 to convert to hours per week;
LIGHTACTIVITY=V4LOWKNP/5/60;
*kcal/wk medium/7.5/60 to convert to hours per week;
MODERATEACTIVITY=V4MEDKNP/7.5/60;
*kcal/wk heavy/10/60 to convert to hours per week;
HIGHACTIVITY=((V4TOTKNP-V4LOWKNP-V4MEDKNP)/10)/60;

**physical activity;
*2 = highly active, 1 = moderately active, 0 = sedentary; 
if HIGHACTIVITY>2 | MODERATEACTIVITY>3 then PHYSACT=2;
else if  MODERATEACTIVITY>1 | LIGHTACTIVITY>2 then PHYSACT=1;
else PHYSACT=0;
if LIGHTACTIVITY=. & MODERATEACTIVITY=. & HIGHACTIVITY=. then PHYSACT=.;

*******************
* Health Conditions
*******************;

**CHF;
*self report and diuretic and at least one of angiotensin, ace inhibitor, or glykosides;
CHF= (
(V4ECONG=1) & (V4LOOP=1 |VPOTDIUR=1 | V4THZ=1 | V4ALDO=1 ) &
((V4ACE=1 | V4HYDRAL=1) | V4DIGITALIS=1)
);
if V4ECONG in (.)  then CHF=.;

**angina;
*self report and nitrates;
ANGINA = (
(V4EANGIN=1) & (V4NIT=1)
);
if V4EANGIN in (.) then ANGINA=.;

*diastolic BP;
DIABP=V1STDDIA;
if V1STDDIA in (.,.A,.R,.W) then DIABP=.;

*systolic BP;
SYSBP=V1STDSYS;
if V1STDSYS in (.,.A,.R) then SYSBP=.;

**hypertension (self report, drugs, BP);
*SBP > 140 mmHg or self-report and at least one of 
*1) angiotensin, 2) diuretic, 3) ace inhibitor, calcium blocker, beta blocker or other HTN med;
HYPERT=(
(SYSBP>140) |
(
(V4EHYPER=1) & 
(
((V4LOOP=1) | (VPOTDIUR=1)| (V4THZ=1)) |
(V4ACE=1) | (V4CCB=1) | (V4BETA=1) |  (V4OAHYP=1) | (V4ALDO=1)
)
)
);
if V4EHYPER in (.,.A) then HYPERT=.;

*Myocardial infarction (self report);
MI = (V4EHEART=1);
if V4EHEART=. then MI=.;

*diabetes;
*self report, hypoglycemia meds, insulin, or other diabetes meds;
DIABETES = (
(V4EDIAB=1) | (V4HYPOG=1) | (V4INSULN=1) | (V4OTDIAB=1)
);
if V4EDIAB in (.) then DIABETES=.;

*serum glucose;
GLUCOSE = .; 

*stroke (self report);
STROKE = (V4ESTRK=1);
if V4ESTRK=. then STROKE=.;

**arthritis;
*knee arthritis (not assessed);
KNEEARTH = .;
*hip arthritis (not assessed);
HIPARTH = .;
*arthritis (self report);
ARTH=(V4EHKAR=1);
if V4EHKAR=. then ARTH=.;

*cancer (self report);
CANCER = .;

**lung conditions;
*Emphysema (self report);
EMPH = (V4ECOPD=1); /*includes COPD too*/
if V4ECOPD=.  then EMPH=.;
*Asthma (not assessed);
ASTHMA = .;

**baseline osteoporosis;
*Femoral neck T-Score using means and SDs from Looker (1998);
TSCORE = (V4FND-0.858)/0.120 /*white women*/ 
;

*T-score < -2.5 or osteoporosis meds;
BASEOSTEO = (TSCORE < -2.5 & TSCORE>.) | (V4MEDOST=1);
if V4MEDOST=. then BASEOSTEO=.;


*******************
* Other Measures;
*******************;

*BMI (kg/m^2);
BMI = V4BMI ;
if V4BMI in (., .G,.H,.W) then BMI=.;

*Cognition (modified MMSE 0-26, MMSE without questions on orientation);
MMSE = V4SHT3MS*30/26; /*rescaled to 0-30*/

*depressive symptoms (GDS);
GDS = V4GDS15;

**self-rated health (self report);
SRHEALTH = (6-V4COMP); /* reverse order to match other cohorts */
if V4COMP=. then SRHEALTH=.;
if SRHEALTH=5 then SRHEALTH=4; /* combining very good with excellent */

*study site;
if V1CLINIC=1 then STUDYSITE="A";
else if V1CLINIC=2 then STUDYSITE="B";
else if V1CLINIC=3 then STUDYSITE="C";
else STUDYSITE="D";

*baseline interview date (not publicly released);
BASEVISITDATE = .;
*month of visit;
BASEVISITMONTH=VMONTH;
*month of visit;
MONTH = VMONTH;


*baseline hip fracture for time-invariant;

*fractures (adjudicated) between baseline and V4;
TIMEFROMV1TOFRAC = V1HIPF;  *time from V1 to fracture;
TIMEFROMV1TOV4 = V1FOLALL-V4FOLALL; *time from V1 to V4;
if V4FOLALL in (.N) then TIMEFROMV1TOV4 = 6.25*365; *if no V4;

*history before v1 or anything between v1 and v4;
BASEHIPFRACTURE = max(V1HIPI*((TIMEFROMV1TOV4)>=TIMEFROMV1TOFRAC),V1HIP50);

*mortality;
DEAD = max(V1DEATH, NEWV4DEATH);
TIMEENROLLTODEATH = V1FOLALL;  /* #days from enrollment (V1) until death or censoring (last follow-up)*/
TIMEENROLLTOBASE = TIMEFROMV1TOV4;
TIMEBASETODEATH = V1FOLALL - TIMEFROMV1TOV4; *negative values would indicate death/censoring before baseline;
*updated mortality;
TIMEBASETODEATH = max(TIMEBASETODEATH, NEWV4FOLALL);

keep ID BASEVISITDATE   SERUMVITD SERUMCALCIUM PTH ALK BONEALK SERUMPHOS PLASMAKLOTHO AGE FEMALE WHITE CUMARRIED NEMARRIED FOMARRIED EDU  CALCIUMFOOD PHOSFOOD PROTEINFOOD DAIRYINTAKE VITDFOOD
 ALCINTAKE DIABP SYSBP CALCSUP VITDSUP CURSMOKE FORMSMOKE PHYSACT    CHF ANGINA HYPERT MI  DIABETES STROKE ARTH KNEEARTH HIPARTH BASEHIPFRACTURE CANCER EMPH ASTHMA
 BASEOSTEO BMI MMSE GDS GLUCOSE SCREA SRHEALTH STUDYSITE BASEVISITMONTH MONTH 
DEAD TIMEENROLLTODEATH TIMEENROLLTOBASE TIMEBASETODEATH; 

run;

proc sort data=long;
by ID;
run;

* combining longitudinal function outcomes with baseline exposure and covariates;
data long2;
merge long r1_pred;
by ID;
STUDY="SOF";
NEWID = cats(STUDY,put(ID , BEST12.)) ;
run;

proc sort data=long2;
by ID YEAR;
run;

data "SOF_VITDTARGETS3";
set long2;
run;




