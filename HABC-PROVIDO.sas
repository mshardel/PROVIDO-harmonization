****************************************************************
*6/18/18
* This program creates harmonized variables in Health ABC to be merged
* with AGES, InCHIANTI, MrOS, and SOF for PROVIDO 
****************************************************************;

options nofmterr;

libname genetics 'C:\Users\shardellmd\HABC\GeneticsDatasets';

libname y1        "C:\Users\shardellmd\HABC\Year1";
libname y2        "C:\Users\shardellmd\HABC\Year2";
libname y4        "C:\Users\shardellmd\HABC\Year4";
libname y5        "C:\Users\shardellmd\HABC\Year5";
libname y6        "C:\Users\shardellmd\HABC\Year6";
libname y8        "C:\Users\shardellmd\HABC\Year8";
libname y10       "C:\Users\shardellmd\HABC\Year10";
libname y11       "C:\Users\shardellmd\HABC\Year11";
libname y12       "C:\Users\shardellmd\HABC\Year12";
libname other     "C:\Users\shardellmd\HABC\Other";


**********************************************
* using data from Year 1 (y1) and Year 2 (y2) 
* for baseline (Round 1, r1)
**********************************************;

data habc_y1;
merge y1.y1calc y1.y1clnvis y1.y1read y1.y1screen y1.y1rxcalc other.biospecimens other.ph ;
by habcid;
run;

data habc_y2;
merge y2.y2calc y2.y2clnvis  y2.klothohabc  y2.y2corehv y2.y2read y2.y2rxcalc other.biospecimens other.fracture 
other.mortality other.ph genetics.habc_genetics053118;
by habcid;
run;


data ids;
set habc_y2;
keep habcid;
run;


***************************************************************
* r1_y2:
* Baseline data: Baseline versions of gait speed and other 
*                outcomes of interest
* Baseline visit: Year 2 visit for participants (unless only
*                 measured at Year 1)
***************************************************************;


data r1_y2;
set habc_y2;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 0;

*falls in past 12 mo;
FALL = BZAJFALL; /* clinic visit */
if BZAJFALL>1 then FALL=.; /* don't know or refused */
else if BZAJFALL in (.,.A,.M) then do;
FALL=ZAAJFALL; /* home visit */
if ZAAJFALL>1 then FALL=.; /* don't know or refused */
end;
if FALL in (.M) then FALL=.; /* .M = Missing */

*number of falls in past 12 mo;
NUMFALLS= BZAJFNUM;
if FALL>0 & BZAJFNUM=. then NUMFALLS=ZAAJFNUM;
if FALL=0 then NUMFALLS=0;
if NUMFALLS=8 then NUMFALLS=.; /* don't know */
if NUMFALLS in (.M) then NUMFALLS=.; /* .M = Missing */
if NUMFALLS in (.A) then NUMFALLS=0; /* .A = Not Applicable */

** self-reported walking disability 1/4 mile;
* Clinic Visit;
MOBDIS =(BCDWQMYN in (1,9)); /* any difficulty or doesn't do */
if BCDWQMYN in (.,7,8) then MOBDIS=.; /* don't know or refused */
* Home Visit;
if MOBDIS=. then do;
MOBDIS =(ZADWQMYN in (1,9)); /* any difficulty or doesn't do */
if ZADWQMYN in (.,7,8) then MOBDIS=.; /* don't know or refused */
end;

*self-reported unable to walk 1/4 mile;
* Clinic Visit;
MOBDISUN =((BCDWQMYN in (1,9)) & (BCDWQMDF=4)); /* has difficulty and unable or doesn't do */
if ((BCDWQMDF=8) | (BCDWQMYN in (.,7,8)) ) then MOBDISUN=.; /* don't know or refused */
* Home Visit;
if MOBDISUN=. then do;
MOBDISUN =((ZADWQMYN in (1,9)) & (ZADWQMDF=4)); /* has difficulty and unable or doesn't do */
if ( (ZADWQMDF=8) | (ZADWQMYN in (.,7,8))) then MOBDISUN=.; /* don't know or refused */
end;

*self-reported stair climb disability (10 steps);
* Clinic Visit;
ADLSTEPS =( BCDW10YN in (1,9));  /* any difficulty or doesn't do */
if  BCDW10YN in (.,7,8) then ADLSTEPS=.; /* don't know or refused */
* Home Visit;
if ADLSTEPS=. then do;
ADLSTEPS =(ZADW10YN in (1,9)); /* any difficulty or doesn't do */
if ZADW10YN in (.,7,8) then ADLSTEPS=.; /* don't know or refused */
end;

*self-reported unable to climb 10 steps;
* Clinic Visit;
ADLSTEPSUN =(( BCDW10YN in (1,9)) & (BCDIF=4)); /* has difficulty and unable or doesn't do */
if  ((BCDIF=8) | (BCDW10YN in (.,7,8))) then ADLSTEPSUN =.; /* don't know or refused */
* Home Visit;
if ADLSTEPSUN=. then do;
ADLSTEPSUN =((ZADW10YN in (1,9)) & (ZADIF=4)); /* has difficulty and unable or doesn't do */
if ((ZADIF=8) | (ZADW10YN in (.,7,8))) then ADLSTEPSUN=.; /* don't know or refused */
end;

*self-reported bathing disability;
* Clinic Visit;
ADLBATHE =(BCBATHYN =1 ); /* any difficulty  */
if BCBATHYN in (.,7,8) then ADLBATHE=.; /* don't know or refused */
* Home Visit;
if ADLBATHE=. then do;
ADLBATHE =(ZABATHYN = 1); /* any difficulty  */
if ZABATHYN in (.,7,8) then ADLBATHE=.; /* don't know or refused */
end;

*self-reported disability dressing;
* Clinic Visit;
ADLDRESS =(BCDDYN=1); /* any difficulty  */
if BCDDYN in (.,7,8) then ADLDRESS=.; /* don't know or refused */
* Home Visit;
if ADLDRESS=. then do;
ADLDRESS =(ZADDYN = 1); /* any difficulty  */
if ZADDYN in (.,7,8) then ADLDRESS=.; /* don't know or refused */
end;

*self-reported transfering disability (bed/chair);
* Clinic Visit;
ADLTRANSFER =(BCDIOYN=1); /* any difficulty  */
if BCDIOYN in (.,7,8) then ADLTRANSFER=.; /* don't know or refused */
* Home Visit;
if ADLTRANSFER=. then do;
ADLTRANSFER =(ZADIOYN = 1); /* any difficulty  */
if ZADIOYN in (.,7,8) then ADLTRANSFER=.; /* don't know or refused */
end;


