****************************************************************
* 10/5/17
* This program creates harmonized variables in AGES to be merged
* with Health ABC, InCHIANTI, MrOS, and SOF for PROVIDO 
****************************************************************;

options nofmterr;

libname ages   "C:\Users\shardellmd\AGES";
libname ice    "C:\Users\shardellmd\Iceland\data";


**************************
* merging AGES data files
**************************;

data ages1;
set ages.shardell_from_ages_newids;
drop ostepris;
run;

proc sort data=ages1;
by id;
run;

proc sort data=ages.new_ostepris_2017_08_16;
by id;
run;

data ages_all;
merge ages1 ages.new_ostepris_2017_08_16;
by id;
 bmir = round(bmi);
run;


proc sort data=ages_all;
by age  gdsi_score bmir;
run;

data iceland_all;
set ice.iceland_all;
 SEX2 = input(SEX, $1.); 
 drop SEX;
 SEX=SEX2;
 drop SEX2;
 bmir = round(bmi);
 run;

proc sort data=iceland_all;
by age  gdsi_score bmir;
run;

data ages_all2;
merge  iceland_all ages_all;
by age  gdsi_score bmir;
run;

data ages_all3;
merge  ages_all ages_all2;
by age  gdsi_score bmir;
run;

data ages_all;
set ages_all3;
run;


***************************************************************
* r1:
* Baseline data: Baseline versions of gait speed and other 
*                functional or proximal outcomes of interest
* Baseline visit: enrollment (first) visit for participants
***************************************************************;

data r1;
set ages_all;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 0;

*falls in past 12 mo;
FALL = HEALFALL;

*number of falls in past 12 mo (not assessed);
NUMFALLS= .;


*self-reported walking disability 500 m;
MOBDIS =(HEALWALK > 1);
if HEALWALK in (.,7) then MOBDIS=.;

*self-reported unable to walk 500 m;
MOBDISUN =(HEALWALK=4);
if HEALWALK in (.,7) then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =( HEAL10ST > 1);
if  HEAL10ST in (.,7) then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN =( HEAL10ST = 4);
if  HEAL10ST in (.,7) then ADLSTEPSUN=.;

*self-reported bathing disability;
ADLBATHE =(HEALBATH > 1 );
if HEALBATH in (.,7) then ADLBATHE=.;

*self-reported disability dressing;
ADLDRESS =(HEALDRES > 1);
if HEALDRES in (.,7) then ADLDRESS=.;

*self-reported transfering disability (bed/chair);
ADLTRANSFER =(HEALBECH > 1);
if HEALBECH in (.,7) then ADLTRANSFER=.;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability (not assessed);
IADLSHOP =.;

*self-reported meal prep disability (not assessed);
IADLMEAL =.;

*self-reported heavy housework disability (not assessed);
IADLHVHOUSWK =.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;



*chair stands ;
CHAIRTIME = .;

*knee ext strength (in Nm) (only tested one leg);
KNEEXT = Legstrnm ;

*6m gait speed (m/sec);
GTSPEED6M = 6/TIME_NORMAL ;  
*converting 6m to 4m using equation in Studenski JAMA 2011 paper;
GTSPEED4M  = -0.0341 + GTSPEED6M*0.9816;

*grip strength (convert from N to kg), only tested one hand;
MAXGRIP = ISOMMASTHAND/9.80665;

*LEG DXA-like BMD: in AGES, DXA is simulated through QCT BMD;
BMDLEGDXA = A2BCT32TOBD;

*hip (femoral neck) DXA-like BMD: in AGES, DXA is simulated through QCT BMD;
BMDHIPDXA = A2BCT32NBMD;

*hip fractures: (history of);
HIPFRACTURE = (HEALBKHP in (1));

* days since baseline as defined in this project;
FOLLOWUPTIME=0;

keep ID YEAR FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED6M GTSPEED4M MAXGRIP BMDLEGDXA
BMDHIPDXA HIPFRACTURE FOLLOWUPTIME; 

run;

***************************************************************
* r2:
* follow-up data: gait speed and other functional or proximal
*                 outcomes of interest measured at r2 (1st followup)
* follow-up visit: 2nd visit for participants
***************************************************************;

data r2;
set ages_all;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 3;

*falls in past 12 mo (not assessed at followup);
FALL = .;

*number of falls in past 12 mo (not assessed);
NUMFALLS= .;


*self-reported walking disability 500 m;
MOBDIS =(A2HEALWALK > 1);
if A2HEALWALK in (.) then MOBDIS=.;

