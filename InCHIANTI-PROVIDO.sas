****************************************************************
* 03/03/19
* This program creates harmonized variables in InCHIANTI to be merged
* with AGES, Health ABC, MrOS, and SOF for PROVIDO 
****************************************************************;

options nofmterr;

libname assayf1 "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Assays";
libname klotho "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\klotho";
libname ekgf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\EKG_ENG_Doppler";
libname interf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Interview";
libname medf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Medical_Exam";
libname nutrf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Nutrients_Intake";
libname physf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Physical_Exam";
libname qctf1        "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\pQCT";
libname disf1          "C:\Users\shardellmd\InCHIANTI\Follow-up1_V3\4.Data\SAS_Datasets\Diseases";

libname assayb "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Assays";
libname ekgb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\EKG_ENG_Doppler";
libname interb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Interview";
libname medb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Medical_Exam";
libname nutrb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Nutrients_Intake";
libname physb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Physical_Exam";
libname qctb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\pQCT";
libname drugb        "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Drugs";
libname disb          "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Diseases";
libname genes          "C:\Users\shardellmd\InCHIANTI\Baseline_V6\English\4.Data\SAS_Datasets\Genes";

proc sort data=genes.dbp;
by code98;
proc sort data=genes.klothogenes;
by code98;
run;

*mortality data;
libname vit "C:\Users\shardellmd\InCHIANTI2015\Vital_Status\1.Data\SAS_Datasets\Master";

**********************************************
* merging baseline (enrollment) data files, genes, and mortality
**********************************************;

data inchianti_base;
merge genes.DBP genes.klothogenes disb.adju_ana vit.ana_raw assayb.labo_raw drugb.fmc_ana medb.cli_rawe physb.per_ana physb.per_rawe interb.int_rawe nutrb.alim_raw nutrb.nutr_raw nutrb.epic_raw qctb.pqct_raw ekgb.mar_raw;
by code98 ;
run;


**********************************************
* merging follow-up data files
**********************************************;

*fu1;
data inchianti_f1;
merge disf1.adjf1ana assayf1.labf1raw klotho.klotho  medf1.clf1rawe physf1.pef1_ana physf1.pef1rawe interf1.inf1rawe nutrf1.alif1raw nutrf1.nutf1raw nutrf1.epif1raw qctf1.pqcf1raw ekgf1.marf1raw;
by code98;
run;


data ids;
set inchianti_base;
keep CODE98;
run;


***************************************************************
* r1:
* Baseline data: Baseline versions of gait speed and other 
*                outcomes of interest
***************************************************************;
data r1;
set inchianti_base;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 0;

*falls in past 12 mo;
FALL = ix15_v1;

*number of falls in past 12 mo;
NUMFALLS= ix15_v3;
if FALL=0 then NUMFALLS=0;

*self-reported walking disability 400m;
MOBDIS =(IX17_V19>1);
if IX17_V19=. then MOBDIS=.;

*self-reported unable to walk 400m;
MOBDISUN = (IX17_V19=5);
if IX17_V19=. then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =(IX6_V24>1);
if IX6_V24=. then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN = (IX6_V24=4);
if IX6_V24=. then ADLSTEPSUN=.;

*self-reported bathing disability;
ADLBATHE =(IX6_V70 in (2,3,4) );
if IX6_V70 in (.,99) then ADLBATHE=.;

*self-reported disability dressing;
ADLDRESS =(IX6_V81>1);
if IX6_V81=. then ADLDRESS=.;

*self-reported transfering disability (bed/chair);
ADLTRANSFER =(IX6_V126>1);
if IX6_V126=. then ADLTRANSFER=.;

*self-reported toileting disability;
ADLTOILET =(IX6_V114>1);
if IX6_V114=. then ADLTOILET=.;

*self-reported light housework disability;
ADLLTHOUSWK =(IX6_V138 in (2,3,4) );
if IX6_V138 in (.,99) then ADLLTHOUSWK=.;

*self-reported shopping disability;
IADLSHOP =(IX6_V47 in (2,3,4) );
if IX6_V47 in (.,99) then IADLSHOP=.;

*self-reported meal prep disability;
IADLMEAL =(IX6_V103 in (2,3,4) );
if IX6_V103 in (.,99) then IADLMEAL=.;

*self-reported heavy housework disability;
IADLHVHOUSWK =(IX7_V1 in (2,3,4) );
if IX7_V1 in (.,99) then IADLHVHOUSWK=.;

*self-reported traveling disability;
IADLTRAVEL =(IX7_V92 in (2,3,4) );
if IX7_V92 in (.,99) then IADLTRAVEL=.;

*self-reported taking meds disability;
IADLMEDS =(IX7_V104 in (2,3,4) );
if IX7_V104 in (.,99) then IADLMEDS=.;