*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;


*self-reported shopping disability;
* Clinic Visit;
IADLSHOP =(BCDFSHOP=1); /* any difficulty  */
if BCDFSHOP in (.,7,8) then IADLSHOP=.; /* don't know or refused */
* Home Visit;
if IADLSHOP=. then do;
IADLSHOP =(ZADFSHOP = 1); /* any difficulty  */
if ZADFSHOP in (.,7,8) then IADLSHOP=.; /* don't know or refused */
end;

*self-reported meal prep disability;
* Clinic Visit;
IADLMEAL =(BCDFPREP=1); /* any difficulty  */
if BCDFPREP in (.,7,8) then IADLMEAL=.; /* don't know or refused */
* Home Visit;
if IADLMEAL=. then do;
IADLMEAL =(ZADFPREP = 1); /* any difficulty  */
if ZADFPREP in (.,7,8) then IADLMEAL=.; /* don't know or refused */
end;

*self-reported heavy housework disability;
* Clinic Visit;
IADLHVHOUSWK =(BCDIFHW=1); /* any difficulty  */
if BCDIFHW in (.,7,8) then do; /* don't know or refused */
if BCEZHW= 3 then IADLHVHOUSWK=1; /* not easy */
else if BCEZHW in (1,2) then IADLHVHOUSWK=0; /* very or somewhat easy */
else IADLHVHOUSWK=.; /* don't know or missing */
end;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIME = 5/CHR5PACE; /*from home visits only, o/w use year 1*/

*isokinetic knee ext strength (in Nm), Avg torque 80-40 deg;
KNEEXT = KCTMEAN;

*4m gait speed (m/sec);
GTSPEED4M = .;  /* from home visits only, use year 1 6m if not performed*/
if Z24MW=1 then GTSPEED4M=4/Z24MWTM1; /*if 4 meters*/
else if Z24MW=2 then GTSPEED4M=3/Z24MWTM1; /*if 3 meters*/

*grip strength (kg);
MAXGRIP = max(B3LTR1, B3LTR2,B3RTR1,B3RTR2); /* clinic visit: max of 2 trials in each hand */;
if MAXGRIP=. then MAXGRIP = max(Z2LTR1, Z2LTR2,Z2RTR1,Z2RTR2); /* home visit: max of 2 trials in each hand */;

*LEG DXA BMD;
BMDLEGDXA = mean(LLEGBMD,RLEGBMD);  /* mean of left and right */

*interview date;
VISITDATE = CV2DATE; /* clinic */
if CV2DATE=. then VISITDATE=ZADATE; /* home */
if VISITDATE in (.A) then VISITDATE=.;

*if missed visit 2, set visitdate2 as enrollment date + 365*1.25;
VISITDATE2 = VISITDATE;
if VISITDATE2=. then VISITDATE2=CV1DATE+365*1.25; /* imputed max date in follow-up window */

*Adjudicated hip fractures between visit 1 and visit 2 (~12 mo);
HIPFRACTURE = (f1frx in (11,12,13,23) & f1adjud=1 & f1frxdt<VISITDATE2) | (f2frx in (11,12,13,23) & f2adjud=1 & f2frxdt<VISITDATE2) |  
              (f3frx in (11,12,13,23) & f3adjud=1 & f3frxdt<VISITDATE2) | (f4frx in (11,12,13,23) & f4adjud=1 & f4frxdt<VISITDATE2) | 
              (f5frx in (11,12,13,23) & f5adjud=1 & f5frxdt<VISITDATE2) | (f6frx in (11,12,13,23) & f6adjud=1 & f6frxdt<VISITDATE2) |
              (f7frx in (11,12,13,23) & f7adjud=1 & f7frxdt<VISITDATE2) | (f8frx in (11,12,13,23) & f8adjud=1 & f8frxdt<VISITDATE2) | 
              (f9frx in (11,12,13,23) & f9adjud=1 & f9frxdt<VISITDATE2) ;

FOLLOWUPTIME=0;

keep HABCID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA
HIPFRACTURE FOLLOWUPTIME; 

run;


proc sort data=r1_y2;
by HABCID;
run;


**********************************************************************
* r1_y1: 
* Baseline data: Baseline versions of gait speed and other 
*                outcomes of interest that are not measured at year 2
**********************************************************************;


data r1_y1; /*some variables measured at y1, but not y2*/
set habc_y1;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIME1 = 5/CHR5PACE; 

*6m gait speed (m/sec);
GTSPEED6M = Y1UWPACE;

*total hip BMD from DXA;
BMDHIPDXA=HTOTBMD;
if HTOTBMD in (.U) then BMDHIPDXA=.;

keep HABCID CHAIRTIME1 GTSPEED6M BMDHIPDXA;
run;


proc sort data=r1_y1;
by HABCID;
run;


***************************************************************
* r1:
* All baseline data: Baseline versions of gait speed and other 
*                functional or proximal outcomes of interest
*                combined from measures in year 1 and year 2 
***************************************************************;


data r1;
merge r1_y1 r1_y2;
by HABCID;

if CHAIRTIME=. then CHAIRTIME=CHAIRTIME1;

*convert 6m gait to 4m gait using equation in Studenski JAMA 2011 paper;
if GTSPEED4M=. then GTSPEED4M  = -0.0341 + GTSPEED6M*0.9816; 
*if GTSPEED4M<0 then GTSPEED4M=0;

drop CHAIRTIME1 GTSPEED6M;
run;


**********************************************
* using data from Year 4 (y4), Year 5 (y5), and Year 6 (y6) 
* for follow-up (Round 2, r2)
**********************************************;


data habc_y4;
merge y4.y4calc y4.y4clnvis y4.y4read y4.y4corehv y4.y4proxy;
by habcid;
run;


data habc_y5;
merge y5.y5calc y5.y5clnvis y5.y5corehv y5.y5read y5.y5rxcalc y5.y5proxy other.fracture other.mortality other.ph;
by habcid;
run;


data habc_y6;
merge y6.y6calc y6.y6clnvis y6.y6corehv y6.y6read y6.y6rxcalc y6.y6proxy ;
by habcid;
run;

