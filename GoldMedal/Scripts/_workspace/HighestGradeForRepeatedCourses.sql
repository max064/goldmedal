/**
	DRILL DOWN REPORT

	This query finds the highest grade and gpa to be awarded to a student if the student has attempted a course multiple times.

	FIELD(s):
		- Matching repeated courses via COURSE CODES (concatenating discipline and course level code)

	Note(s):
		- Extracting the Grade Points from the most recent effective date BEFORE course completion
*/

-- Working Version (Termcode and Grade not shown)
SELECT SHRTCKG_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) AS Course, MAX(SHRGRDE_QUALITY_POINTS)
FROM SHRTCKN, SHRTCKG, SHRGRDE, SHRTCKL 
WHERE SHRTCKG_PIDM=SHRTCKN_PIDM -- link student registration to grades, by student
AND  SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE -- link student registration to grades, by term
AND SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO  -- link student registration to grades, by sequence number
AND SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL -- link the grade codes
AND SHRGRDE_TERM_CODE_EFFECTIVE = (
										SELECT MAX(SHRGRDE_TERM_CODE_EFFECTIVE) 
										FROM SHRGRDE 
										WHERE SHRGRDE_TERM_CODE_EFFECTIVE <= SHRTCKN_TERM_CODE -- get the most recent term code for grade points before course attempt
										AND SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL
									) -- find the effective points
AND SHRGRDE_LEVL_CODE = SHRTCKL_LEVL_CODE -- make sure you get the correct level of the gpa as per the course/programme
AND SHRTCKG_PIDM = SHRTCKL_PIDM -- link to the course level information, by student
AND SHRTCKG_TERM_CODE = SHRTCKL_TERM_CODE -- link to the course level information, by term
AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO -- link to the course level information, by sequence number
GROUP BY SHRTCKG_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB)
;








-- FIND the repeats of course reg -- WITH GROUP BY (UNNECESSARY)
SELECT SHRTCKG_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB), SHRGRDE_QUALITY_POINTS, COUNT(CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB))
FROM SHRTCKN, SHRTCKG, SHRGRDE, SHRTCKL
WHERE SHRTCKG_PIDM=SHRTCKN_PIDM -- link student registration to grades, by student
AND  SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE -- link student registration to grades, by term
AND SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO  -- link student registration to grades, by sequence number
AND SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL -- link the grade codes
AND SHRGRDE_TERM_CODE_EFFECTIVE = (
										SELECT MAX(SHRGRDE_TERM_CODE_EFFECTIVE) 
										FROM SHRGRDE 
										WHERE SHRGRDE_TERM_CODE_EFFECTIVE <= SHRTCKN_TERM_CODE -- get the most recent term code for grade points before course attempt
										AND SHRGRDE_LEVL_CODE = SHRTCKL_LEVL_CODE -- make sure you get the correct level of the gpa as per the course/programme
									) -- find the effective points
AND SHRTCKG_PIDM = SHRTCKL_PIDM -- link to the course level information, by student
AND SHRTCKG_TERM_CODE = SHRTCKL_TERM_CODE -- link to the course level information, by term
AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO -- link to the course level information, by sequence number
GROUP BY SHRTCKG_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB), SHRGRDE_QUALITY_POINTS
HAVING COUNT(CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB))>1;


-- FIND the repeats of course reg
SELECT SHRTCKG_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) AS Course, SHRTCKG_TERM_CODE, SHRGRDE_CODE, SHRGRDE_QUALITY_POINTS
FROM SHRTCKN, SHRTCKG, SHRGRDE, SHRTCKL
WHERE SHRTCKG_PIDM=SHRTCKN_PIDM -- link student registration to grades, by student
AND  SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE -- link student registration to grades, by term
AND SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO  -- link student registration to grades, by sequence number
AND SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL -- link the grade codes
AND SHRGRDE_TERM_CODE_EFFECTIVE = (
										SELECT MAX(SHRGRDE_TERM_CODE_EFFECTIVE) 
										FROM SHRGRDE 
										WHERE SHRGRDE_TERM_CODE_EFFECTIVE <= SHRTCKN_TERM_CODE -- get the most recent term code for grade points before course attempt
										AND SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL
									) -- find the effective points
AND SHRGRDE_LEVL_CODE = SHRTCKL_LEVL_CODE -- make sure you get the correct level of the gpa as per the course/programme
AND SHRTCKG_PIDM = SHRTCKL_PIDM -- link to the course level information, by student
AND SHRTCKG_TERM_CODE = SHRTCKL_TERM_CODE -- link to the course level information, by term
AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO -- link to the course level information, by sequence number
ORDER BY SHRTCKG_PIDM, Course, SHRTCKG_TERM_CODE
;


/** Version 2: Subquery in select clause **/
SELECT SHRTCKN_PIDM, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) As Course, SHRTCKG_TERM_CODE, SHRTCKG_GRDE_CODE_FINAL, 
	(
		SELECT SHRGRDE_QUALITY_POINTS 
		FROM SHRGRDE 
		WHERE SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL -- link the grade codes
		AND SHRGRDE_TERM_CODE_EFFECTIVE = (
												-- find the effective term
												SELECT MAX(innerGrade.SHRGRDE_TERM_CODE_EFFECTIVE) 
												FROM SHRGRDE innerGrade
												WHERE innerGrade.SHRGRDE_TERM_CODE_EFFECTIVE <= SHRTCKN_TERM_CODE -- get the most recent term code for grade points before course attempt
												AND innerGrade.SHRGRDE_CODE = SHRTCKG_GRDE_CODE_FINAL
											)
		AND SHRGRDE_LEVL_CODE = SHRTCKL_LEVL_CODE -- make sure you get the correct level of the gpa as per the course/programme
	) -- find the effective points
FROM SHRTCKN, SHRTCKG, SHRTCKL
WHERE SHRTCKG_PIDM = SHRTCKN_PIDM -- link student registration to grades, by student
AND  SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE -- link student registration to grades, by term
AND SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO  -- link student registration to grades, by sequence number
AND SHRTCKG_PIDM = SHRTCKL_PIDM -- link to the course level information, by student
AND SHRTCKG_TERM_CODE = SHRTCKL_TERM_CODE -- link to the course level information, by term
AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO -- link to the course level information, by sequence number
and SHRTCKN_PIDM IN (90000992)
ORDER BY SHRTCKG_PIDM, Course, SHRTCKG_TERM_CODE
;
