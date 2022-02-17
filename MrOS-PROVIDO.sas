****************************************************************
*12/29/17
* This program creates harmonized variables in MrOS to be merged
* with AGES, Health ABC, InCHIANTI, and SOF for PROVIDO 
****************************************************************;

options nofmterr;

libname genetics 'C:\Users\shardellmd\Desktop\MrOSFEB15\GNAUG14';
libname y1a        "C:\Users\shardellmd\MROS\baseline\F1AUG14";
libname y1b        "C:\Users\shardellmd\MROS\baseline\FG1AUG12";
libname y1c        "C:\Users\shardellmd\MROS\baseline\OH1AUG14";
libname y1d        "C:\Users\shardellmd\MROS\baseline\QC1OCT10";
libname y1e        "C:\Users\shardellmd\MROS\baseline\QH1OCT10";
libname y1f        "C:\Users\shardellmd\MROS\baseline\V1FEB14";
libname y1g        "C:\Users\shardellmd\MROS\baseline\B1OCT10";
libname y1h        "C:\Users\shardellmd\MROS\baseline\AS1FEB14";
libname y1i        "C:\Users\shardellmd\MROS\baseline\BM1FEB09";
libname y1j        "C:\Users\shardellmd\MROS\baseline\D1OCT10";

libname othera        "C:\Users\shardellmd\MROS\other\EFFEB15";
libname otherb        "C:\Users\shardellmd\MROS\other\FAFEB15";

libname y3a 	"C:\Users\shardellmd\MROS\V2\V2FEB14";
libname y3b 	"C:\Users\shardellmd\MROS\V2\B2AUG09";


**********************************************
* merging baseline (enrollment) data files, genes, and mortality (V1)
**********************************************;

data mros_y1;
merge y1a.F1AUG14 y1b.FG1AUG12 y1c.OH1AUG14 y1d.QC1OCT10 y1e.QH1OCT10 y1f.V1FEB14 y1g.B1OCT10 y1h.AS1FEB14 y1i.BM1FEB09
y1j.D1OCT10 othera.EFFEB15 otherb.FAFEB15 genetics.mros_genetics053118;
by id;
run;


**********************************************
* merging follow-up data files (V2)
**********************************************;

data mros_y3;
merge y3a.V2FEB14 y3b.B2AUG09 otherb.FAFEB15;
by id;
run;


***************************************************************
* r1:
* Baseline data: Baseline versions of gait speed and other 
*                outcomes of interest
***************************************************************;

data r1_y1;
set mros_y1;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR=0;

*falls in past 12 mo;
FALL = MHFALL;
if MHFALL>1 then FALL=.;

*number of falls in past 12 mo;
NUMFALLS= MHFALLTM; *1=1, 2=2 to 3, 3=4 to 5, 4= 6 or more;
if FALL=0 then NUMFALLS=0;
if FALL in (.M) then NUMFALLS=0;
if NUMFALLS in (.M) then NUMFALLS=0;


*self-reported walking disability (2-3 blocks);
MOBDIS =(QLBLK1 in (0,.K)); *treat don't do as unable;
if QLBLK1 in (.,.A) then MOBDIS=.;

*self-reported unable to walk 2-3 blocks;
MOBDISUN =(MOBDIS=1 & QLBLKLVL=3); *treat don't do as unable;
if MOBDIS=. | QLBLKLVL=. then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =(  QLSTP1 in (0,.K)); *treat don't do as unable;
if  QLSTP1 in (.,.A) then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN =(ADLSTEPS=1 & QLSTPLVL=3); *treat don't do as unable;
if ADLSTEPS=. | QLSTPLVL=. then ADLSTEPSUN=.;

*self-reported bathing disability (not assessed);
ADLBATHE=.; 

*self-reported disability dressing (not assessed);
ADLDRESS =.; 

*self-reported transfering disability (bed/chair) (not assessed);
ADLTRANSFER =.;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability;
IADLSHOP =(QLSHP1 in (0, .K));
if QLSHP1 in (.,.A) then IADLSHOP=.;

**self-reported meal prep disability;
IADLMEAL =(QLMEL1 in (0,.K) );
if QLMEL1 in (.,.A) then IADLMEAL=.;

*self-reported heavy housework disability;
IADLHVHOUSWK =(QLHHW1 in (0,.K) );
if QLHHW1 in (.,.A) then IADLHVHOUSWK=.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIME = NFTIME5; /*includes time for those who used arms */