* to merge with follow-up data to compute time since R1 date;
data r1date;
set r1;
R1VISITDATE=VISITDATE;
keep HABCID R1VISITDATE;
run;

proc sort data=r1date;
by HABCID;
run;


***************************************************************
* r2_y5:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   Y2 is baseline, so ideal follow-up is Y5. If not measured
                   at Y5, then use Y4 or Y6 or their average if both.
***************************************************************;

data r2_y5;
merge habc_y5 r1date;
by HABCID;

*Year of wave (scheduled visit) relative to baseline as defined in this project;
YEAR = 3;

*falls in past 12 mo;
FALL = (EBAJFALL=1 | ZCAJFALL=1 |YAAJFALL=1); /* clinic or home visit or proxy */
if EBAJFALL in (.,.N) & ZCAJFALL in (.,.N) & YAAJFALL in (.,.N) then FALL=.;

*number of falls in past 12 mo;
NUMFALLS= EBAJFNUM;
if FALL>0 & EBAJFNUM=. then do;
NUMFALLS=ZCAJFNUM;
if FALL>0 & ZCAJFNUM=. then NUMFALLS=YAAJFNUM;
end;
if FALL=0 then NUMFALLS=0;
if NUMFALLS=8 then NUMFALLS=.; /* don't know */

** self-reported walking disability 1/4 mile;
* Clinic Visit;
MOBDIS =(EBDWQMYN in (1,9)); /* any difficulty or doesn't do */
if EBDWQMYN in (.,7,8) then MOBDIS=.; /* don't know or refused */
* Home Visit;
if MOBDIS=. then do;
MOBDIS =(ZCDWQMYN in (1,9)); /* any difficulty or doesn't do */
if ZCDWQMYN in (.,7,8) then MOBDIS=.; /* don't know or refused */
* Proxy;
if MOBDIS=. then do;
MOBDIS =(YADWQMYN in (1,9)); /* any difficulty or doesn't do */
if YADWQMYN in (.,7,8) then MOBDIS=.; /* don't know or refused */
end;
end;

*self-reported unable to walk 1/4 mile;
* Clinic Visit;
MOBDISUN =((EBDWQMYN in (1,9)) & (EBDWQMDF=4)); /* has difficulty and unable or doesn't do */
if ((EBDWQMDF=8) | (EBDWQMYN in (.,7,8)) ) then MOBDISUN=.; /* don't know or refused */
* Home Visit;
if MOBDISUN=. then do;
MOBDISUN =((ZCDWQMYN in (1,9)) & (ZCDWQMDF=4)); /* has difficulty and unable or doesn't do */
if ( (ZCDWQMDF=8) | (ZCDWQMYN in (.,7,8))) then MOBDISUN=.; /* don't know or refused */
* Proxy;
if MOBDISUN=. then do;
MOBDISUN =((YADWQMYN in (1,9)) & (YADWQMDF=4)); /* has difficulty and unable or doesn't do */
if ( (YADWQMDF=8) | (YADWQMYN in (.,7,8))) then MOBDISUN=.; /* don't know or refused */
end;
end;

*self-reported stair climb disability (10 steps);
* Clinic Visit;
ADLSTEPS =( EBDW10YN in (1,9)); /* any difficulty or doesn't do */
if  EBDW10YN in (.,7,8) then ADLSTEPS=.; /* don't know or refused */
* Home Visit;
if ADLSTEPS=. then do;
ADLSTEPS =(ZCDW10YN in (1,9)); /* any difficulty or doesn't do */
if ZCDW10YN in (.,7,8) then ADLSTEPS=.; /* don't know or refused */
* Proxy;
if ADLSTEPS=. then do;
ADLSTEPS =(YADW10YN in (1,9)); /* any difficulty or doesn't do */
if YADW10YN in (.,7,8) then ADLSTEPS=.; /* don't know or refused */
end;
end;

*self-reported unable to climb 10 steps;
* Clinic Visit;
ADLSTEPSUN =(( EBDW10YN in (1,9)) & (EBDIF=4)); /* has difficulty and unable or doesn't do */
if  ((EBDIF=8) | (EBDW10YN in (.,7,8))) then ADLSTEPSUN =.; /* don't know or refused */
* Home Visit;
if ADLSTEPSUN=. then do;
ADLSTEPSUN =((ZCDW10YN in (1,9)) & (ZCDIF=4)); /* has difficulty and unable or doesn't do */
if ((ZCDIF=8) | (ZCDW10YN in (.,7,8))) then ADLSTEPSUN=.; /* don't know or refused */
* Proxy;
if ADLSTEPSUN=. then do;
ADLSTEPSUN =((YADW10YN in (1,9)) & (YADIF=4)); /* has difficulty and unable or doesn't do */
if ((YADIF=8) | (YADW10YN in (.,7,8))) then ADLSTEPSUN=.; /* don't know or refused */
end;
end;

*self-reported bathing disability;
* Clinic Visit;
ADLBATHE =(EBBATHYN =1 ); /* any difficulty  */
if EBBATHYN in (.,7,8) then ADLBATHE=.; /* don't know or refused */
* Home Visit;
if ADLBATHE=. then do;
ADLBATHE =(ZCBATHYN = 1); /* any difficulty  */
if ZCBATHYN in (.,7,8) then ADLBATHE=.; /* don't know or refused */
* Proxy;
if ADLBATHE=. then do;
ADLBATHE =(YABATHYN = 1); /* any difficulty  */
if YABATHYN in (.,7,8) then ADLBATHE=.; /* don't know or refused */
end;
end;

*self-reported disability dressing;
* Clinic Visit;
ADLDRESS =(EBDDYN=1); /* any difficulty  */
if EBDDYN in (.,7,8) then ADLDRESS=.; /* don't know or refused */
* Home Visit;
if ADLDRESS=. then do;
ADLDRESS =(ZCDDYN = 1); /* any difficulty  */
if ZCDDYN in (.,7,8) then ADLDRESS=.; /* don't know or refused */
* Proxy;
if ADLDRESS=. then do;
ADLDRESS =(YADDYN = 1); /* any difficulty  */
if YADDYN in (.,7,8) then ADLDRESS=.; /* don't know or refused */
end;
end;

