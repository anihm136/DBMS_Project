SELECT JOB_LOCATION, JOB_DESCRIPTION, COUNT(CANDIDATE_ID) AS NUM_CANDIDATES FROM DBMS.DBMS_Mysql.CANDIDATE AS (CANDIDATE JOIN JOB_DETAILS ON CANDIDATE.CANDIDATE_ROLE=JOB_DETAILS.JOB_ID) JOIN JOB_ROLE ON JOB_ROLE.JOB_TITLE=JOB_DETAILS.JOB_TITLE GROUP BY JOB_LOCATION;
