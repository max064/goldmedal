/**
	SUPPORT ONLY
	
	This query finds the highest grade and gpa to be awarded to a student if the student has attempted a course multiple times.

	FIELD(s):
		- Matching repeated courses via COURSE CODES (concatenating discipline and course level code)

	Note(s):
		- Extracting the Grade Points from the most recent effective date BEFORE course completion
*/

SELECT SHRTCKG_PIDM, SHRTCKG_TERM_CODE, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) , SHRTCKG_GRDE_CODE_FINAL
FROM SHRTCKN, SHRTCKG 
WHERE 
SHRTCKG_PIDM=SHRTCKN_PIDM  -- LINK STUDENT REGISTRATION TO GRADES
AND  SHRTCKG_TERM_CODE = SHRTCKN_TERM_CODE -- LINK STUDENT REGISTRATION TO GRADES
AND SHRTCKG_TCKN_SEQ_NO = SHRTCKN_SEQ_NO  -- LINK STUDENT REGISTRATION TO GRADES
ORDER BY SHRTCKG_PIDM ASC, CONCAT(SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB) ASC, SHRTCKG_TERM_CODE ASC;