*self-reported transfering disability (bed/chair);
* Clinic Visit;
ADLTRANSFER =(EBDIOYN=1); /* any difficulty  */
if EBDIOYN in (.,7,8) then ADLTRANSFER=.; /* don't know or refused */
* Home Visit;
if ADLTRANSFER=. then do;
ADLTRANSFER =(ZCDIOYN = 1); /* any difficulty  */
if ZCDIOYN in (.,7,8) then ADLTRANSFER=.; /* don't know or refused */
* Proxy;
if ADLTRANSFER=. then do;
ADLTRANSFER =(YADIOYN = 1); /* any difficulty  */
if YADIOYN in (.,7,8) then ADLTRANSFER=.; /* don't know or refused */
end;
end;

*self-reported toileting disability (not assessed);
ADLTOILET =.;

*self-reported light housework disability (not assessed);
ADLLTHOUSWK =.;

*self-reported shopping disability;
* Clinic Visit;
IADLSHOP =.;
* Home Visit;
if IADLSHOP=. then do;
IADLSHOP =(ZCDFSHOP = 1); /* any difficulty  */
if ZCDFSHOP in (.,7,8) then IADLSHOP=.; /* don't know or refused */
end;

*self-reported meal prep disability;
* Clinic Visit;
IADLMEAL =.;
* Home Visit;
if IADLMEAL=. then do;
IADLMEAL =(ZCDFPREP = 1); /* any difficulty  */
if ZCDFPREP in (.,7,8) then IADLMEAL=.; /* don't know or refused */
end;

*self-reported heavy housework disability (not assessed);
IADLHVHOUSWK =.;

*self-reported traveling disability (not assessed);
IADLTRAVEL =.;

*self-reported taking meds disability (not assessed);
IADLMEDS = .;

*self-reported managing money disability (not assessed);
IADLMONEY =.;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIME = 5/CHR5PACE; /*from home visits only, o/w use mean of years 4 & 6*/

*isokinetic knee ext strength (in Nm), Avg torque 80-40 deg;
KNEEXT = .; /* use mean of years 4 and 6 */

*4m gait speed (m/sec);
GTSPEED4M = .;  /*from home visits only, use mean of years 4 and 6 6m if not performed*/
if Z44MW=1 then GTSPEED4M=4/Z44MWTM1; /*if 4 meters*/
else if Z44MW=2 then GTSPEED4M=3/Z44MWTM1; /*if 3 meters*/

*grip strength (kg);
MAXGRIP = .; /*use mean of year 4 and year 6*/
if MAXGRIP=. then MAXGRIP = max(Z4LTR1, Z4LTR2,Z4RTR1,Z4RTR2); /* home visit: max of 2 trials in each hand */

*LEG DXA BMD;
BMDLEGDXA = mean(LLEGBMD,RLEGBMD);  /* mean of left and right */

*total hip DXA BMD;
BMDHIPDXA=HTOTBMD;

*interview date;
VISITDATE = CV5DATE;

*if missed visit 5, set visitdate as enrollment date + 365*4.25;
VISITDATE2 = VISITDATE;
if VISITDATE2=. then VISITDATE2=CV1DATE+365*4.25;

*if missed visit 2 (R1), set r1visitdate as enrollment date + 365*1.25;
R1VISITDATE2 = R1VISITDATE;
if R1VISITDATE2=. then R1VISITDATE2=CV1DATE+365*1.25;

*Time from R1 to R2;
FOLLOWUPTIME = CV5DATE-R1VISITDATE2;

*Adjudicated hip fractures between visit 2 (R1) and visit 5 (R2);
HIPFRACTURE = (f1frx in (11,12,13,23) & f1adjud=1 & f1frxdt<VISITDATE2 & f1frxdt>R1VISITDATE2) | (f2frx in (11,12,13,23) & f2adjud=1 & f2frxdt<VISITDATE2 & f2frxdt>R1VISITDATE2) |  
              (f3frx in (11,12,13,23) & f3adjud=1 & f3frxdt<VISITDATE2 & f3frxdt>R1VISITDATE2) | (f4frx in (11,12,13,23) & f4adjud=1 & f4frxdt<VISITDATE2 & f4frxdt>R1VISITDATE2) | 
              (f5frx in (11,12,13,23) & f5adjud=1 & f5frxdt<VISITDATE2 & f5frxdt>R1VISITDATE2) | (f6frx in (11,12,13,23) & f6adjud=1 & f6frxdt<VISITDATE2 & f6frxdt>R1VISITDATE2) |
              (f7frx in (11,12,13,23) & f7adjud=1 & f7frxdt<VISITDATE2 & f7frxdt>R1VISITDATE2) | (f8frx in (11,12,13,23) & f8adjud=1 & f8frxdt<VISITDATE2 & f8frxdt>R1VISITDATE2) | 
              (f9frx in (11,12,13,23) & f9adjud=1 & f9frxdt<VISITDATE2 & f9frxdt>R1VISITDATE2) ;

keep HABCID YEAR VISITDATE FALL NUMFALLS MOBDIS MOBDISUN ADLSTEPS ADLSTEPSUN ADLBATHE ADLDRESS ADLTRANSFER ADLTOILET ADLLTHOUSWK IADLSHOP IADLMEAL
IADLHVHOUSWK IADLMEAL IADLTRAVEL IADLMEDS IADLMONEY CHAIRTIME KNEEXT GTSPEED4M MAXGRIP BMDLEGDXA BMDHIPDXA
HIPFRACTURE FOLLOWUPTIME;

run;


proc sort data=r2_y5;
by HABCID;
run;


***************************************************************
* r2_y4:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   Y2 is baseline, so ideal follow-up is Y5. If not measured
                   at Y5, then use Y4 or Y6 or their average if both.
***************************************************************;


data r2_y4;
set habc_y4;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIMEY4 = 5/CHR5PACE;

*6m gait speed (m/sec);
GTSPEED6MY4 = 6/SIXMWTM;

*grip strength (kg);
MAXGRIPY4 = max(D3LTR1, D3LTR2,D3RTR1,D3RTR2);

*isokinetic knee ext strength (in Nm), Avg torque 80-40 deg;
KNEEXTY4 = KCTMEAN;

keep HABCID CHAIRTIMEY4 GTSPEED6MY4 MAXGRIPY4 KNEEXTY4;
run;


proc sort data=r2_y4;
by HABCID;
run;


***************************************************************
* r2_y6:
* Follow-up data: Follow-up versions of gait speed and other 
*                outcomes of interest
* Follow-up visit: Aiming for 3 years after baseline visit for participants to be r2.
                   Y2 is baseline, so ideal follow-up is Y5. If not measured
                   at Y5, then use Y4 or Y6 or their average if both.