*self-reported unable to walk 500 m;
MOBDISUN =(A2HEALWALK=4);
if A2HEALWALK in (.) then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =( A2HEAL10ST > 1);
if  A2HEAL10ST in (.) then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN =( A2HEAL10ST = 4);
if  A2HEAL10ST in (.) then ADLSTEPSUN=.;

*self-reported bathing disability;
ADLBATHE =(A2HEALBATH > 1 );
if A2HEALBATH in (.,7) then ADLBATHE=.;

*self-reported disability dressing;
ADLDRESS =(A2HEALDRES > 1);
if A2HEALDRES in (.,7) then ADLDRESS=.;

*self-reported transfering disability (bed/chair);
ADLTRANSFER =(A2HEALBECH > 1);
if A2HEALBECH in (.,7) then ADLTRANSFER=.;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability (not assessed);
IADLSHOP =.;

*self-reported meal prep disability (not assessed);
IADLMEAL =.;

*self-reported heavy housework disability (not assessed);
IADLHVHOUSWK =.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed)
IADLMONEY =.;


*chair stands ;
CHAIRTIME = .;

*knee ext strength (in Nm) (only tested one leg);
KNEEXT = a2legstrnm; 

*6m gait speed (m/sec);
GTSPEED6M = 6/A2TIME_NORMAL ;  
*c*converting 6m to 4m using equation in Studenski JAMA 2011 paper;
GTSPEED4M  = -0.0341 + GTSPEED6M*0.9816;

*grip strength (convert from N to kg), only tested one hand;
MAXGRIP = A2ISOMMASTHAND/9.80665;

*LEG DXA-like BMD: in AGES, DXA is simulated through QCT BMD;
BMDLEGDXA = A2FCT32TOBD;  /* leg BMD */
*hip (femoral neck) DXA-like BMD: in AGES, DXA is simulated through QCT BMD;
BMDHIPDXA = A2FCT32NBMD;

* fractures (adjudicated);
* fractures: any from baseline to 3.5 years later;
HIPFRACTURE = (hipfx_ctr>0) & (days_to_first_hipfx <(365.25*3.5));
if hipfx_ctr=. then HIPFRACTURE=.;

* days since baseline as defined in this project;
FOLLOWUPTIME = A2DAYS_AGES_AGESII;


keep ID YEAR FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED6M GTSPEED4M MAXGRIP BMDLEGDXA BMDHIPDXA
HIPFRACTURE FOLLOWUPTIME;

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
* Baseline data: exposure and covariates for adustment
* Mortality: Time to death or loss to follow-up (censoring)
* Baseline visit: enrollment (first) visit for participants
***************************************************************;

data r1_pred;
set ages_all;

*************************************
*EXPOSURE and BIOMARKER COVARIATES
*************************************;

*25(OH)D vitamin D;
*note: measured using Liaison;
SERUMVITD = D_25OHD ; /*in nmol/mL*/

*serum calcium;
SERUMCALCIUM = CA; /* in mg/dL */

*PTH;
PTH = PTH; /* in ng/L = pg/mL */

*alkaline phosphatase (not assessed);
ALK = .;

*bone-specific alkaline phosphatase (not assessed);
BONEALK = .;

*serum phosphorus (not assessed);
SERUMPHOS = .;

*alpha-klotho (not assessed);
PLASMAKLOTHO = .;

*serum creatinine (not assessed);
SCREA = .;

***************
* DEMOGRAPHICS
***************;

AGE = AGE;

FEMALE = (sex=2);

WHITE = 1;

*marital status;
CUMARRIED = (HEALMARI=1);
NEMARRIED = (HEALMARI in (4));
FOMARRIED = (HEALMARI in (2,3));
if HEALMARI in (.) then do;
CUMARRIED =.; NEMARRIED = .; FOMARRIED =.;
end;

*education (HS grad, yes=1);
EDU = HS_GRAD;

***************
* LIFESTYLE
***************;

*calcium intake (not assessed);
CALCIUMFOOD = .;

*phosphorus intake (not assessed);
PHOSFOOD = .;

**Estimated protein intake based on self-reported meat, fish, fishmeal, and sausage intake;
*Categories: 1 = Never, 2 = <1/wk, 3 = 1-2 times/wk, 4 = 3-4 times/wk, 
*5 = 5-6 times/wk, 6 = Daily,  7 = >Daily
*Meat: assumes each serving is 22g;
MEATGDAY = ((QUE2NMMM=1)*0 + (QUE2NMMM=2)*(1/7) + (QUE2NMMM=3)*(2/7) + (QUE2NMMM=4)*(4/7) +  
           (QUE2NMMM=5)*(6/7) + (QUE2NMMM=6)*(7/7) + (QUE2NMMM=7)*(10.5/7))*22;
