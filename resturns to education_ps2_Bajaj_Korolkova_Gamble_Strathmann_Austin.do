************* WWS508c PS1 *************
*  Spring 2018			              *
*  Author : Chris Austin              *
*  Email: chris.austin@princeton.edu  *
***************************************

/*
Credit: Somya Bajaj, Joelle Gamble, Anastasia Korolkova, Luke Strathmann, Chris Austin
Last modified by: Chris Austin
Last modified on: 2/28/18
*/

clear all

*Set directory, dta file, etc.
*cd "C:\Users\TerryMoon\Dropbox\Teaching Princeton\wws508c 2018S\ps\ps2"
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
gen white = 1 if race == 100 ;
replace white = . if race != 100 ;

gen black = 1 if
	race == 200 |
	race == 801 |
	race == 805 |
	race == 806 |
	race == 807 |
	race == 810 |
	race == 811 |
	race == 814 ;
replace black = . if
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 ;

gen other = 1 if 
	race != 100 &
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 ;
replace other = . if
	race == 100 &
	race == 200 &
	race == 801 &
	race == 805 &
	race == 806 &
	race == 807 &
	race == 810 &
	race == 811 &
	race == 814 ;

gen race3 = 1 if race == 100 ;

replace race3 = 2 if 
	race == 200 |
	race == 801 |
	race == 805 |
	race == 806 |
	race == 807 |
	race == 810 |
	race == 811 |
	race == 814 ;

replace race3 = 3 if 
	race != 100 &
	race != 200 &
	race != 801 &
	race != 805 &
	race != 806 &
	race != 807 &
	race != 810 &
	race != 811 &
	race != 814 ;
# delimit cr

label variable white "White race dummy"
label variable black "Black race dummy"
label variable other "Other race dummy"
label variable race3 "Race is W B or O"

//generate education variable for years of schooling
gen educyears = educ

#delimit ;
recode educyears
	0	=	.
	1	=	.
	2	=	1
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

label variable educyears "Number of years of education"

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
//to question(2), calculate the correlation between education and the log hourly wage.
display _b[educyears]*(educyearssd/loghourlywagesd) 


//Confirm that your calculation is correct using Stata’s corr command
corr loghourlywage educyears

// Show mathematically how the correlation coefficient relates to the regression
//coefficient and the R2
di (_b[educyears]*(educyearssd/loghourlywagesd))^2


********************************************************************************
**                                   P4                                       **
********************************************************************************
//Estimate the Mincerian Wage Equation. What is the estimated return to education?
reg loghourlywage educyears exper exper2, r

//Frisch-Waugh Theorem
reg loghourlywage exper exper2
predict u_loghourlywage, resid

reg educyears exper exper2
predict u_educyears, resid

reg u_loghourlywage u_educyears

reg loghourlywage educyears exper exper2

********************************************************************************
**                                   P5                                       **
********************************************************************************
//Estimate an “extended” Mincerian Wage Equation that controls for race and sex.
reg loghourlywage educyears exper exper2 race3 sex, r 	

********************************************************************************
**                                   P6                                       **
********************************************************************************
//summary statistics and cross tabs//

********************************************************************************
**                                   P7                                       **
********************************************************************************
//summary statistics and cross tabs//