***************************************************************;


data r2_y6;
set habc_y6;

*chair stands (converting chair stands per second into time to perform 5 chair stands);
CHAIRTIMEY6 = 5/CHR5PACE;

*6m gait speed (m/sec);
GTSPEED6MY6 = 6/SIXMWTM;

*grip strength (kg);
MAXGRIPY6 = max(F3LTR1, F3LTR2,F3RTR1,F3RTR2);

*isokinetic knee ext strength (in Nm), Avg torque 80-40 deg;
KNEEXTY6 = KCTMEAN;

*Hip DXA BMD;
BMDHIPDXAY6 = HTOTBMD;

*shopping;
IADLSHOPY6 =(FAHSHOP in (1,2,3));
if FAHSHOP in (.,7,8) then IADLSHOPY6=.;

if IADLSHOPY6=. then do;
IADLSHOPY6 = (ZCDFSHOP=1);
if ZCDFSHOP in (.,7,8) then IADLSHOPY6 =.;
end;

*self-reported meal prep disability;
* Clinic Visit;
IADLMEALY6 =(FAHMEAL in (1,2,3) ); /* ever gets help  */
if FAHMEAL in (.,7,8) then IADLMEALY6=.; /* don't know or refused */
* Home Visit;
if IADLMEALY6=. then do;
IADLMEALY6 = (ZCDFPREP=1); /* any difficulty  */
if ZCDFPREP in (.,7,8) then IADLMEALY6 =.; /* don't know or refused */
end;

*heavy housework;
IADLHVHOUSWKY6 =(FAHHCWK in (1,2,3)); /* ever gets help  */
if FAHHCWK in (.,7,8) then IADLHVHOUSWKY6=.; /* don't know or refused */

keep HABCID IADLSHOPY6 IADLMEALY6 IADLHVHOUSWKY6 CHAIRTIMEY6 GTSPEED6MY6 MAXGRIPY6 KNEEXTY6 BMDHIPDXAY6;
run;


proc sort data=r2_y6;
by HABCID;
run;


* creating means of Y4 and Y6 vars;
data r2_y4y6;
merge r2_y4 r2_y6 other.ph;
by HABCID;

CHAIRTIMEY4Y6 = mean(CHAIRTIMEY6,CHAIRTIMEY4);

GTSPEED6MY4Y6 = mean(GTSPEED6MY6,GTSPEED6MY4);

MAXGRIPY4Y6 = mean(MAXGRIPY6,MAXGRIPY4);

KNEEXTY4Y6 = mean(KNEEXTY6,KNEEXTY4);

keep HABCID VITAL48M IADLSHOPY6 IADLMEALY6 IADLHVHOUSWKY6 BMDHIPDXAY6 CHAIRTIMEY4Y6 GTSPEED6MY4Y6 MAXGRIPY4Y6 KNEEXTY4Y6;
run;


proc sort data=r2_y5;
by HABCID;
run;


data r2;
merge r2_y5 r2_y4y6;
by HABCID;

* if alive at 48M (Y5 wave) then replace 
* unmeasured Y5 variables with mean of Y4 & Y6 or 
* just Y6 if only measured then;
if VITAL48M~=2 then do;

if IADLSHOP=. then IADLSHOP=IADLSHOPY6;
if IADLMEAL=. then IADLMEAL=IADLMEALY6;
if IADLHVHOUSWK=. then IADLHVHOUSWK=IADLHVHOUSWKY6;

if BMDHIPDXA=. then BMDHIPDXA=BMDHIPDXAY6;

if CHAIRTIME=. then CHAIRTIME=CHAIRTIMEY4Y6;
*convert 6m gait to 4m gait using equation in Studenski JAMA 2011 paper;
if GTSPEED4M = . then GTSPEED4M   = -0.0341 + GTSPEED6MY4Y6*0.9816;
if MAXGRIP=. then MAXGRIP=MAXGRIPY4Y6;
if KNEEXT=. then KNEEXT=KNEEXTY4Y6;
end; 

drop VITAL48M IADLSHOPY6 IADLMEALY6 IADLHVHOUSWKY6 BMDHIPDXAY6 CHAIRTIMEY4Y6 GTSPEED6MY4Y6 MAXGRIPY4Y6 KNEEXTY4Y6;
run;


***************************************************************
* long:
* appending r2 to r1
***************************************************************;

data long;
set r1 r2;
run;


***************************************************************
* r1_pred_y2:
* Baseline data: exposure and covariates for adustment measured at Y2
* Mortality: Time to death or loss to follow-up (censoring)
* Baseline visit: enrollment (first) visit for participants
***************************************************************;


data r1_pred_y2;
set habc_y2;

*************************************
*EXPOSURE and BIOMARKER COVARIATES
*************************************;

*25(OH)D vitamin D;
*note: measured using DiaSorin Radioimmunoassay;
SERUMVITD = VITD25OH_2*2.496; /*convert from ng/mL to nmol/mL*/

*serum calcium;
SERUMCALCIUM = SCA2; /* in mg/dL */

*PTH;
PTH = PTH2; /* intact in pg/mL */

*alkaline phosphatase (in U/L);
ALK = ALK_PHOS1;
if ALK in (.M) then ALK=.;

*bone-specific alkaline phosphatase (ng/mL);
BONEALK = SBONEALP1;

*serum phosphorus;
SERUMPHOS = S_PHOSPHRS2; /* in mg/dL */
if SERUMPHOS in (.M) then SERUMPHOS=.;

*plasma alpha-klotho;
PLASMAKLOTHO = KLOTHO2; /*in pg/mL */

*serum creatinine (mg/dL);
SCREA = CREATIN1;
if SCREA in (.M) then SCREA=.;

*serum FGF23;
FGF23=FGF23_2; /* in pg/ml */

***************
* DEMOGRAPHICS
***************;

AGE = CV2AGE;

FEMALE = (gender=2);
if gender=. then FEMALE=.;

WHITE = (race=1);
BLACK = (race~=1 & race~=.);
if race=. then do;
WHITE=.;
BLACK=.;
end;

***************
* LIFESTYLE
***************;

*calcium intake (mg/d);
CALCIUMFOOD = FFQCALC;
if CALCIUMFOOD in (.M) then CALCIUMFOOD=.;