*knee ext strength (in Watts) ;
KNEEXT = mean(NPLMAX,NPRMAX); 

*6m gait speed (m/sec);
GTSPEED6M = NFWLKSPD;  
*convert 6m gait to 4m gait using equation in Studenski JAMA 2011 paper;
GTSPEED4M = -0.0341 + GTSPEED6M*0.9816; 
if GTSPEED4M in (., .A, .M) then GTSPEED4M=.;

*grip strength (kg);
MAXGRIP = max(GSRT1, GSRT2,GSLF1,GSLF2);

*LEG DXA BMD;
BMDLEGDXA = mean(B1LLD,B1RLD);  /* mean of left and right, be aware of longitudinal correction*/

*HIP DXA BMD;
BMDHIPDXA= B1THD; /*mean of left and right, be aware of longitudinal corrections*/

*interview date;
VISITDATE = EFDATE;

*hip fractures (adjudicated);
HIPFRACTURE = FFHIP ;
if FFHIP in (.M,.W) then HIPFRACTURE=0;

FOLLOWUPTIME=0;

keep ID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA BMDHIPDXA
HIPFRACTURE FOLLOWUPTIME;
run;

proc sort data=r1_y1;
by ID;
run;

* to merge with follow-up data to compute time since R1 date;
data r1date;
set r1_y1;
R1VISITDATE=VISITDATE;
keep ID R1VISITDATE;
run;

proc sort data=r1date;
by ID;
run;

***************************************************************
* r2_y3:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   V1 is baseline, V2 is the first follow-up. 
***************************************************************;

data r2_y3;
merge mros_y3 r1date;
by ID;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR=3;

*falls in past 12 mo;
FALL = MHFALL;
if MHFALL>1 or MHFALL in (.A) then FALL=.;

*number of falls in past 12 mo;
NUMFALLS= MHFALLTM; *1=1, 2=2 to 3, 3=4 to 5, 4= 6 or more;
if FALL=0 then NUMFALLS=0;
if FALL in (.M) then NUMFALLS=0;
if NUMFALLS in (.M) then NUMFALLS=0;
if NUMFALLS in (.A) then NUMFALLS=.;

*self-reported walking disability (2-3 blocks);
MOBDIS =(QLBLK1 in  (0,.K)); *treat don't do as unable;
if QLBLK1 in (.,.A) then MOBDIS=.;

*self-reported unable to walk 2-3 blocks;
MOBDISUN =(MOBDIS=1 & QLBLKLVL=3); *treat don't do as unable;
if MOBDIS=. | QLBLKLVL in (., .A) then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =(  QLSTP1 in (0,.K)); *treat don't do as unable;
if  QLSTP1 in (.,.A) then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN =(ADLSTEPS=1 & QLSTPLVL=3); *treat don't do as unable;
if ADLSTEPS=. | QLSTPLVL in (., .A) then ADLSTEPSUN=.;

*self-reported bathing disability (not assessed);
ADLBATHE=.; 

*self-reported disability dressing (not assessed);
ADLDRESS =.; 

*self-reported transfering disability (bed/chair) (not assessed);
ADLTRANSFER =.;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability;
IADLSHOP =(QLSHP1 in (0, .K));
if QLSHP1 in (.,.A) then IADLSHOP=.;

*self-reported meal prep disability;
IADLMEAL =(QLMEL1 in (0, .K) );
if QLMEL1 in (.,.A) then IADLMEAL=.;

*self-reported heavy housework disability;
IADLHVHOUSWK =(QLHHW1 in (0, .K) );
if QLHHW1 in (.,.A) then IADLHVHOUSWK=.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIME = NFTIME5; /*includes time for those who used arms */

*knee ext strength (in Watts) ;
KNEEXT = mean(NPLMAX,NPRMAX); /*average of leg-specific max's*/

*6m gait speed (m/sec);
GTSPEED6M = NFWLKSPD;
*convert from 6m to 4m using equation in Studenski 2011 JAMA;  
GTSPEED4M = -0.0341 + GTSPEED6M*0.9816; 
if GTSPEED4M in (., .A, .M) then GTSPEED4M=.;

*grip strength (kg);
MAXGRIP = max(GSRT1, GSRT2,GSLF1,GSLF2);

