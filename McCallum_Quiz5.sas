/* Jessica McCallum 8417055 */

libname epi "Z:\EPI5143\Code";
libname ex "Z:\EPI5143\Workfolder";

/* creating dataset spine with observations from Jan 1 2003 - Dec 31 2004 */
data ex.spine;
set epi.NhrAbstracts;
by hraEncWID;
if year(datepart(hraAdmDtm)) < 2003 then delete;
if year(datepart(hraAdmDtm)) > 2004 then delete;
run;

/* confirming data does not have duplicate encwids */
proc sort data=ex.spine nodupkey;
by hraencwid;
run;

/* checking number of observations */
proc contents data=ex.spine;
run;

/* re-naming hraencwid to encwid */
proc sort data=ex.spine out=ex.spine1 (rename=hraencwid=encwid);
by hraencwid;
run;



/* sorting diabetes database by hdghraencwid */
Proc sort data=epi.nhrdiagnosis out=ex.diabetes; 
by hdghraencwid;
run;

data ex.diabetes1;
set ex.diabetes;
by hdghraencwid;
If first.hdghraencwid then do; DM=0;count=0;
end;
if hdgcd in:('250' 'E11' 'E10') then do; 
DM=1;count=count+1;end;
If last.hdghraencwid then output;
retain DM count;
run;

/*checking diabetes count before flat filing */
proc freq data=ex.diabetes1;
Tables DM count;
run;

/* re-naming hdghraencwid to encwid  */
proc sort data=ex.diabetes1 out=ex.diabetes2 (rename=hdghraencwid=encwid);
by hdghraencwid;
run;

/* creating flat file */
proc sort data=ex.diabetes2 nodupkey;
by encwid;
run;

/* checking diabetes count in ex.diabetes2 flat file to confirm it is the same*/
proc freq data=ex.diabetes2;
table DM;
run;


data ex.final;
merge ex.spine1(in=a) ex.diabetes2(in=b);
by encwid;
if a;
if b=0 then do;
DM=0;count=0;dm_count=0;
end;
run;

proc freq data=ex.final;
tables DM count;
run;


/* 	The final dataset has 2230 observations which is the same as the initial spine dataset.
   	Of the 2230 patients, 83 had a diagnosis of diabetes
	Therefore, 3.72% of admissions between January 1, 2003 and December 31, 2004 had a 
	diagnosis of diabetes   */