*phosphorus intake (mg/d);
PHOSFOOD = FFQPHOS;
if PHOSFOOD in (.M) then PHOSFOOD=.;

*protein intake (g/d);
PROTEINFOOD = FFQPROT;
if PROTEINFOOD in (.M) then PROTEINFOOD=.;

*dairy intake (servings/day);
DAIRYINTAKE = FFQDRYS;
if DAIRYINTAKE in (.M) then DAIRYINTAKE=.;

*vitamin D intake (mcg/d);
VITDFOOD = FFQVITD*.025; /* converting IU to mcg */
if VITDFOOD in (.M) then VITDFOOD=.;

**alcohol intake (drink/d);
* beers/d;
*categories: 1 = <12/yr, 2 = 1-3/mo, 3 = 1/wk, 4 = 2-4/wk, 5 = 5-6/wk,
*6 = 1/d, 7 = 2-3/d, 8 = 4/d, 9 = 5+/d; 
BEERINTAKE = 0*(B2BEER=1) + 0.1*(B2BEER=2) + (1/7)*(B2BEER=3) + 
                  (3/7)*(B2BEER=4) + (5.5/7)*(B2BEER=5) + 
                  1*(B2BEER=6) + 2.5*(B2BEER=7) + 4*(B2BEER=8) + 
                  5.5*(B2BEER=9);
if B2BEER=. then BEERINTAKE=.;

* wine/d;
*categories: 1 = <12/yr, 2 = 1-3/mo, 3 = 1/wk, 4 = 2-4/wk, 5 = 5-6/wk,
*6 = 1/d, 7 = 2-3/d, 8 = 4/d, 9 = 5+/d;  
WINEINTAKE = 0*(B2WINE=1) + 0.1*(B2WINE=2) + (1/7)*(B2WINE=3) + 
                  (3/7)*(B2WINE=4) + (5.5/7)*(B2WINE=5) + 
                  1*(B2WINE=6) + 2.5*(B2WINE=7) + 4*(B2WINE=8) + 
                  5.5*(B2WINE=9);
if B2WINE=. then WINEINTAKE=.;

* shots/d;
*categories: 1 = <12/yr, 2 = 1-3/mo, 3 = 1/wk, 4 = 2-4/wk, 5 = 5-6/wk,
*6 = 1/d, 7 = 2-3/d, 8 = 4/d, 9 = 5+/d; 
SHOTINTAKE = 0*(B2SHOT=1) + 0.1*(B2SHOT=2) + (1/7)*(B2SHOT=3) + 
                  (3/7)*(B2SHOT=4) + (5.5/7)*(B2SHOT=5) + 
                  1*(B2SHOT=6) + 2.5*(B2SHOT=7) + 4*(B2SHOT=8) + 
                  5.5*(B2SHOT=9);
if B2SHOT=. then SHOTINTAKE=.;
*Alcoholic drinks/day; 
ALCINTAKE = sum(BEERINTAKE,WINEINTAKE,SHOTINTAKE);

*calcium supplements y/n; 
CALCSUP = Y2CALCM;
if CALCSUP in (.A) then CALCSUP=0;

*vitamin D supplements y/n;
VITDSUP = Y2VITD;
if VITDSUP in (.A) then VITDSUP=0;

*******************
* Other Measures;
*******************;

*BMI;
BMI = BMI;

*self-rated health (self report);
SRHEALTH = (6-BCHSTAT); /* reverse order to match other cohorts */
if BCHSTAT<0 then do;
SRHEALTH = (6-ZAHSTAT);
end;
if SRHEALTH<0 then SRHEALTH=.; 
IF SRHEALTH=5 then SRHEALTH=4; /* combining very good with excellent */

*baseline interview date;
BASEVISITDATE = CV2DATE;

*month of visit;
MONTH = MONTH(CV2DATE);

*mortality;
FOLLOWDATE = DTLASTCT; /*values for censored and alive*/

DEAD = (VSTATUS=2);
TIMEENROLLTODEATH = DTLASTCT - CV1DATE; 
TIMEENROLLTOBASE = CV2DATE - CV1DATE;
if CV2DATE in (.A) then TIMEENROLLTOBASE=365; /*note: missing refers to person who missed visit 2 (perhaps due to death)*/
TIMEBASETODEATH = TIMEENROLLTODEATH - TIMEENROLLTOBASE; /* #days from baseline (visit2) until death*/

keep HABCID BASEVISITDATE SERUMVITD SERUMCALCIUM PTH ALK BONEALK SERUMPHOS FGF23 PLASMAKLOTHO AGE FEMALE WHITE BLACK CALCIUMFOOD PHOSFOOD PROTEINFOOD DAIRYINTAKE VITDFOOD
 ALCINTAKE CALCSUP VITDSUP BMI SCREA SRHEALTH MONTH  RS7041 RS1352844 RS1491709 RS1491711
RS222014 RS222016 RS3733359 RS705117 
RS705125 RS842881 DEAD TIMEENROLLTODEATH TIMEENROLLTOBASE TIMEBASETODEATH FOLLOWDATE;

run;



data r1_pred_y1;
set habc_y1;

*************************************
*Age and BMI measured at enrollment
*************************************;
BASEAGE=CV1AGE;
BASEBMI=BMI;

***********************
* ADDITIONAL DEMOGRAPHICS
***********************;

*marital status;
CUMARRIED = (TSMARSTA=1);
NEMARRIED = (TSMARSTA in (0,5));
FOMARRIED = (TSMARSTA in (2,3,4));
if TSMARSTA in (.,7,8) then do;
CUMARRIED =.; NEMARRIED = .; FOMARRIED =.;
end;

*education (HS grad, yes=1);
*LPSCHOOL: 0=none, 1 to 12=grade 1 to grade 12, 13=voc without hi, 14=voc with hi,
15=some college, 16=college grad, 17=masters, 18=doctorate; 
EDU = (LPSCHOOL>=12);
if LPSCHOOL in (.,.D,.G,.M,.R) then edu=.;

************************
* ADDITIONAL LIFESTYLE
************************;

*Smoking (current, former, never);
CURSMOKE = (BQSCSNOW=1);
FORMSMOKE = (BQSCSNOW=0);
if BQSC100 in (.,8,7) then do;
CURSMOKE=.; FORMSMOKE=.;
end;