*LEG DXA BMD;
BMDLEGDXA = mean(B2LLD,B2RLD);  /* mean of left and right, need to be aware of longitudinal corrections*/
BMDLEGDXAV2V1 = mean(B2LLD1,B2RLD1);

*hip DXA BMD;
BMDHIPDXA= B2THD; /*mean of left and right, need to be aware of longitudinal corrections*/
BMDHIPDXAV2V1 = B2THD1;

*interview date;
VISITDATE = V2DATE;
VISITDATE2 = R1VISITDATE+365*3.25; *latest timing of fracture corresponding to ~3 years for all;

diffvisit = (VISITDATE-R1VISITDATE)/365;

*hip fractures since baseline (adjudicated);
HIPFRACTURE = (FAANYHIP=1 & (FAHIPDT1<VISITDATE2)) ;

FOLLOWUPTIME = VISITDATE-R1VISITDATE;

keep ID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA BMDLEGDXAV2V1 BMDHIPDXA BMDHIPDXAV2V1
HIPFRACTURE FOLLOWUPTIME;

run;


***************************************************************
* long:
* appending r2_y3 to r1_y1
***************************************************************;

data long;
set r1_y1 r2_y3;
run; 


proc sort data=long;
by ID  descending year;
run;


* addressing the DXA longitudinal correction;
data long2;
set long;
lagBMDLEGDXA=lag(BMDLEGDXAV2V1);

if YEAR=3 & lagBMDLEGDXA>. then BMDLEGDXA=lagBMDLEGDXA;
else if YEAR=0 & lagBMDLEGDXA>. then BMDLEGDXA=lagBMDLEGDXA;

lagBMDHIPDXA=lag(BMDHIPDXAV2V1);

if YEAR=3 & lagBMDHIPDXA>. then BMDHIPDXA=lagBMDHIPDXA;
else if YEAR=0 & lagBMDHIPDXA>. then BMDHIPDXA=lagBMDHIPDXA;

drop BMDLEGDXAV2V1 lagBMDLEGDXA BMDHIPDXAV2V1 lagBMDHIPDXA;
run;

***************************************************************
* r1_pred:
* Baseline data: exposure and covariates for adustment measured at V1
* Mortality: Time to death or loss to follow-up (censoring)
* Baseline visit: enrollment (first) visit for participants
***************************************************************;

data r1_pred;
set mros_y1;

*************************************
*EXPOSURE and BIOMARKER COVARIATES
*************************************;

*25(OH)D vitamin D;
SERUMVITD = OHVDTOTI; /* in nmol/mL */

*serum calcium;
SERUMCALCIUM = ASCA; /* in mg/dL */

*PTH;
PTH = OHPTTI; /* intact in pg/mL */

*alkaline phosphatase;
ALK = ASALP2S; /* in U/L */

*serum phosphorus;
SERUMPHOS = ASPHOS2; /* in mg/dL */

*FGF23;
FGF23=FGF23; /* in pg/ml */

*serum creatinine (mg/dl);
SCREA = ascreat;

***************
* DEMOGRAPHICS
***************;

AGE =  GIAGE1;

FEMALE = 0;

WHITE = (GIERACE=1);
BLACK = (GIERACE=2);

*marital status;
CUMARRIED = (GIMSTAT=1);
NEMARRIED = (GIMSTAT=5);
FOMARRIED = (GIMSTAT in (2,3,4));


*education (HS grad, yes=1); 
EDU = (GIEDUC>=4); /*GIEDUC: 1=some ele, 2=ele, 3=some hi, 4=hi, 5=some college, 6=college, 7=some grad, 8=grad*/
if EDU=. then GIEDUC=.;

***************
* LIFESTYLE
***************;

*calcium intake from food (mg/d);
CALCIUMFOOD = DTCALC;

*calcium intake from food and supplements (mg/d);
CALCIUMFOODSUP = DTTCALCM;

*mean daily intake from supplements > 0;
CALCSUP = (DTSPCALC>0);
if DTSPCALC in (., .A,.W,.R) then CALCSUP=.;

*phosphorus intake from food (mg/d);
PHOSFOOD = DTPHOSPH;

*protein intake (g/d);
PROTEINFOOD = DTPROTEI;
if DTPROTEI in (.A,.W,.R) then PROTEINFOOD=.;

