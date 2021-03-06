/* Creation of the database */
CREATE DATABASE DBMS
CONTAINMENT=NONE
ON PRIMARY (CANDIDATE_NAME=N'dbms_main', FILENAME=N'/var/opt/mssql/data/dbms_primary/dbms_primary.mdf', SIZE=8192KB, FILEGROWTH=65535KB)
LOG ON (CANDIDATE_NAME=N'dbms_log', FILENAME=N'/var/opt/mssql/data/dbms_log/dbms_log.ldf', SIZE=8192KB, FILEGROWTH=65535KB)
GO

ALTER DATABASE DBMS ADD FILEGROUP FG1
ALTER DATABASE DBMS ADD FILE (CANDIDATE_NAME=N'FG1_F1', FILENAME=N'/var/opt/mssql/data/dbms_data/disk1/fg1_f1.ndf', SIZE=8192KB , FILEGROWTH=65536KB) TO FILEGROUP FG1
ALTER DATABASE DBMS ADD FILE (CANDIDATE_NAME=N'FG1_F2', FILENAME=N'/var/opt/mssql/data/dbms_data/disk2/fg1_f2.ndf', SIZE=8192KB , FILEGROWTH=65536KB) TO FILEGROUP FG1
ALTER DATABASE DBMS ADD FILEGROUP FG2
ALTER DATABASE DBMS ADD FILE (CANDIDATE_NAME=N'FG2_F1', FILENAME=N'/var/opt/mssql/data/dbms_data/disk1/fg2_f1.ndf', SIZE=8192KB , FILEGROWTH=65536KB) TO FILEGROUP FG2
ALTER DATABASE DBMS ADD FILE (CANDIDATE_NAME=N'FG2_F2', FILENAME=N'/var/opt/mssql/data/dbms_data/disk2/fg2_f2.ndf', SIZE=8192KB , FILEGROWTH=65536KB) TO FILEGROUP FG2
GO

/* Creation of the Schema (and indices) */
USE DBMS
GO

CREATE PARTITION FUNCTION PF_SMALL (INT)
AS RANGE LEFT FOR VALUES (500)
CREATE PARTITION FUNCTION PF_MED (INT)
AS RANGE LEFT FOR VALUES (10000)
CREATE PARTITION FUNCTION PF_LARGE (INT)
AS RANGE LEFT FOR VALUES (50000)

CREATE PARTITION SCHEME PS_SMALL 
AS PARTITION PF_SMALL
TO (FG1, FG2)
CREATE PARTITION SCHEME PS_MED 
AS PARTITION PF_MED
TO (FG1, FG2)
CREATE PARTITION SCHEME PS_LARGE
AS PARTITION PF_LARGE
TO (FG1, FG2)  
GO

CREATE TABLE JOB_DETAILS
(
  JOB_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  JOB_LOCATION VARCHAR(100) NOT NULL,
  JOB_TITLE VARCHAR(100) NOT NULL,
  FILLED bit NOT NULL default 'FALSE'
) ON PS_MED(JOB_ID)

CREATE TABLE JOB_ROLE
(
  JOB_TITLE VARCHAR(100) PRIMARY KEY,
  JOB_DESCRIPTION VARCHAR(8000)
) ON FG2

CREATE TABLE CANDIDATE
(
  CANDIDATE_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  CANDIDATE_STATUS VARCHAR(100) CHECK (CANDIDATE_STATUS IN ('ONGOING','REJECTED','ACCEPTED','ENTRY RECIEVED')),
  CANDIDATE_EXPERIENCE VARCHAR(100),
  CANDIDATE_NAME VARCHAR(100) NOT NULL,
  CANDIDATE_AGE INT NOT NULL,
  CANDIDATE_EDUCATION VARCHAR(8000),
  CANDIDATE_ROLE INT FOREIGN KEY REFERENCES JOB_DETAILS(JOB_ID) ON DELETE SET NULL
) ON PS_LARGE(CANDIDATE_ID)

CREATE TABLE SKILLS
(
  CANDIDATE_ID INT NOT NULL FOREIGN KEY REFERENCES CANDIDATE(CANDIDATE_ID) ON DELETE CASCADE,
  SKILL_NAME VARCHAR(100) NOT NULL,
  SKILL_LEVEL INT,
  PRIMARY KEY(CANDIDATE_ID, SKILL_NAME)
) ON PS_LARGE(CANDIDATE_ID)

CREATE TABLE EMPLOYEE
(
  EMPLOYEE_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  EMPLOYEE_NAME VARCHAR(100) NOT NULL,
  EMPLOYEE_AGE INT,
  EMPLOYEE_POSITION INT NOT NULL FOREIGN KEY REFERENCES JOB_DETAILS(JOB_ID),
  START_DATE DATE
) ON FG1

CREATE TABLE INTERVIEWER
(
  INTERVIEWER_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  EMPLOYEE_ID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES EMPLOYEE(EMPLOYEE_ID) ON DELETE CASCADE,
) ON FG1

CREATE TABLE QUESTION
(
  QUESTION_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  QUESTION_DESCRIPTION VARCHAR(100) NOT NULL,
  QUESTION_EXPLANATION VARCHAR(100),
  QUESTION_DIFFICULTY VARCHAR(8000)
) ON PS_SMALL(QUESTION_ID)

CREATE TABLE QUESTION_TAGS
(
  QUESTION_ID INT FOREIGN KEY REFERENCES QUESTION(QUESTION_ID),
  TAGS VARCHAR(100),
  PRIMARY KEY(QUESTION_ID,TAGS)
) ON FG2

