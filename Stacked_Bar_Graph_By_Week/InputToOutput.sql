DROP TABLE IF EXISTS BP
; 
CREATE TABLE BP (
  DateTaken      date,
  TimeTaken      time,
  LeftSystolic   integer,
  LeftDiastolic  integer,
  LeftPulse      integer,
  LeftIrrHeart   varchar(3),
  RightSystolic  integer,
  RigtDiastolic  integer,
  RightPulse     integer,
  RightIrrHeart  varchar(3),
  Exercise	 varchar,
  Note           varchar
);


COPY BP FROM './input/BPdata.csv' (AUTO_DETECT TRUE)
;


DROP VIEW IF EXISTS BPWeek
;
CREATE VIEW BPWeek as 
  select *, CAST(((DateTaken - Date '2023-01-27')/7)+1 as integer) as WeekSinceAblation from BP;


DROP VIEW IF EXISTS BPweeklyTotalsGross
;
CREATE VIEW BPweeklyTotalsGross AS
  SELECT WeekSinceAblation,
         count(leftSystolic) as NormalLower
  FROM   BPweek
  WHERE  leftSystolic between 0 and 110
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Normal
  FROM   BPweek
  WHERE  leftSystolic between 111 and 119
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as ElevatedLower
  FROM   BPweek
  WHERE  leftSystolic between 120 and 124
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Elevated
  FROM   BPweek
  WHERE  leftSystolic between 125 and 129
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Stage1Lower
  FROM   BPweek
  WHERE  leftSystolic between 130 and 134
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Stage1
  FROM   BPweek
  WHERE  leftSystolic between 135 and 139
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Stage2Lower
  FROM   BPweek
  WHERE  leftSystolic between 140 and 144
         group by WeekSinceAblation 
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Stage2
  FROM   BPweek
  WHERE  leftSystolic between 145 and 149
         group by WeekSinceAblation
  UNION ALL BY NAME
  SELECT WeekSinceAblation,
         count(leftSystolic) as Stage2High
  FROM   BPweek
  WHERE  leftSystolic > 149
         group by WeekSinceAblation
;


DROP VIEW IF EXISTS BPweeklyTotalsByStage
;
CREATE VIEW BPweeklyTotalsByStage AS
  SELECT BPW.WeekSinceAblation,
         NL.NormalLower,
          N.Normal,
         EL.ElevatedLower,
          E.Elevated,
        S1L.Stage1Lower, 
         S1.Stage1, 
        S2L.Stage2Lower, 
         S2.Stage2, 
         S2.Stage2High, 
  FROM (select WeekSinceAblation 
        from BPweek
        group by WeekSinceAblation) AS BPW
  LEFT JOIN BPweeklyTotalsGross     AS NL
        on  BPW.WeeksinceAblation = NL.WeeksinceAblation
        and NL.NormalLower not null
  LEFT JOIN BPweeklyTotalsGross     AS N
        on  BPW.WeeksinceAblation = N.WeeksinceAblation
        and N.Normal not null
  LEFT JOIN BPweeklyTotalsGross     AS EL 
        on  BPW.WeeksinceAblation = EL.WeeksinceAblation
        and EL.ElevatedLower not null
  LEFT JOIN BPweeklyTotalsGross     AS E 
        on  BPW.WeeksinceAblation = E.WeeksinceAblation
        and E.Elevated not null
  LEFT JOIN BPweeklyTotalsGross     AS S1L 
        on  BPW.WeeksinceAblation = S1L.WeeksinceAblation
        and S1L.Stage1Lower not null
  LEFT JOIN BPweeklyTotalsGross     AS S1 
        on  BPW.WeeksinceAblation = S1.WeeksinceAblation
        and S1.Stage1 not null
  LEFT JOIN BPweeklyTotalsGross     AS S2L 
        on  BPW.WeeksinceAblation = S2L.WeeksinceAblation
        and S1L.Stage2Lower not null
  LEFT JOIN BPweeklyTotalsGross     AS S2 
        on  BPW.WeeksinceAblation = S2.WeeksinceAblation
        and S1.Stage2 not null
  LEFT JOIN BPweeklyTotalsGross     AS S2H 
        on  BPW.WeeksinceAblation = S2H.WeeksinceAblation
        and S1.Stage2High not null
;

COPY (SELECT * FROM BPweeklyTotalsByStage ORDER BY WeeksinceAblation) TO './output/BPreport.csv'
     (FORMAT CSV, HEADER);