*self-reported managing money disability;
IADLMONEY =(IX7_V115 in (2,3,4) );
if IX7_V115 in (.,99) then IADLMONEY=.;

*chair stands (time to perform 5 chair stands);
CHAIRTIME = PX3_V25;

*knee extension strength with dynamometer (kg);
KNEEXT = PXKNEEXT;

*4m gait speed (m/sec);
GTSPEED4M = PXWSPD1A;  /*note: just first walk*/

*grip strength (kg);
MAXGRIP = max(PXHGMAXR, PXHGMAXL);

*Leg CT BMD measures;
BMDTRAB4CT = XBMDT_4;  /* trabecular 4% tibia */
BMDCORT38CT = XCSAC_38; /* cortical 38% tibia */
BMDTOT4CT = XBMD_4;     /* total 4% tibia */
BMDTOT38CT = XBMD_38;   /* total 38% tibia */

*adjudicated hip fractures;
HIPFRACTURE = AXFFEMOR;

*interview date;
VISITDATE = IXDATE;

FOLLOWUPTIME=0;

keep CODE98 YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK  IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME kneeXT GTSPEED4M MAXGRIP BMDTRAB4CT BMDCORT38CT BMDTOT4CT BMDTOT38CT
HIPFRACTURE FOLLOWUPTIME; 

run;

proc sort data=r1;
by CODE98;
run;


data r1date;
set r1;
R1VISITDATE=VISITDATE;
keep CODE98 R1VISITDATE;
run;

proc sort data=r1date;
by CODE98;
run;


**********************************************
* using data from fu1 (Year 3) 
* for follow-up (fu1)
**********************************************;

data fu1;
merge inchianti_f1 ids r1date;
by CODE98;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 3;

*falls in past 12 mo;
FALL = (iy15_v1=1);
if iy15_v1=. then FALL=.;

*number of falls in past 12 mo;
NUMFALLS= (iy15_v3);
if FALL=0 then NUMFALLS=0;

*self-reported walking disability 400m;
MOBDIS =(IX17_V19>1);
if IX17_V19=. then MOBDIS=.;

*self-reported unable to walk 400m;
MOBDISUN = (Iy17_V19=5);
if Iy17_V19=. then MOBDISUN=.;

*self-reported stair climb disability (10 steps);
ADLSTEPS =(Iy6_V24>1);
if Iy6_V24=. then ADLSTEPS=.;

*self-reported unable to climb 10 steps;
ADLSTEPSUN = (Iy6_V24=4);
if Iy6_V24=. then ADLSTEPSUN=.;

*self-reported bathing disability;
ADLBATHE =(Iy6_V70 in (2,3,4) );
if Iy6_V70 in (.,99) then ADLBATHE=.;

*self-reported disability dressing;
ADLDRESS =(Iy6_V81>1);
if Iy6_V81=. then ADLDRESS=.;

*self-reported transfering disability (bed/chair);
ADLTRANSFER =(Iy6_V126>1);
if Iy6_V126=. then ADLTRANSFER=.;

*self-reported toileting disability;
ADLTOILET =(Iy6_V114>1);
if Iy6_V114=. then ADLTOILET=.;

*self-reported light housework disability;
ADLLTHOUSWK =(Iy6_V138 in (2,3,4) );
if Iy6_V138 in (.,99) then ADLLTHOUSWK=.;

*self-reported shopping disability;
IADLSHOP =(Iy6_V47 in (2,3,4) );
if Iy6_V47 in (.,99) then IADLSHOP=.;

*self-reported meal prep disability;
IADLMEAL =(Iy6_V103 in (2,3,4) );
if Iy6_V103 in (.,99) then IADLMEAL=.;

*self-reported heavy housework disability;
IADLHVHOUSWK =(Iy7_V1 in (2,3,4) );
if Iy7_V1 in (.,99) then IADLHVHOUSWK=.;

*self-reported traveling disability;
IADLTRAVEL =(Iy7_V92 in (2,3,4) );
if Iy7_V92 in (.,99) then IADLTRAVEL=.;

*self-reported taking meds disability;
IADLMEDS =(Iy7_V104 in (2,3,4) );
if Iy7_V104 in (.,99) then IADLMEDS=.;

*self-reported managing money disability;
IADLMONEY =(Iy7_V115 in (2,3,4) );
if Iy7_V115 in (.,99) then IADLMONEY=.;

*chair stands (time to perform 5 chair stands);
CHAIRTIME = Py3_V25;

*knee ext strength with dynamometer (kg);
kneext = PyKNEEXT;

*4m gait speed (m/sec);
GTSPEED4M = PyWSPD1A;  /*note: just first walk*/

*grip strength (kg);
MAXGRIP = max(PyHGMAXR, PyHGMAXL);

