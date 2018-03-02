************* WWS508c PS1 *************
*  Spring 2018			              *
*  Author : Chris Austin              *
*  Email: chris.austin@princeton.edu  *
***************************************

/*
Credit: Somya Bajaj, Joelle Gamble, Anastasia Korolkova, Luke Strathmann, Chris Austin
Last modified by: Chris Austin
Last modified on: 3/2/18
*/

clear all

*Set directory, dta file, etc.
*cd "C:\Users\TerryMoon\Dropbox\Teac=hing Princeton\wws508c 2018S\ps\ps2"
cd "C:\Users\Chris\Documents\Princeton\WWS Spring 2018\WWS 508c\PS2\DTA"

set more off
set matsize 10000
capture log close
log using PS1.log, replace

*Download outreg2
ssc install outreg2

********************************************************************************
**                                   P1                                       **
********************************************************************************
//see submitted assignment.

********************************************************************************
**                                   P2                                       **
********************************************************************************
//Run dat file//
run cps08

//generate log hourly wage
gen loghourlywage = ln(incwage / (uhrswork * wkswork1)) 
label variable loghourlywage "Log hourly wage"

//generage race dummies
#delimit ;
gen black = 1 if
	race == 200 |
	race == 801 |
	race == 805 |
	race == 806 |
	race == 807 |
	race == 810 |
	race == 811 |
	race == 814 
;
replace black = 0 if
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 
;

gen other = 1 if 
	race != 100 &
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 
;
replace other = 0 if
	race == 100 &
	race == 200 &
	race == 801 &
	race == 805 &
	race == 806 &
	race == 807 &
	race == 810 &
	race == 811 &
	race == 814 
;

gen race3 = 1 if race == 100 ;
replace race3 = 2 if 
	race == 200 |
	race == 801 |
	race == 805 |
	race == 806 |
	race == 807 |
	race == 810 |
	race == 811 |
	race == 814 
;
replace race3 = 3 if 
	race != 100 &
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 
;

label define race3_lbl
	1 White
	2 Black
	3 Other
;
# delimit cr

label variable race3 race3_lbl
label variable black "Black race dummy"
label variable other "Other race dummy"
label variable race3 "Race"

//generate education variable for years of schooling
gen educyears = educ
label variable educyears "Years of education"

#delimit ;
recode educyears
	0	=	0
	1	=	0
	2	=	.5
	10	=	2.5
	11	=	1
	12	=	2
	13	=	3
	14	=	4
	20	=	5.5
	21	=	5
	22	=	6
	30	=	7.5
	31	=	6
	32	=	8
	40	=	9
	50	=	10
	60	=	11
	70	=	12
	71	=	12
	72	=	12
	73	=	12
	80	=	13
	81	=	14.5
	90	=	14
	91	=	14
	92	=	14
	100	=	15
	110	=	16
	111	=	16
	120	=	17
	121	=	17
	122	=	18
	123	=	18
	124	=	19
	125	=	21
	999	=	.
;
#delimit cr

// generage potential experience variable
gen exper = (age - educyears - 5)
label variable exper "Potential experience"

// generate exper^2 variable
gen exper2 = exper^2
label variable exper2 "Squared potential experience"

// drop anyone who worked less than 35 hours in a typical week
//and drop anyone with missing wages or education
drop if uhrswork < 35
drop if incwage == . | educyears == .

// summarize the data
sum educyears
gen educyearssd = r(sd)
label variable educyearssd "SD educyears"
di educyearssd

sum loghourlywage
gen loghourlywagesd = r(sd)
label variable loghourlywagesd "SD loghourlywages"
di loghourlywagesd

********************************************************************************
**                                   P3                                       **
********************************************************************************
//Estimate a univariate regression of the log hourly wage on education.
reg loghourlywage educyears, r

//Based on your regression coefficient and the summary statistics in your answer 
//to question(2), calculate the correlation between education and the log hourly 
//wage.
di _b[educyears]*(educyearssd/loghourlywagesd)


