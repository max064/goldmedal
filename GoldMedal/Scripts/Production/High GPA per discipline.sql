DEFINE AwardYear = 2016;
DEFINE AwardYearCutoffDate = '0430';
DEFINE MinCoursesForProgramFilter = 18;
DEFINE MinCoursesForDisciplineFilter = 6;
DEFINE MinGpaFilter = 4;
DEFINE ProgramLevelFilter = 'DG';

SELECT SPRIDEN_LAST_NAME || ', ' || SPRIDEN_FIRST_NAME AS STUDENTNAME, SPRIDEN_ID, '-' AS GRADUATION_DATE, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, ROUND( AVG(GradePoints) , 2) AS GPA, COUNT(PIDM) AS NumCourses FROM 
(
	SELECT SHRTCKG_PIDM AS PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) AS Course, MAX(SHRGRDE_QUALITY_POINTS) AS GradePoints
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
	AND SHRDGMR_LEVL_CODE = '&ProgramLevelFilter' -- filter by degree programs only
	AND SHRDGMR_DEGS_CODE IN ('SO', 'CP')
	AND SHRTCKN_PIDM IN 
	(
		SELECT PIDM FROM (
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
		AND SHRDGMR_LEVL_CODE = '&ProgramLevelFilter' -- filter by degree programs only
		AND SHRDGMR_DEGS_CODE IN ('SO', 'CP')
		AND (SHRDGMR_GRAD_DATE IS NULL OR SHRDGMR_GRAD_DATE = '')
		GROUP BY SHRTCKG_PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB)
		) innerMin18
		GROUP BY PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE
		HAVING COUNT(PIDM) >= &MinCoursesForProgramFilter -- filter by a minimum requirement of completed courses
	)
	GROUP BY SHRTCKG_PIDM, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB)
) pointsTable,
SPRIDEN
WHERE SPRIDEN_PIDM = PIDM 
AND SPRIDEN_CHANGE_IND IS NULL -- to remove repeats due to name changes
GROUP BY SPRIDEN_LAST_NAME || ', ' || SPRIDEN_FIRST_NAME, SPRIDEN_ID,  '-', SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE
HAVING COUNT(PIDM) >= &MinCoursesForDisciplineFilter -- filter by a minimum requirement of completed courses for that discipline
AND AVG(GradePoints) >= &MinGpaFilter -- filter by a threshold GPA
UNION ALL
SELECT SPRIDEN_LAST_NAME || ', ' || SPRIDEN_FIRST_NAME AS STUDENTNAME, SPRIDEN_ID, TO_CHAR(SHRDGMR_GRAD_DATE, 'DD-MON-YYYY'), SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, ROUND( AVG(GradePoints) , 2) AS GPA, COUNT(PIDM)
FROM 
(
	SELECT SHRTCKG_PIDM AS PIDM, SHRDGMR_GRAD_DATE, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) AS Course, MAX(SHRGRDE_QUALITY_POINTS) AS GradePoints
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
	AND SHRDGMR_LEVL_CODE = '&ProgramLevelFilter' -- filter by degree of program
	AND SHRDGMR_GRAD_DATE >= TO_DATE( TO_CHAR(&AwardYear-1) || LPAD(&AwardYearCutoffDate,4,'0'), 'yyyymmdd') -- filter by year of graduation, from 30th April of past year=
  AND SHRDGMR_GRAD_DATE < TO_DATE( TO_CHAR(&AwardYear) || LPAD(&AwardYearCutoffDate,4,'0'), 'yyyymmdd') -- filter by year of graduation, to 30th April of this year
	GROUP BY SHRTCKG_PIDM, SHRDGMR_GRAD_DATE, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB)
	ORDER BY SHRDGMR_SEQ_NO
) pointsTable,
SPRIDEN
WHERE SPRIDEN_PIDM = PIDM
AND SPRIDEN_CHANGE_IND IS NULL -- to remove repeats due to name changes
GROUP BY SPRIDEN_LAST_NAME || ', ' || SPRIDEN_FIRST_NAME, SPRIDEN_ID, SHRDGMR_GRAD_DATE, SHRDGMR_SEQ_NO, SHRDGMR_DEGC_CODE, SHRTCKN_SUBJ_CODE
HAVING AVG(GradePoints) >= &MinGpaFilter -- filter by a threshold GPA
AND COUNT(PIDM) >= &MinCoursesForDisciplineFilter -- filter by the number of courses per discipline
ORDER BY SHRTCKN_SUBJ_CODE, GPA
;