**physical activity;
/*convert activities to hrs/wk, then classify activities as light, moderate, or high intensity,
then categorize participants as highly active, moderately active, or sedentary */
*gardening;
GARDENTIME= FPPAKKWK/3.5; *(light activity) removing the assumed mets;

*walking for exercise;
if FPEWPACE=1 then FPEWMET=4;
else if FPEWPACE=2 then FPEWMET=3;
else if FPEWPACE=3 then FPEWMET=2;

if FPEWKKWK<0 then do;
if FPEWTIME>0 and (FPEWTIM>0 or FPEWTIM=.M) and FPEWPACE=.M then FPEWMET=3;
end;

EXWALKTIME=FPEWKKWK/FPEWMET; *light activity;

*other walking;
if FPOWPACE=1 then FPOWMET=4;
else if FPOWPACE=2 then FPOWMET=3;
else if FPOWPACE=3 then FPOWMET=2;

if FPOWKKWK<0 then do;
if FPOWTIME>0 and (FPOWTIM>0 OR FPOWTIM=.M) and FPOWPACE=.M then FPOWMET=3;
end;

OTHWALKTIME=FPOWKKWK/FPOWMET; *light activity;

*aerobics;
AEROTIME=FPACKKWK/5; *(moderate activity) removing mets;

*weight training;
WEIGHTTIME=FPTRKKWK/6; *(moderate activity) removing mets;

*1st activity intensity converted to mets;
If FPHIA1EF=1 THEN FPH1MET=4.0;
if FPHIA1EF=2 THEN FPH1MET=6.0;
if FPHIA1EF=3 THEN FPH1MET=8.0;
FPH1KKWK=FPH1MET*FPH1TIME/60; /* converting 1st activity min/wk to kilocal/wk */
*imputed missing code;
if FPH1KKWK < 0 then do;
if FPHI7DAY=1 and FPH1TIME=.M then FPH1TIME=60;
if FPHI7DAY=1 and FPH1TIME>0 and FPHIA1EF=.M then FPH1MET=6;
if FPHI7DAY=1 then FPH1KKWK=FPH1MET*FPH1TIME/60; end;

*converting 1st activity kilocal/wk to hrs/wk in light, moderate, and high-intensity (vigorous) activity;
H1HIGH=0;
H1MOD=0;
H1LIGHT=0;
if FPH1KKWK=. then do;
H1HIGH=.; H1MOD=.; H1LIGHT=.; end;

if FPH1MET=8 then H1HIGH=FPH1KKWK/FPH1MET;
else if FPH1MET=6 then H1MOD=FPH1KKWK/FPH1MET;
else if FPH1MET=4 then H1LIGHT=FPH1KKWK/FPH1MET;

*2nd activity intensity converted to mets;
IF FPHIA2EF=1 THEN FPH2MET=4.0;
if FPHIA2EF=2 THEN FPH2MET=6.0;
if FPHIA2EF=3 THEN FPH2MET=8.0;
FPH2KKWK=FPH2MET*FPH2TIME/60; /* converting 2nd activity min/wk to kilocal/wk */
if FPH2TIME=.A then FPH2KKWK=0;
*imputed missing code;
if FPH2KKWK < 0 then do;
if FPHI7DAY=1 and FPH2TIME=.M then FPH2TIME=60;
if FPHI7DAY=1 and FPH2TIME>0 and FPHIA2EF=.M then FPH2MET=6;
if FPHI7DAY=1 then FPH2KKWK=FPH2MET*FPH2TIME/60; end;

*converting 2nd activity kilocal/wk to hrs/wk in light, moderate, and high-intensity (vigorous) activity;
H2HIGH=0;
H2MOD=0;
H2LIGHT=0;
if FPH2KKWK=. then do;
H2HIGH=.; H2MOD=.; H2LIGHT=.; end;

if FPH2MET=8 then H2HIGH=FPH2KKWK/FPH2MET;
else if FPH2MET=6 then H2MOD=FPH2KKWK/FPH2MET;
else if FPH2MET=4 then H2LIGHT=FPH2KKWK/FPH2MET;

*3rd activity intensity converted to mets;
IF FPHIA3EF=1 THEN FPH3MET=4.0;
if FPHIA3EF=2 THEN FPH3MET=6.0;
if FPHIA3EF=3 THEN FPH3MET=8.0;
FPH3KKWK=FPH3MET*FPH3TIME/60; /* converting 3rd activity min/wk to kilocal/wk */
if FPH3TIME=.A then FPH3KKWK=0;
*imputed missing code;
if FPH3KKWK < 0 then do;
if FPHI7DAY=1 and FPH3TIME=.M then FPH3TIME=40;
if FPHI7DAY=1 and FPH3TIME>0 and FPHIA3EF=.M then FPH3MET=6;
if FPHI7DAY=1 then FPH3KKWK=FPH3MET*FPH3TIME/60; end;

*converting 3rd activity kilocal/wk to hrs/wk in light, moderate, and high-intensity (vigorous) activity;
H3HIGH=0;
H3MOD=0;
H3LIGHT=0;
if FPH3KKWK=. then do;
H3HIGH=.; H3MOD=.; H3LIGHT=.; end;

if FPH3MET=8 then H3HIGH=FPH3KKWK/FPH3MET;
else if FPH3MET=6 then H3MOD=FPH3KKWK/FPH3MET;
else if FPH3MET=4 then H3LIGHT=FPH3KKWK/FPH3MET;

*4th activity intensity converted to mets;
IF FPHIA4EF=1 THEN FPH4MET=4.0;
if FPHIA4EF=2 THEN FPH4MET=6.0;
if FPHIA4EF=3 THEN FPH4MET=8.0;
FPH4KKWK=FPH4MET*FPH4TIME/60; /* converting 4th activity min/wk to kilocal/wk */
if FPH4TIME=.A then FPH4KKWK=0;
*imputed missing code;
if FPH4KKWK < 0 then do;
if FPHI7DAY=1 and FPH4TIME=.M then FPH4TIME=30;
if FPHI7DAY=1 and FPH4TIME>0 and FPHIA4EF=.M then FPH4MET=6;
if FPHI7DAY=1 then FPH4KKWK=FPH4MET*FPH4TIME/60; end;

*converting 4th activity kilocal/wk to hrs/wk in light, moderate, and high-intensity (vigorous) activity;
H4HIGH=0;
H4MOD=0;
H4LIGHT=0;
if FPH4KKWK=. then do;
H4HIGH=.; H4MOD=.; H4LIGHT=.; end;

