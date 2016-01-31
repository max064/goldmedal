/**
	This query finds the average GPA for students taking into consideration different programs.

	FILTER:
		- Only degree programs
		- Only graduated students
*/

SELECT PIDM,  SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, ROUND( AVG(GradePoints) , 2) AS GPA
FROM 
(
	SELECT SHRTCKG_PIDM AS PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) AS Course, MAX(SHRGRDE_QUALITY_POINTS) AS GradePoints
	FROM SHRTCKN, SHRTCKG, SHRGRDE, SHRTCKL, SHRTCKD, SHRDGMR
	WHERE SHRTCKG_PIDM = SHRTCKN_PIDM -- link student registration to grades, by student
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
	AND SHRTCKD_PIDM = SHRTCKN_PIDM
	AND SHRTCKD_TERM_CODE = SHRTCKN_TERM_CODE
	AND SHRTCKD_TCKN_SEQ_NO = SHRTCKN_SEQ_NO
	AND SHRTCKD_DGMR_SEQ_NO = SHRDGMR_SEQ_NO
	AND SHRDGMR_PIDM = SHRTCKN_PIDM
	AND SHRDGMR_LEVL_CODE = 'DG' -- filter by degree of program
	AND to_char(SHRDGMR_GRAD_DATE,'YYYY') = '2015' -- filter by year of graduation
	GROUP BY SHRTCKG_PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB)
	ORDER BY SHRDGMR_SEQ_NO
) pointsTable
GROUP BY PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE
HAVING AVG(GradePoints) > 4 -- filter by a threshold GPA
ORDER BY SHRDGMR_DEGC_CODE, GPA
;