//Confirm that your calculation is correct using Stata’s corr command
corr loghourlywage educyears

// Show mathematically how the correlation coefficient relates to the regression
//coefficient and the R2
di (_b[educyears]*(educyearssd/loghourlywagesd))^2


********************************************************************************
**                                   P4                                       **
********************************************************************************
//Estimate the Mincerian Wage Equation. What is the estimated return to
//education?
reg loghourlywage educyears exper exper2, r
outreg2 using PS2_Outreg.xls, ctitle (CPS Short) replace label

//Frisch-Waugh Theorem
reg loghourlywage exper exper2
predict u_loghourlywage, resid

reg educyears exper exper2
predict u_educyears, resid

reg u_loghourlywage u_educyears
outreg2 using PS2_Frish-Waugh.xls, ctitle (CPS Short) replace label

reg loghourlywage educyears exper exper2
outreg2 using PS2_Frish-Waugh.xls, ctitle (CPS Short) append label

********************************************************************************
**                                   P5                                       **
********************************************************************************
//Estimate an “extended” Mincerian Wage Equation that controls for race and sex.
local controls race3 sex

reg loghourlywage educyears exper exper2 `controls', r 	
outreg2 using PS2_Outreg.xls, ctitle(CPS Extended) addtext(Race and Sex Controls,X)append label

********************************************************************************
**                                   P6                                       **
********************************************************************************
//Based on the “extended” regression specification, plot the estimated 
//wage-experience profile, holding education, sex, and race constant at their 
// sample averages.

sort exper

twoway (fpfit loghourlywage exper2), ytitle(Wage-experience profile) by(race3 sex)

save returnstoeduc_ps2_updated.dta, replace

********************************************************************************
**                                   P7                                       **
********************************************************************************
//run NLSY data.
use nlsy79

label variable educ "Years of education"
label variable male "Sex"

//Generate a log hourly wage variable and a “potential experience” variable.
gen loghourlywage = ln(laborinc07 / hours07) 
label variable loghourlywage "Log hourly wage"

//Drop anyone who worked less than 35 hrs/week for 50 weeks.
drop if hours07 < (35*50)

//Summarize the data.
sum loghourlywage

********************************************************************************
**                                   P8                                       **
********************************************************************************
//Estimate an extended Mincerian Wage Equation with controls for race/ethnicity 
// and sex.
gen age07 = (age79 + 28)

// generage potential experience variable
gen exper = (age07 - educ - 5)
label variable exper "Potential experience"

// generate exper^2 variable
gen exper2 = exper^2
label variable exper2 "Squared potential experience"

//Estimate an “extended” Mincerian Wage Equation that controls for race and sex.
local controls black hisp male

reg loghourlywage educ exper exper2 `controls', r
outreg2 using PS2_Outreg.xls, ctitle(NSLY Extended) addtext(Race and Sex Controls,X)append label 	

//How do your estimates of the return to education and the return to experience 
//compare to the estimates from the CPS? If there are differences, hypothesize 
//why.

********************************************************************************
**                                   P9                                       **
********************************************************************************
//See submitted assignment.


********************************************************************************
**                                   P10                                      **
********************************************************************************
//Do you think any of these variables (cognitive test scores and childhood 
//environment) would be appropriate as control variables in the Mincerian Wage 
//Equation? If so, re-estimate the equation, controlling for race/ethnicity, 
//sex, and any other variables as you see appropriate.

local backgroundcontrols foreign urban14 mag14 news14 lib14 educ_mom educ_dad numsibs

//What happens to the estimated return to education? Interpret any changes you 
//observe.

reg loghourlywage educ exper exper2 `controls' `backgroundcontrols', r
outreg2 using PS2_Outreg.xls, ctitle(NSLY Extended) addtext(Race and Sex Controls,X, Background Controls,X)append label 


********************************************************************************
**                                   P11                                      **
********************************************************************************
//See submitted assignment.