if FPH4MET=8 then H4HIGH=FPH4KKWK/FPH4MET;
else if FPH4MET=6 then H4MOD=FPH4KKWK/FPH4MET;
else if FPH4MET=4 then H4LIGHT=FPH4KKWK/FPH4MET;

*time in "moderate" activity (all considered light here);
MACTTIME=FPMIKKWK/3;

*time in light, moderate, and high-intensity (vigorous) activity;
TIMELIGHT=sum(H1LIGHT, H2LIGHT, H3LIGHT, H4LIGHT, MACTTIME, GARDENTIME,EXWALKTIME,OTHWALKTIME);
TIMEMODERATE=sum(AEROTIME, WEIGHTTIME, H1MOD, H2MOD,H3MOD,H4MOD);
TIMEHIGH=sum(H1HIGH,H2HIGH,H3HIGH,H4HIGH);

**physical activity;
*2 = highly active (mod/vig activity>3 hrs/wk); 
*1 = moderately active (mod/vig acitivity 1-3 hrs/wk or light activity >= 1-3 hrs/wk);
if TIMEHIGH>2 | TIMEMODERATE>3 then PHYSACT=2;
else if  TIMEMODERATE>1 | TIMELIGHT>2 then PHYSACT=1;
else PHYSACT=0;
if TIMELIGHT=. & TIMEMODERATE=. & TIMEHIGH=. then PHYSACT=.;

*******************
* Health Conditions
*******************;

**CHF;
*self report and diuretic and at least one of angiotensis, ace inhibitor, or glykosides;
CHF= (
(MHHCCHF=1) & (Y1CHFDIU=1) &
((Y1ANGTN2=1 |Y1ACEINH=1 | Y1HYDRLZ=1) | Y1CARGLY=1)
);
if MHHCCHF in (.)  then CHF=.;

**angina;
*self report and nitrates;
ANGINA = (
(MHHCAPCP=1) & (Y1NITRAT=1)
);
if MHHCAPCP in (.) then ANGINA=.;

**hypertension (self report, drugs, BP);
*SBP > 140 mmHg or self-report and at least one of 
*1) angiotensin, 2) diuretic, 3) ace inhibitor, calcium blocker, beta blocker, or htn med;
HYPERT=(
(SYSBP>140) |
(
(MHHCHBP=1) & 
(
(Y1ANGTN2=1) | ((Y1LOOPDI=1) | (Y1KSPARE=1)| (Y1THIAZ=1)) |
(Y1ACEINH=1) | (Y1CACHBK=1) | (Y1BETABK=1) |  (Y1HBPDRG=1)
)
)
);
if MHHCHBP in (.) then HYPERT=.;


*diastolic BP;
DIABP=DIABP;

*systolic BP;
SYSBP=SYSBP;

*Myocardial infarction (self report);
MI = (MHHCHAMI=1);
if MHHCHAMI=. then MI=.;

*diabetes;
*self report, hypoglycemia meds, or insulin;
DIABETES = (
(LBSGDIAB=1) | (Y1DIBDRG=1) | (LBSGINSU=1) | (LBSGMED=1)
);
if LBSGDIAB in (.) then DIABETES=.;

GLUCOSE = FAST8GLU2; /* mg/dL */
if FAST8GLU2 in (., .T) then GLUCOSE=.;

*stroke (self report);
STROKE = (MHHCCVA=1);
if MHHCCVA=. then STROKE=.;

**arthritis;
*knee arthritis (self report);
KNEEARTH = (PQAJKNEE=1);
if PQAJARDA=. then KNEEARTH=.;
*hip arthritis (self report);
HIPARTH = (PQAJHIP=1);
if PQAJARDA=. then HIPARTH=.;

*baseline hip fracture for time-invariant variable (self-report);
BASEHIPFRACTURE = (PQOSBRH=1);

*cancer (self report);
CANCER = (MHCHMGMT=1);

**lung conditions;
*Emphysema (self report);
EMPH = (MHLCCHBR=1 | MHLCEMPH=1);
if MHLCCHBR=. & MHLCEMPH=.  then EMPH=.;
*Asthma (self report);
ASTHMA = (MHLCASTH=1);
if MHLCASTH=. then ASTHMA=.;

**baseline osteoporosis;
*Femoral neck T-Score using means and SDs from Looker (1998);
TSCORE = (NBMD-0.858)/0.120*(RACEGEN=2) + /*white women*/ 
         (NBMD-0.934)/0.137*(RACEGEN=1) + /*white men*/
         (NBMD-1.074)/0.168*(RACEGEN=3) + /*black men*/
         (NBMD-0.950)/0.133*(RACEGEN=4) /*black women*/
;
if racegen=. then TSCORE=.;

*T-score < -2.5 or osteoporosis meds;
BASEOSTEO = (TSCORE < -2.5 & TSCORE>.) | (Y1OSTDRG=1);
if Y1OSTDRG=. then BASEOSTEO=.;


*******************
* Other Measures;
*******************;

*Cognition (Modified MMSE);
THREEMS = MMMSCORE;

*depressive symptoms (CES-D Score);
CESD = CES_D;

*site;
if SITE=1 then STUDYSITE="MEMPHIS";
else if SITE=2 then STUDYSITE="PITTSBURGH";

keep HABCID BASEAGE BASEBMI DIABP SYSBP CUMARRIED NEMARRIED FOMARRIED EDU CURSMOKE FORMSMOKE 
CHF ANGINA HYPERT MI GLUCOSE DIABETES STROKE KNEEARTH HIPARTH BASEHIPFRACTURE CANCER EMPH ASTHMA
 BASEOSTEO THREEMS CESD PHYSACT STUDYSITE;

run;

proc sort data= r1_pred_y1;
by HABCID;
run;

proc sort data= r1_pred_y2;
by HABCID;
run;

* combining exposure and covariates measured at Y1 and Y2;
data r1_pred;
merge r1_pred_y1 r1_pred_y2;
by HABCID;
run;

proc sort data=long;
by HABCID;
run;

* combining longitudinal function outcomes with baseline exposure and covariates;
data long2;
merge long r1_pred;
by HABCID;
STUDY="HABC";
NEWID = cats(STUDY,put(HABCID , BEST12.)) ;
run;

proc sort data=long2;
by HABCID YEAR;
run;

data "HABC_VITDTARGETSv3";
set long2;
run;