*Fish: assumes each serving is 45g;
FISHGDAY = ((QUE2NFMM=1)*0 + (QUE2NFMM=2)*(1/7) + (QUE2NFMM=3)*(2/7) + (QUE2NFMM=4)*(4/7) +  
           (QUE2NFMM=5)*(6/7) + (QUE2NFMM=6)*(7/7) + (QUE2NFMM=7)*(10.5/7))*45;
*Fishmeal: assumes each serving is 22.5g;    
FISHMLGDAY = ((QUE2NFBR=1)*0 + (QUE2NFBR=2)*(1/7) + (QUE2NFBR=3)*(2/7) + (QUE2NFBR=4)*(4/7) +  
           (QUE2NFBR=5)*(6/7) + (QUE2NFBR=6)*(7/7) + (QUE2NFBR=7)*(10.5/7))*45/2;  
*Protein: assumes each serving is 10g; 
SAUSAGEGDAY = ((QUE2NBLS=1)*0 + (QUE2NBLS=2)*(1/7) + (QUE2NBLS=3)*(2/7) + (QUE2NBLS=4)*(4/7) +  
           (QUE2NBLS=5)*(6/7) + (QUE2NBLS=6)*(7/7) + (QUE2NBLS=7)*(10.5/7))*10; 
*Protein g/day from food; 
PROTEINFOOD = sum(MEATGDAY, FISHGDAY,FISHMLGDAY,SAUSAGEGDAY);

**Estimated dairy intake based on self-reported cultured milk and milk intake;
*Categories: 1 = Never, 2 = <1/wk, 3 = 1-2 times/wk, 4 = 3-4 times/wk, 
*5 = 5-6 times/wk, 6 = Daily,  7 = >Daily
*Cultured milk products: assumes each serving is 200g;
CULTMILK = ((QUE2NMPR=1)*0 + (QUE2NMPR=2)*(1/7) + (QUE2NMPR=3)*(2/7) + (QUE2NMPR=4)*(4/7) +  
           (QUE2NMPR=5)*(6/7) + (QUE2NMPR=6)*(7/7) + (QUE2NMPR=7)*(10.5/7))*200;  
*Milk: assumes each serving is 200g;
MILK = ((QUE2NMLK=1)*0 + (QUE2NMLK=2)*(1/7) + (QUE2NMLK=3)*(2/7) + (QUE2NMLK=4)*(4/7) +  
           (QUE2NMLK=5)*(6/7) + (QUE2NMLK=6)*(7/7) + (QUE2NMLK=7)*(10.5/7))*200; 
*Dairy g/day from food; 
DAIRYINTAKE = sum(CULTMILK, MILK);

*vitamin D intake (not assessed);
VITDFOOD = .; 

**Alcohol intake (drink/d);
*converting week to day, converting grams to drinks assuming 14 g per drink;
ALCINTAKE = (alcoholgweek/7)/14; 

*Smoking (current, former, never);
CURSMOKE = (SMOKINGSTATUS =2);
FORMSMOKE = (SMOKINGSTATUS =1);
if SMOKINGSTATUS =. then do;
CURSMOKE=.; FORMSMOKE=.;
end;

*calcium supplements (not assessed); 
CALCSUP = .;

*vitamin D supplements (not assessed);
VITDSUP = .;

**physical activity;
*2 = highly active (mod/vig activity>3 hrs/wk); 
*1 = moderately active (mod/vig acitivity 1-3 hrs/wk or light activity >= 1-3 hrs/wk);
PHYSACT = 2*(QUE2NMPA>4) + 1*(QUE2NMPA<=4)*(QUE2NMPA=4 |  QUE2NLPA>=4);
if QUE2NMPA=. | QUE2NLPA=. then PHYSACT=.;


*******************
* Health Conditions
*******************;

**CHF;
*self report and diuretic and at least one of angiotensis, ace inhibitor, or glykosides;
CHF= (
(HEALCONG=1) & (DIURETIC=1 | DIURETIC1=1 | DIURETIC2=1) &
((ANGIOTENSISN=1 |ACEINHIB=1) | GLYKOSIDES=1)
);
if HEALCONG in (.)  then CHF=.;

**angina;
*self report and nitrates;
ANGINA = (
(HEALANGI=1) & (NITRATES=1)
);
if HEALANGI in (.) then ANGINA=.;

