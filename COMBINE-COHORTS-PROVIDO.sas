****************************************************************
* 03/15/19
* This program combines data from AGES, Health ABC, InCHIANTI, MrOS, and SOF 
* and defines additional harmonized variables 
****************************************************************;

options nofmterr;

libname vitd "C:\Users\shardellmd\Desktop\vitd_targets";

data all;
set vitd.AGES_vitdtargets2 vitd.habc_vitdtargetsv3 vitd.inchianti_vitdtargets2 vitd.SOF_vitdtargets3 vitd.MROS_vitdtargets2 ;

**harmonizing depressive symptoms into a dichotomous variable;
*CES-D: http://www.valueoptions.com/providers/Education_Center/Provider_Tools/Depression_Screening.pdf;
if CESD ~=.  then DEPRESSED = (CESD>16);
*GDS 15: http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1571046/;
else if GDS ~=. then DEPRESSED=(GDS>4); 
*SF-12 mental component: http://www.ncbi.nlm.nih.gov/pubmed/23796290; 
else if SF12MC~=. then DEPRESSED=(SF12MC<45); 

**harmonizing cognition into a continuous 0-1 variable;
*Proportion of max score;
*MMSE is 0-30, 3MS is 0-100;
If MMSE~=. then COGNITION=MMSE/30;
else if THREEMS then COGNITION=THREEMS/100; 

**harmonization of 25(OH)D;
*converting 25(OH)D to RIA to reflect norm of clinical labs;
*conversion equation between LC-MS/MS and RIA:;
*Chen H, McCoy LF, Schleicher RL, Pfeiffer CM. 
*Measurement of 25-hydroxyvitamin D3 (25OHD3) and 25-hydroxyvitamin D2 (25OHD2) in human serum using 
*liquid chromatography-tandem mass spectrometry and its comparison to a radioimmunoassay method. 
*Clin Chim Acta. 2008 391: 6-12.;
*note: equation in paper is based on ng/ml;
*sqrt(LC-MS/MS) = 0.9542 + 0.8621×sqrt(RIA);

*For AGES: liason -> Lc-Ms/Ms -> RIA conversion;
*conversion between liaison and LC-MS/MS from Cashman paper for AGES (in nmol/L) https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5527850/;

*converting to LC-MS/MS;
SERUMVITDLCMS= SERUMVITD;
if study in ("HABC", "INCH") then SERUMVITDLCMS=(0.9542*sqrt(2.496) + 0.8621*sqrt(SERUMVITD))**2;
if study in ("AGES") then SERUMVITDLCMS=(7.7011 + 1.0128*SERUMVITD)*(SERUMVITD<=49.2155) + 
                                        (27.3969 + 0.6125*SERUMVITD)*(SERUMVITD>49.2155); 

*converting to RIA;
SERUMVITDRIA=SERUMVITD;
if study in ("MROS", "SOF") then SERUMVITDRIA=((sqrt(SERUMVITD)-0.9542*sqrt(2.496))/0.8621)**2;
if study in ("AGES") then SERUMVITDRIA=((sqrt(SERUMVITDLCMS)-0.9542*sqrt(2.496))/0.8621)**2;

run;

*create dataset of baseline versions of outcomes;
data allbase;
set all;
if YEAR~=0 then delete;

BASEGTSPEED4M = GTSPEED4M;
BASEMOBDIS= MOBDIS;
BASEMOBDISUN = MOBDISUN;
BASEADLSTEPS= ADLSTEPS;
BASEADLSTEPSUN = ADLSTEPSUN;

keep newid study BASEGTSPEED4M BASEMOBDIS BASEMOBDISUN BASEADLSTEPS BASEADLSTEPSUN;
run;

proc sort data=allbase;
by newid;
run;

proc sort data=all;
by study newid;
run;

data all;
merge all allbase;
by study newid;
run;

data "COMBINED-PROVIDO";
set all;
run;