*Leg CT BMD measures;
BMDTRAB4CT = YBMDT_4;  /* trabecular 4% tibia */
BMDCORT38CT = YCSAC_38; /* cortical 38% tibia */
BMDTOT4CT = YBMD_4;     /* total 4% tibia */
BMDTOT38CT = YBMD_38;   /* total 38% tibia */

*adjudicated hip fractures;
HIPFRACTURE = (AYFFEMOR=1); /*new fracture, not one at baseline*/
if AYFFEMOR=. then HIPFRACTURE=.;

*interview date;
VISITDATE = IYDATE;

FOLLOWUPTIME = VISITDATE-R1VISITDATE;

keep CODE98 YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDTRAB4CT BMDCORT38CT BMDTOT4CT BMDTOT38CT
HIPFRACTURE FOLLOWUPTIME;
run;

proc sort data=fu1;
by CODE98;
run;

***************************************************************
* r1pred:
* Baseline data: exposure and covariates for adustment
* Mortality: Time to death or loss to follow-up (censoring)
***************************************************************;

data r1pred;
set inchianti_base;

*************************************
*EXPOSURE and BIOMARKER COVARIATES
*************************************;

*25(OH)D vitamin D;
SERUMVITD = X_25OH_D; /* in nmol/mL */

*serum calcium;
SERUMCALCIUM = X_CA; /* in mg/dL */

*PTH;
PTH = X_PTH; /* intact in pg/mL */

*alkaline phosphatase;
ALK = X_PALK; /* in U/L */

*serum creatinine (mg/dL);
SCREA = x_crea;

***************
* DEMOGRAPHICS
***************;

AGE = ixage;

FEMALE = (sex=2);

WHITE = 1;

*marital status;
CUMARRIED = (IX1_V23=2);
NEMARRIED = (IX1_V23=1);
FOMARRIED = (IX1_V23 in (3,4,5,6));
if IX1_V23=. then do;
CUMARRIED =.; NEMARRIED = .; FOMARRIED =.;
end;

**education (HS grad, yes=1); 
*(IX1_V26: 0=nothing, 1=elem, 2=second, 3=HS, 4=prof, 5=university, 8=undoc);
EDU = (IX1_V26>=3);
if IX1_V26 in (.,999,8) then edu=.;

***************
* LIFESTYLE
***************;

*calcium intake (mg/d);
CALCIUMFOOD = XVN25;

*phosphorus intake (mg/d);
PHOSFOOD = XVN28;

*protein intake (g/d);
PROTEINFOOD = XVN3;

*dairy intake (servings/day);
DAIRYINTAKE = sum(XF0501, XF0503, XF0505);

*vitamin D intake (mcg/d);
VITDFOOD = XVN40;

*alcohol intake (drink/d);
ALCINTAKE =sum(xf1401,xf1402,xf1403,xf1404);

*Smoking (current, former, never);
CURSMOKE = (IXFUMA=2);
FORMSMOKE = (IXFUMA=1);
if IXFUMA=. then do;
CURSMOKE=.; FORMSMOKE=.;
end;

**physical activity;
*2 = highly active (mod/vig activity>3 hrs/wk); 
*1 = moderately active (mod/vig acitivity 1-3 hrs/wk or light activity >= 1-3 hrs/wk);
PHYSACT = 0*(Ix14_V26<=2) + 1*(Ix14_V26>2 & Ix14_V26<5) + 2*(Ix14_V26>=5);
if Ix14_v26>7 then PHYSACT=.;


*******************
* Health Conditions
*******************;

**CHF;
*self report and diuretic and at least one of angiotensin, ace inhibitor, or glykosides;
CHF= (
(VX5_V54=1) & (FX1_C3=1 | FX1_C13=1) &
((FX1_C2=1 |FX1_C4=1) | FX1_C11=1)
);

**angina;
*self report and nitrates;
ANGINA = (
(VX11_V5=1) & (FX1_C10=1)
);

*systolic BP;
SYSBP=mean(VX23_V23,VX23_V25);

**hypertension (self report, drugs, BP);
*SBP > 140 mmHg or self-report and at least one of 
*1) angiotensin, 2) diuretic, 3) ace inhibitor, calcium blocker, beta blocker, or htn med;
HYPERT=(
(SYSBP >140) |
(
(VX10_V11=1) & 
(
(FX1_C2=1) | (FX1_C3=1) |
(FX1_C4=1) | (FX1_C5=1) | (FX1_C6=1) |  (FX1_C9=1) | (FX1_C13=1) 
)
)
);

*diastolic BP;
DIABP=mean(VX23_V24,VX23_V26);

*Myocardial infarction (self report);
MI = (VX11_V1=1);