**hypertension (self report, drugs, BP);
*SBP > 140 mmHg or self-report and at least one of 
*1) angiotensin, 2) diuretic, 3) ace inhibitor, calcium blocker, beta blocker, or htn med;
HYPERT=(
(SYS>140) |
(
(HEALHYPT=1) & 
(
(ANGIOTENSISN=1) | ((DIURETIC=1) | (DIURETIC1=1)| (DIURETIC2=1)) |
(ACEINHIB=1) | (CABLOCKVASC=1) | (BBLOCKER=1) |  (HEALHYPM=1)
)
)
);
if HEALHYPT in (.) then HYPERT=.;

*diastolic BP;
DIABP=DID;

*systolic BP;
SYSBP=SYS;

*Myocardial infarction (self report);
MI=(HEALATTK=1);
if HEALATTK in (.) then MI=.;


**diabetes;
*self report, hypoglycemia meds, or insulin;
DIABETES = (
(HEALDBTS=1) | (HYPOGLYCEMO=1) | (INSULIN_MED=1) 
);
if HEALDBTS in (.) then DIABETES=.;


*stroke (self report);
STROKE = (HEALSTRK=1);
if HEALSTRK in (.) then STROKE=.;

**arthritis;
*knee arthritis (not assessed);
KNEEARTH = .;
*hip arthritis (not assessed);
HIPARTH = .;

*baseline hip fracture for time-invariant variable (self-report);
BASEHIPFRACTURE = (HEALBKHP = 1);

*cancer (not assessed);
CANCER = .;

**lung conditions;
*emphysema (not assessed);
EMPH = .;
*asthma (not assessed);
ASTHMA = .;

**baseline steoporosis;
*Total femur T-Score using means and SDs from Looker (1998);
TSCORE = (CT02TOBD-0.942)/0.122*(FEMALE=1) + 
         (CT02TOBD-1.041)/0.144*(FEMALE=0);
*T-score < -2.5 or osteoporosis meds;
BASEOSTEO = (TSCORE < -2.5 & TSCORE>.) | (OSTEPRIS=1);
if OSTEPRIS=. then BASEOSTEO=.;


*******************
* Other Measures;
*******************;

*BMI (kg/m^2);
BMI = BMI;

*Cognition (MMSE score);
MMSE = MM_SCORE; 

*depressive symptoms (GDS Score);
GDS = GDSI_SCORE;

*self-rated health (self report);
SRHEALTH = (6-HEALSTAT ); /* reverse order to match other cohorts */
if HEALSTAT =7 then SRHEALTH = .;
if SRHEALTH=5 then SRHEALTH=4; /* combining very good with excellent */

*month of visit;
MONTH = month_sample;

* Mortality;
DEAD = (DAYS_AGES_IC_TO_DEATH>.); /* 1 = dead, 0 = censored */
TIMEENROLLTODEATH = DAYS_AGES_IC_TO_DEATH;  /* #days from enrollment until death */
if TIMEENROLLTODEATH=. then TIMEENROLLTODEATH= 4727.00; /* if alive, assume censored after last death time */
TIMEENROLLTOBASE=0; /* #days from enrollment until baseline for this project */ 
TIMEBASETODEATH = TIMEENROLLTODEATH - TIMEENROLLTOBASE; /* #days from baseline for this project until death */ 
FOLLOWDATE=.; /* not released */;

keep ID SERUMVITD SERUMCALCIUM PTH ALK BONEALK SERUMPHOS PLASMAKLOTHO AGE FEMALE WHITE 
CUMARRIED NEMARRIED FOMARRIED EDU CALCIUMFOOD PHOSFOOD PROTEINFOOD DAIRYINTAKE VITDFOOD ALCINTAKE CURSMOKE FORMSMOKE CALCSUP 
VITDSUP PHYSACT CHF ANGINA HYPERT DIABP SYSBP MI DIABETES STROKE KNEEARTH HIPARTH BASEHIPFRACTURE CANCER EMPH ASTHMA BASEOSTEO 
BMI MMSE GDS SCREA SRHEALTH MONTH DEAD TIMEENROLLTODEATH TIMEENROLLTOBASE TIMEBASETODEATH FOLLOWDATE
DAYS_AGES_IC_TO_DEATH;

run;

proc sort data= r1_pred;
by ID;
run;

proc sort data=long;
by ID;
run;

* combining longitudinal function outcomes with baseline exposure and covariates;
data long2;
merge long r1_pred;
by ID;
STUDY="AGES";
NEWID = cats(STUDY,put(ID , BEST12.)) ;
run;

proc sort data=long2;
by ID YEAR;
run;

data "AGES_VITDTARGETS";
set long2;
run;