*dairy (servings/day);
DAIRYINTAKE = DTRDRYSV;
if DAIRYINTAKE in (.A,.W,.R) then DAIRYINTAKE=.;

*vitamin D intake from food (converting IU to mcg/d);
VITDFOOD = DTVITD*0.025;

*vitamin D intake from food and supplements (converting IU to mcg);
VITDFOODSUP = DTTVTMND*.025;

*vitamin D from supplements (mean daily intake from supplements >0);
VITDSUP = (DTSPVITD>0);
if DTSPVITD  in (., .A,.W,.R) then VITDSUP=.;

*alcohol intake (drink/d);
ALCINTAKE = TUDRSMC/7; *converting from week to day;

*Smoking (current, former, never);
CURSMOKE = (TURSMOKE=2);
FORMSMOKE = (TURSMOKE=1);
if TURSMOKE=. then do;
CURSMOKE=.; FORMSMOKE=.;
end;

****Physical activity, adapting items from PASE measure;
*hours in endurance sports (moderate-intensity);
STREND = PAWGT*PAWGTT;
if STREND=. then STREND=0; 

*hours in strenuous sports (high-intensity);
STRSPORT = PASTR*PASTRT/2; /*(swimming & aerobic dance reclass as moderate; cycling reclass as moderate*/
if STRSPORT=. then STRSPORT=0; /*hours in strenuous sport*/

*hours in moderate sports (moderate-intensity);
MODSPORT = PAMOD*PAMODT + min(0,PASTR*PASTRT/3); */2 of 6 strenuous activities reclass as moderate/*
if MODSPORT=. then MODSPORT=0; /*hours in moderate sport*/

*hours in light sports (light-intensity);
LTSPORT = PALTE*PALTET + min(0,PASTR*PASTRT/6); */1 of 6 strenuous activities reclass as moderate*/
if LTSPORT=. then LTSPORT=0; /*hours in light sport*/

*hours walking (light-intensity);
WALKTIME = PAWALK*PAWALKT;
if WALKTIME=. then WALKTIME=0; /*hours walking*/

LIGHTACTIVITY = sum(WALKTIME, LTSPORT);
MODERATEACTIVITY = sum(MODSPORT,STREND) ;
HIGHACTIVITY = STRSPORT;

**physical activity;
*2 = highly active, 1 = moderately active, 0 = sedentary; 
if HIGHACTIVITY> 3 | MODERATEACTIVITY> 4 then PHYSACT=2;
else if  MODERATEACTIVITY> 2 | LIGHTACTIVITY> 3 then PHYSACT=1;
else PHYSACT=0;
if LIGHTACTIVITY=. & MODERATEACTIVITY=. & HIGHACTIVITY=. then PHYSACT=.;


*******************
* Health Conditions
*******************;

**CHF;
*self report and diuretic and at least one of angiotensin, or ace inhibitor;
CHF= (
(MHCHF=1) & (MUDILOOP=1 | MUDIPOTA=1 | MUDUITHX=1 ) &
(MUARB=1 |MUACE=1)
);
if MHCHF in (.)  then CHF=.;

**angina;
*self report and nitrates;
ANGINA = (
(MHANGIN=1) & (MUNITRA=1)
);
if MHANGIN in (.) then ANGINA=.;


*diastolic BP;
DIABP=.;

*systolic BP;
SYSBP=mean(bparm1, bparm2);

**hypertension (self report, drugs, BP);
*SBP > 140 mmHg or self-report and at least one of 
*1) angiotensin, 2) diuretic, 3) ace inhibitor, calcium blocker, or beta blocker;
HYPERT=(
(SYSBP>140) |
(
(MHBP=1) & 
(
(MUARB=1) | ((MUDILOOP=1) | (MUDIPOTA=1)| (MUDUITHX=1)) |
(MUACE=1) | (MUCABLOK=1) | (MUBETA=1)
)
)
);
if MHBP in (.) then HYPERT=.;

*Myocardial infarction (self report);
MI = (mhmi=1);
if mhmi=. then MI=.;

*diabetes;
*self report or hypoglycemia meds;
DIABETES = (
(MHDIAB=1) | (MUHYPOG=1) 
);
if MHDIAB in (.) then DIABETES=.;

*blood glucose (mg/dL);
GLUCOSE=D1FGLUC;

