/* JOB DETAILS */
/* Number of jobs in each location */
SELECT COUNT(JOB_ID) AS NUMBER_OF_JOBS,JOB_LOCATION FROM JOB_DETAILS GROUP BY JOB_LOCATION;
/* Location count for each job title */
SELECT COUNT(JOB_LOCATION) AS NUMBER_OF_LOCATIONS,JOB_TITLE FROM JOB_DETAILS GROUP BY JOB_TITLE;
/* All job details */
SELECT JOB_ID,JOB_DETAILS.JOB_TITLE,JOB_DESCRIPTION,JOB_LOCATION,FILLED FROM JOB_DETAILS JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE;
/* Job details for job id */
SELECT JOB_DETAILS.JOB_TITLE,JOB_DESCRIPTION,JOB_LOCATION,FILLED FROM JOB_DETAILS JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE WHERE JOB_ID=(?);
/* job Id */
/* Job details for location */
SELECT JOB_ID,JOB_DETAILS.JOB_TITLE,JOB_DESCRIPTION,FILLED FROM JOB_DETAILS JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE WHERE JOB_LOCATION=(?);
/* location */
/* Number of available jobs */
SELECT COUNT(*) AS NUM_VACANT FROM JOB_DETAILS WHERE FILLED=0;
/* CANDIDATES */
/* Status summary of applications */
SELECT CANDIDATE_STATUS, COUNT(CANDIDATE_STATUS) AS NUM_CANDIDATES FROM CANDIDATE GROUP BY CANDIDATE_STATUS;
/* Number of applicants per location */
SELECT JOB_LOCATION, COUNT(CANDIDATE_ID) AS NUM_CANDIDATES FROM CANDIDATE JOIN JOB_DETAILS ON CANDIDATE.CANDIDATE_ROLE=JOB_DETAILS.JOB_ID GROUP BY JOB_LOCATION;
/* Candidate details for candidate id */
SELECT CANDIDATE_NAME, CANDIDATE_AGE, CANDIDATE_EDUCATION, CANDIDATE_EXPERIENCE, CANDIDATE_STATUS, JOB_TITLE FROM CANDIDATE JOIN JOB_DETAILS ON CANDIDATE.CANDIDATE_ROLE=JOB_DETAILS.JOB_ID WHERE CANDIDATE_ID=(?);
/* candidate id */
/* Candidates by age group */
SELECT CANDIDATE_ID, CANDIDATE_NAME FROM CANDIDATE WHERE CANDIDATE_AGE BETWEEN (?) AND (?);
/* lower bound */
/* upper bound */
/* SKILLS */
/* Skills of candidate by candidate id */
SELECT CANDIDATE_NAME,SKILL_NAME,SKILL_LEVEL FROM SKILLS JOIN CANDIDATE ON CANDIDATE.CANDIDATE_ID=SKILLS.CANDIDATE_ID WHERE CANDIDATE.CANDIDATE_ID=(?);
/* candidate id */
/* Candidates with skill above specific level */
SELECT CANDIDATE.CANDIDATE_ID,CANDIDATE_NAME,SKILL_LEVEL FROM SKILLS JOIN CANDIDATE ON CANDIDATE.CANDIDATE_ID=SKILLS.CANDIDATE_ID WHERE SKILLS.SKILL_NAME='java' AND SKILL_LEVEL>5;
/* skill name */
/* minimum skill level */
/* EMPLOYEE */
/* Employee details by employee id */
SELECT EMPLOYEE_NAME,EMPLOYEE_AGE,JOB_DETAILS.JOB_ID,JOB_DETAILS.JOB_TITLE,JOB_DESCRIPTION FROM (EMPLOYEE JOIN JOB_DETAILS ON EMPLOYEE_POSITION=JOB_ID) JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE WHERE EMPLOYEE_ID=(?);
/* employee id */
/* Number of employees at different position */
SELECT JOB_DETAILS.JOB_TITLE,COUNT(*) AS NUM_EMPLOYEES FROM JOB_DETAILS JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE GROUP BY JOB_DETAILS.JOB_TITLE;
/* Employees at particular position */
SELECT EMPLOYEE_ID,EMPLOYEE_NAME FROM (EMPLOYEE JOIN JOB_DETAILS ON EMPLOYEE_POSITION=JOB_ID) JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE WHERE JOB_ROLE.JOB_TITLE=(?);
/* job title */
/* INTERVIEWER */
/* Interviewer details by interviewer id */
SELECT INTERVIEWER_ID,INTERVIEWER.EMPLOYEE_ID,EMPLOYEE_NAME,EMPLOYEE_AGE,JOB_TITLE FROM (INTERVIEWER JOIN EMPLOYEE ON INTERVIEWER.EMPLOYEE_ID=EMPLOYEE.EMPLOYEE_ID) JOIN JOB_DETAILS ON EMPLOYEE.EMPLOYEE_POSITION=JOB_DETAILS.JOB_ID WHERE INTERVIEWER_ID=(?);
/* interviewer id */
/* List of candidates interviewed by interviewer */
SELECT EMPLOYEE_NAME,INTERVIEW.CANDIDATE_ID,CANDIDATE_NAME,CANDIDATE_AGE,CANDIDATE_STATUS FROM ((INTERVIEWER JOIN EMPLOYEE ON INTERVIEWER.EMPLOYEE_ID=EMPLOYEE.EMPLOYEE_ID) JOIN INTERVIEW ON INTERVIEWER.INTERVIEWER_ID=INTERVIEW.INTERVIEW_ID) JOIN CANDIDATE ON INTERVIEW.CANDIDATE_ID=CANDIDATE.CANDIDATE_ID WHERE INTERVIEWER.INTERVIEWER_ID=(?);
/* interviewer id */
/* Distribution of question difficulties by interviewer id */
SELECT QUESTION.QUESTION_DIFFICULTY, COUNT(*) AS NUM_QUESTIONS FROM (((INTERVIEWER JOIN INTERVIEW ON INTERVIEWER.INTERVIEWER_ID=INTERVIEW.INTERVIEWER_ID) JOIN MAP ON INTERVIEW.INTERVIEW_ID=MAP.INTERVIEW_ID) JOIN QUESTION ON MAP.QUESTION_ID=QUESTION.QUESTION_ID) WHERE INTERVIEWER.INTERVIEWER_ID=(?) GROUP BY QUESTION_DIFFICULTY.QUESTION_DIFFICULTY;
/* interviewer id */
/* Number of candidates at different stages by interviewer */
SELECT INTERVIEWER.INTERVIEWER_ID, EMPLOYEE_NAME, COUNT(CANDIDATE.CANDIDATE_ID) AS NUM_CANDIDATES FROM ((INTERVIEWER JOIN EMPLOYEE ON INTERVIEWER.EMPLOYEE_ID=EMPLOYEE.EMPLOYEE_ID) JOIN INTERVIEW ON INTERVIEWER.INTERVIEWER_ID=INTERVIEW.INTERVIEWER_ID) JOIN CANDIDATE ON INTERVIEW.CANDIDATE_ID=CANDIDATE.CANDIDATE_ID WHERE CANDIDATE.CANDIDATE_STATUS=(?) GROUP BY INTERVIEWER.INTERVIEWER_ID,EMPLOYEE_NAME ORDER BY INTERVIEWER.INTERVIEWER_ID;
/* candidate status */
/* QUESTIONS */
/* View question details for question id */
SELECT QUESTION_DESCRIPTION, QUESTION_EXPLANATION, QUESTION_DIFFICULTY, TAGS FROM QUESTION JOIN QUESTION_TAGS ON QUESTION.QUESTION_ID=QUESTION_TAGS.QUESTION_ID WHERE QUESTION.QUESTION_ID=(?);
/* question id */
/* Number of questions by difficulty */
SELECT QUESTION_DIFFICULTY, COUNT(QUESTION_DIFFICULTY) AS NUM_QUESTIONS FROM QUESTION GROUP BY QUESTION_DIFFICULTY;
/* List of questions without explanations */
SELECT QUESTION_ID, QUESTION_DESCRIPTION FROM QUESTION WHERE QUESTION_EXPLANATION IS NULL;
/* INTERVIEW */
/* List interviews of candidate */
SELECT INTERVIEW_ID, INTERVIEWER_ID, INTERVIEW_SCORE, INTERVIEW_RESULT FROM INTERVIEW WHERE CANDIDATE_ID=(?);
/* candidate id */
/* List interviews of interviewer */
SELECT INTERVIEW_ID, CANDIDATE_ID, INTERVIEW_SCORE, INTERVIEW_RESULT FROM INTERVIEW WHERE INTERVIEWER_ID=(?);
/* interviewer id */
/* Scheduled (but not yet conducted) interviews */
SELECT INTERVIEW_ID, CANDIDATE_ID, INTERVIEWER_ID FROM INTERVIEW WHERE INTERVIEW_RESULT IS NULL;
/* Distribution of interview results */
SELECT INTERVIEW_RESULT, COUNT(*) AS NUM_CANDIDATES FROM INTERVIEW WHERE INTERVIEW_RESULT IS NOT NULL GROUP BY INTERVIEW_RESULT;
/* Filter candidates by average score */
SELECT CANDIDATE.CANDIDATE_ID, CANDIDATE_NAME, COUNT(INTERVIEW_ID) AS NUM_INTERVIEWS, AVG(INTERVIEW_SCORE) AS AVG_SCORE FROM CANDIDATE JOIN INTERVIEW ON CANDIDATE.CANDIDATE_ID=INTERVIEW.CANDIDATE_ID WHERE SCORE IS NOT NULL GROUP BY CANDIDATE.CANDIDATE_ID, CANDIDATE_NAME HAVING AVG(SCORE)>(?);
/* lower bound */
/* List of questions asked in interview by interview id */
SELECT QUESTION.QUESTION_ID,QUESTION.QUESTION_DESCRIPTION FROM INTERVIEW JOIN MAP ON INTERVIEW.INTERVIEW_ID=MAP.INTERVIEW_ID JOIN QUESTION ON MAP.QUESTION_ID=QUESTION.QUESTION_ID WHERE INTERVIEW.INTERVIEW_ID=(?);
/* interview id */
/* Distribution of questions asked in interviews */
SELECT MAP.QUESTION_ID, COUNT(INTERVIEW.INTERVIEW_ID) AS NUMBER_OF_INTERVIEWERS FROM INTERVIEW JOIN MAP ON INTERVIEW.INTERVIEW_ID=MAP.INTERVIEW_ID GROUP BY MAP.QUESTION_ID;
/* MAP */
/* Difficulty of interview */
SELECT INTERVIEW.INTERVIEW_ID, AVG(CASE WHEN QUESTION_DIFFICULTY='hard' THEN 8 WHEN QUESTION_DIFFICULTY='challenge' THEN 10 WHEN QUESTION_DIFFICULTY='medium' THEN 6 WHEN QUESTION_DIFFICULTY='easy' THEN 4 WHEN QUESTION_DIFFICULTY='beginner' THEN 2 END) AS DIFFICULTY_SCORE FROM (INTERVIEW JOIN MAP ON INTERVIEW.INTERVIEW_ID=MAP.INTERVIEW_ID) JOIN QUESTION ON QUESTION.QUESTION_ID=MAP.QUESTION_ID GROUP BY INTERVIEW.INTERVIEW_ID;
/* COMPLEX QUERIES */
/* Summary of candidate */
SELECT CANDIDATE_NAME,CANDIDATE_AGE,CANDIDATE_EDUCATION,SUM(CASE WHEN QUESTION_DIFFICULTY='hard' THEN 8 WHEN QUESTION_DIFFICULTY='challenge' THEN 10 WHEN QUESTION_DIFFICULTY='medium' THEN 6 WHEN QUESTION_DIFFICULTY='easy' THEN 4 WHEN QUESTION_DIFFICULTY='beginner' THEN 2 END)/COUNT(*) AS INTERVIEW_DIFFICULTY, SUM(SCORE)/COUNT(*) AS AVG_SCORE FROM ((CANDIDATE JOIN INTERVIEW ON CANDIDATE.CANDIDATE_ID=INTERVIEW.CANDIDATE_ID) JOIN MAP ON MAP.INTERVIEW_ID=INTERVIEW.INTERVIEW_ID) JOIN QUESTION ON QUESTION.QUESTION_ID=MAP.QUESTION_ID WHERE CANDIDATE.CANDIDATE_ID=(?) GROUP BY CANDIDATE_NAME, CANDIDATE_AGE, CANDIDATE_EDUCATION;
/* candidate id */
/* Summary statistics for job title */
SELECT JOB_DETAILS.JOB_TITLE,COUNT(DISTINCT JOB_DETAILS.JOB_LOCATION) AS NUM_LOCATIONS, COUNT(JOB_DETAILS.FILLED)-COUNT(CASE WHEN JOB_DETAILS.FILLED=1 THEN 1 END) AS VACANCIES from JOB_DETAILS JOIN JOB_ROLE ON JOB_DETAILS.JOB_TITLE=JOB_ROLE.JOB_TITLE GROUP BY JOB_DETAILS.JOB_TITLE;
/* Summary of interviewers */
SELECT INTERVIEWER.INTERVIEWER_ID, EMPLOYEE.EMPLOYEE_NAME,COUNT(CANDIDATE_ID) AS NUM_CANDIDATES_INTERVIEWED,AVG(INTERVIEW_SCORE) as AVG_CANDIDATE_SCORE, AVG(CASE WHEN QUESTION_DIFFICULTY='hard' THEN 8 WHEN QUESTION_DIFFICULTY='challenge' THEN 10 WHEN QUESTION_DIFFICULTY='medium' THEN 6 WHEN QUESTION_DIFFICULTY='easy' THEN 4 WHEN QUESTION_DIFFICULTY='beginner' THEN 2 END) AS AVG_DIFFICULTY FROM INTERVIEW JOIN INTERVIEWER ON INTERVIEW.INTERVIEWER_ID=INTERVIEWER.INTERVIEWER_ID JOIN MAP ON MAP.INTERVIEW_ID=INTERVIEW.INTERVIEW_ID JOIN QUESTION ON MAP.QUESTION_ID=QUESTION.QUESTION_ID JOIN EMPLOYEE ON INTERVIEWER.EMPLOYEE_ID=EMPLOYEE.EMPLOYEE_ID GROUP BY INTERVIEWER.INTERVIEWER_ID, EMPLOYEE.EMPLOYEE_NAME HAVING AVG(INTERVIEW_SCORE) IS NOT NULL ORDER BY INTERVIEWER.INTERVIEWER_ID ASC;
/* End */