CREATE TABLE INTERVIEW
(
  INTERVIEW_ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  CANDIDATE_ID INT NOT NULL FOREIGN KEY REFERENCES CANDIDATE(CANDIDATE_ID) ON DELETE CASCADE ON UPDATE CASCADE ,
  INTERVIEWER_ID INT NOT NULL FOREIGN KEY REFERENCES INTERVIEWER(INTERVIEWER_ID) ON DELETE CASCADE ON UPDATE CASCADE ,
  INTERVIEW_RESULT VARCHAR(20) CHECK(INTERVIEW_RESULT IN ('SOLVED','UNSOLVED','PARTIALLY SOLVED')),
  INTERVIEW_SCORE INT CHECK(INTERVIEW_SCORE>=0 AND INTERVIEW_SCORE<=10),
) ON PS_LARGE(INTERVIEW_ID)

CREATE TABLE MAP
(
  INTERVIEW_ID INT NOT NULL FOREIGN KEY REFERENCES INTERVIEW(INTERVIEW_ID),
  QUESTION_ID INT NOT NULL FOREIGN KEY REFERENCES QUESTION(QUESTION_ID) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY(INTERVIEW_ID,QUESTION_ID)
) ON PS_SMALL(QUESTION_ID)
GO

CREATE TRIGGER write_start_date ON EMPLOYEE AFTER INSERT AS BEGIN
  Declare @start_date date;
  Declare @id1 VARCHAR(100);
  select @id1=i.EMPLOYEE_ID
  from inserted i;
  select @start_date=i.START_DATE
  from inserted i;
  IF(@start_date IS NULL) BEGIN
    UPDATE EMPLOYEE
        SET START_DATE=GETDATE()
        WHERE EMPLOYEE_ID=@id1;
  END
END
GO

CREATE TRIGGER make_status ON CANDIDATE AFTER INSERT AS BEGIN
  Declare @status VARCHAR(100);
  Declare @id VARCHAR(100);
  select @id = i.CANDIDATE_ID
  from inserted i;
  select @status=i.CANDIDATE_STATUS
  from inserted i;
  IF(@status IS NULL) BEGIN
    UPDATE CANDIDATE
          SET CANDIDATE_STATUS='entry recieved'
          WHERE CANDIDATE_ID=@id;
  END
END
GO

CREATE TRIGGER make_employee ON CANDIDATE AFTER UPDATE AS BEGIN
  Declare @status VARCHAR(10);
  Declare @AGE INT;
  Declare @NAME VARCHAR(100);
  Declare @POSITION VARCHAR(15);
  Declare @JOB_ID VARCHAR(100);
  select @status=i.CANDIDATE_STATUS
  from inserted i;
  select @AGE=i.CANDIDATE_AGE
  from inserted i;
  select @NAME=i.CANDIDATE_NAME
  from inserted i;
  select @POSITION=i.CANDIDATE_ROLE
  from inserted i;
  IF(@status='accepted') BEGIN
    INSERT INTO EMPLOYEE
      (EMPLOYEE_NAME,EMPLOYEE_AGE,EMPLOYEE_POSITION,START_DATE)
    VALUES(@NAME, @AGE, @POSITION, GETDATE());
  END
END
GO 

CREATE INDEX LOCATION ON JOB_DETAILS(JOB_LOCATION) ON FG1;
CREATE INDEX SKID ON SKILLS(SKILL_NAME, SKILL_LEVEL) ON FG2;
CREATE INDEX QID ON MAP(QUESTION_ID) ON FG1;

DROP INDEX LOCATION ON JOB_DETAILS;
DROP INDEX SKID ON SKILLS;
DROP INDEX QID ON MAP;

/* Queries used */
SELECT COUNT(JOB_ID) AS NUMBER_OF_JOBS,JOB_LOCATION FROM JOB_DETAILS GROUP BY JOB_LOCATION;
SELECT CANDIDATE.CANDIDATE_ID,CANDIDATE_NAME,SKILL_LEVEL FROM SKILLS JOIN CANDIDATE ON CANDIDATE.CANDIDATE_ID=SKILLS.CANDIDATE_ID WHERE SKILLS.SKILL_NAME='java' AND SKILL_LEVEL>5;
SELECT INTERVIEWER.INTERVIEWER_ID, EMPLOYEE.EMPLOYEE_NAME,COUNT(CANDIDATE_ID) AS NUM_CANDIDATES_INTERVIEWED,AVG(INTERVIEW_SCORE) as AVG_CANDIDATE_SCORE, AVG(CASE WHEN QUESTION_DIFFICULTY='hard' THEN 8 WHEN QUESTION_DIFFICULTY='challenge' THEN 10 WHEN QUESTION_DIFFICULTY='medium' THEN 6 WHEN QUESTION_DIFFICULTY='easy' THEN 4 WHEN QUESTION_DIFFICULTY='beginner' THEN 2 END) AS AVG_DIFFICULTY FROM INTERVIEW JOIN INTERVIEWER ON INTERVIEW.INTERVIEWER_ID=INTERVIEWER.INTERVIEWER_ID JOIN MAP ON MAP.INTERVIEW_ID=INTERVIEW.INTERVIEW_ID JOIN QUESTION ON MAP.QUESTION_ID=QUESTION.QUESTION_ID JOIN EMPLOYEE ON INTERVIEWER.EMPLOYEE_ID=EMPLOYEE.EMPLOYEE_ID GROUP BY INTERVIEWER.INTERVIEWER_ID, EMPLOYEE.EMPLOYEE_NAME HAVING AVG(INTERVIEW_SCORE) IS NOT NULL ORDER BY INTERVIEWER.INTERVIEWER_ID ASC;