*stroke (self report);
STROKE = (mhstrk=1);
if mhstrk=. then STROKE=.;

**arthritis;
*knee arthritis (self report);
KNEEARTH = (MHARTH=1 & MHKNEE=1);
*hip arthritis (self report);
HIPARTH = (MHARTH=1 & MHHIP=1);

*baseline hip fracture for time-invariant variable (self-report);
BASEHIPFRACTURE = (FFHIP=1);

*cancer (self report);
CANCER = (mhcancer=1);

**lung conditions;
*Emphysema (not assessed);
EMPH = .;
*Asthma (not assessed);
ASTHMA = .;
*COPD (self report);
COPD=MHCOPD;

**baseline osteoporosis;
*Femoral neck T-Score using means and SDs from Looker (1998);
TSCORE = (B1FND-0.934)/0.137*(GIERACE in (1, 3, 5)) + /*white, asian, other*/ 
         (B1FND-1.074)/0.168*(GIERACE = 2) + /*black*/
         (B1FND-0.982)/0.137*(GIERACE = 4)  /*hispanic, using mex norms*/
         
;
if GIERACE=. then TSCORE=.;

*T-score < -2.5 or osteoporosis meds;
BASEOSTEO = (TSCORE < -2.5 & TSCORE>.) | (MUMEDOST=1);
if MUMEDOST=. then BASEOSTEO=.;


*******************
* Other Measures;
*******************;

*BMI (kg/m^2);
BMI = HWBMI;
if HWBMI in (., .G,.H,.W) then BMI=.;

*Cognition (Modified MMSE);
THREEMS = TMMSCORE;

*depressive symptoms (SF-12 mental component);
SF12MC = QLMCS12;
if QLMCS12 in (.N) then SF12MC=.;

**self-rated health (self report);
SRHEALTH = (6-QLHEALTH); /* reverse order to match other cohorts */
if QLHEALTH  in (.,.A) then SRHEALTH=.;
if SRHEALTH=5 then SRHEALTH=4; /* combining very good with excellent */

*study site;
if SITE="BI" then STUDYSITE="BIRMINGHAM";
else if SITE="MN" then STUDYSITE="MINNEAPOLIS";
else if SITE="PA" then STUDYSITE="PALO ALTO";
else if SITE="PI" then STUDYSITE="PITTSBURGH";
else if SITE="PO" then STUDYSITE="PORTLAND";
else if SITE="SD" then STUDYSITE="SAN DIEGO";

*baseline interview date;
BASEVISITDATE = EFDATE;

*month of visit;
MONTH = month(EFDATE);

*mortality;
DEAD = (DADEAD=1);
TIMEENROLLTODEATH = FUCDTIME; *DTLASTCT - VISITDATE;  /* #days from enrollment until death*/
TIMEENROLLTOBASE=0; *enrollment = baseline here;
TIMEBASETODEATH = TIMEENROLLTODEATH; *enrollment=baseline;
FOLLOWDATE = BASEVISITDATE + TIMEBASETODEATH;

keep ID BASEVISITDATE SERUMVITD SERUMCALCIUM PTH ALK SERUMPHOS FGF23 AGE FEMALE WHITE BLACK CUMARRIED NEMARRIED FOMARRIED EDU CALCIUMFOODSUP PHOSFOOD PROTEINFOOD DAIRYINTAKE VITDFOODSUP
 ALCINTAKE CALCSUP VITDSUP DIABP SYSBP CURSMOKE FORMSMOKE PHYSACT CHF ANGINA HYPERT MI DIABETES STROKE KNEEARTH HIPARTH BASEHIPFRACTURE CANCER COPD
 BASEOSTEO BMI THREEMS SF12MC GLUCOSE SCREA SRHEALTH MONTH STUDYSITE RS7041 RS1352844 RS1491709 RS1491711
RS222014 RS222016 RS3733359 RS705117 
RS705125 RS842881 DEAD TIMEENROLLTODEATH TIMEENROLLTOBASE TIMEBASETODEATH FOLLOWDATE; 

run;


***************************************************************
* long3:
* merging longitudinal data (long2) to r1_pred
***************************************************************;

data long3;
merge long2 r1_pred;
by ID;
MROSID=ID;
drop ID;
STUDY="MROS";
NEWID = cats(STUDY,MROSID) ;
run;

data "MROS_VITDTARGETS2";
set long3;
run;