*diabetes;
*self report, hypoglycemia meds, or insulin;
DIABETES = (
(VX9_V18=1) | (FX1_A9=1) | (FX1_A10=1)
);

*blood glucose (mg/dL);
GLUCOSE=X_GLU;

*stroke (self report);
STROKE = (VX12_V32=1);

**arthritis;
*knee arthritis (adjudicated);
KNEEARTH = (AXGONART>0);
if AXGONART=. then KNEEARTH=.;
*hip arthritis (adjudicated);
HIPARTH = (AXANCART>0);
if AXANCART=. then HIPARTH=.;

*baseline hip fracture for time-invariant variable (self-report);
BASEHIPFRACTURE = (VX18_V1=1);

*cancer (adjudicated);
CANCER = axcancer;

**lung conditions;
*Emphysema (self report);
EMPH = (axbpco=1);
if axbpco=. then EMPH=.;
*Asthma (self report);
ASTHMA = (axASTHMA=1);
if axASTHMA=. then ASTHMA=.;

**baseline osteoporosis;
*T-SCORE from CT;
TSCORE = XFBMD4;
if SEX=1 then TSCORE = XMBMD4;

*T-score < -2.5 or osteoporosis meds;
BASEOSTEO = (TSCORE < -2.5 & TSCORE>.) | (FX1_H3=1) | (FX1_M6=1);

*******************
* Other Measures;
*******************;

*BMI (kg/m^2);
BMI = PxBMI;

*Cognition (MMSE);
MMSE = IxMMSECO;

*depressive symptoms (CES-D Score);
CESD = IxCESD_T;

*self-rated health (self report);
SRHEALTH = IX8_V1;
if IX8_V1=9 then SRHEALTH=.;
SRHEALTH = SRHEALTH - 1; *from 1 to 5 variable to 0 to 4 variable;
if SRHEALTH = 0 then SRHEALTH = 1; *from 0 to 4 variable to 1 to 4 variable. Combined very poor with poor.

*study site;
if SITE=1 then STUDYSITE="GREVE";
else if SITE=2 then STUDYSITE="BAGNO A RIPOLI";

*baseline interview date;
BASEVISITDATE = IXDATE;

*month of visit;
MONTH = month(BASEVISITDATE);

*mortality;
DEATHDATE = DATA_MOR; /*missing if alive*/
LASTOBSDATE = DATA_ULT; /*values for censored and alive*/

DEAD = (DEATHDATE >.);
TIMEENROLLTODEATH = DEATHDATE - BASEVISITDATE;  /* #days from baseline until death*/
if DEATHDATE=. then TIMEENROLLTODEATH = LASTOBSDATE - BASEVISITDATE; 
TIMEENROLLTOBASE=0; *enrollment = baseline here;
TIMEBASETODEATH = TIMEENROLLTODEATH; *enrollment=baseline;
FOLLOWDATE = max(DEATHDATE, LASTOBSDATE);


keep CODE98 BASEVISITDATE SERUMVITD SERUMCALCIUM PTH ALK AGE FEMALE WHITE CUMARRIED NEMARRIED FOMARRIED EDU CALCIUMFOOD PHOSFOOD PROTEINFOOD DAIRYINTAKE VITDFOOD
 ALCINTAKE DIABP SYSBP CURSMOKE FORMSMOKE PHYSACT CHF ANGINA HYPERT MI DIABETES STROKE KNEEARTH HIPARTH BASEHIPFRACTURE CANCER EMPH ASTHMA
 BASEOSTEO BMI MMSE CESD GLUCOSE SCREA SRHEALTH MONTH STUDYSITE RS4588 RS7041 RS9536314 RS9527025 DEAD TIMEENROLLTODEATH TIMEENROLLTOBASE TIMEBASETODEATH FOLLOWDATE;

run;


proc sort data=r1pred;
by CODE98;
run;

*predictors at follow-up;
data fu1pred;
merge inchianti_f1 ids;
by CODE98;

PLASMAKLOTHO=klotho;

keep CODE98 PLASMAKLOTHO;
run;

proc sort data=fu1pred;
by CODE98;
run;


***************************************************************
* long:
* appending fu1 to r1
***************************************************************;

data long;
set r1 fu1;
run;

proc sort data=long;
by CODE98 YEAR;
run;

* combining longitudinal function outcomes with baseline exposure and covariates;
data long2;
merge long r1pred;
by CODE98;
run;

* combining longitudinal function outcomes and baseline exposure and covariates with fu1 exposure;
data long3;
merge long2 fu1pred;
by CODE98;

STUDY="INCH";
NEWID = cats(STUDY,put(CODE98 , BEST12.)) ;
run;

proc sort data=long3;
by CODE98 YEAR;
run;

data "INCHIANTI_VITDTARGETS2";
set long3;
run;
