DROP TABLE IF EXISTS BPinput
; 
CREATE TABLE BPinput (
  MeasurementDate     date    not null,
  LeftSystolicReading integer not null
);


COPY BPinput FROM './input/BPdata.csv' (AUTO_DETECT TRUE)
;


DROP VIEW IF EXISTS BP
;
CREATE VIEW BP AS (
  SELECT 
  MeasurementDate     AS DateTaken,
  LeftSystolicReading AS LeftSystolic
  FROM BPinput)
;


DROP VIEW IF EXISTS BPStartDate
;
CREATE VIEW BPStartDate AS 
  SELECT Min(DateTaken) AS StartDate
  FROM BP
;


DROP VIEW IF EXISTS BPWeek
;
CREATE VIEW BPWeek AS 
  SELECT *, CAST(((DateTaken - (SELECT StartDate FROM BPStartDate))/7) AS integer) AS WeekSinceAnchor from BP;


DROP VIEW IF EXISTS BPweeklyTotalsGross
;
CREATE VIEW BPweeklyTotalsGross AS
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Low
  FROM   BPweek
  WHERE  leftSystolic between 0 and 89
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS NormalLower
  FROM   BPweek
  WHERE  leftSystolic between 90 and 110
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Normal
  FROM   BPweek
  WHERE  leftSystolic between 111 and 119
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS ElevatedLower
  FROM   BPweek
  WHERE  leftSystolic between 120 and 124
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Elevated
  FROM   BPweek
  WHERE  leftSystolic between 125 and 129
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Stage1Lower
  FROM   BPweek
  WHERE  leftSystolic between 130 and 134
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Stage1
  FROM   BPweek
  WHERE  leftSystolic between 135 and 139
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Stage2Lower
  FROM   BPweek
  WHERE  leftSystolic between 140 and 144
         group by WeekSinceAnchor 
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Stage2
  FROM   BPweek
  WHERE  leftSystolic between 145 and 149
         group by WeekSinceAnchor
  UNION ALL BY NAME
  SELECT WeekSinceAnchor,
         count(leftSystolic) AS Stage2High
  FROM   BPweek
  WHERE  leftSystolic > 149
         group by WeekSinceAnchor
;


DROP VIEW IF EXISTS BPweeklyTotalsByStage
;
CREATE VIEW BPweeklyTotalsByStage AS
  SELECT BPW.WeekSinceAnchor,
         LW.Low,
         NL.NormalLower,
          N.Normal,
         EL.ElevatedLower,
          E.Elevated,
        S1L.Stage1Lower, 
         S1.Stage1, 
        S2L.Stage2Lower, 
         S2.Stage2, 
         S2.Stage2High, 
  FROM (SELECT WeekSinceAnchor 
        from BPweek
        group by WeekSinceAnchor)   AS BPW
  LEFT JOIN BPweeklyTotalsGross     AS LW
        on  BPW.WeekSinceAnchor = LW.WeekSinceAnchor
        and LW.Low not null
  LEFT JOIN BPweeklyTotalsGross     AS NL
        on  BPW.WeekSinceAnchor = NL.WeekSinceAnchor
        and NL.NormalLower not null
  LEFT JOIN BPweeklyTotalsGross     AS N
        on  BPW.WeekSinceAnchor = N.WeekSinceAnchor
        and N.Normal not null
  LEFT JOIN BPweeklyTotalsGross     AS EL 
        on  BPW.WeekSinceAnchor = EL.WeekSinceAnchor
        and EL.ElevatedLower not null
  LEFT JOIN BPweeklyTotalsGross     AS E 
        on  BPW.WeekSinceAnchor = E.WeekSinceAnchor
        and E.Elevated not null
  LEFT JOIN BPweeklyTotalsGross     AS S1L 
        on  BPW.WeekSinceAnchor = S1L.WeekSinceAnchor
        and S1L.Stage1Lower not null
  LEFT JOIN BPweeklyTotalsGross     AS S1 
        on  BPW.WeekSinceAnchor = S1.WeekSinceAnchor
        and S1.Stage1 not null
  LEFT JOIN BPweeklyTotalsGross     AS S2L 
        on  BPW.WeekSinceAnchor = S2L.WeekSinceAnchor
        and S2L.Stage2Lower not null
  LEFT JOIN BPweeklyTotalsGross     AS S2 
        on  BPW.WeekSinceAnchor = S2.WeekSinceAnchor
        and S2.Stage2 not null
  LEFT JOIN BPweeklyTotalsGross     AS S2H 
        on  BPW.WeekSinceAnchor = S2H.WeekSinceAnchor
        and S2H.Stage2High not null
;

DROP VIEW IF EXISTS BPweeklyTotalsByStageNullAsZero
;
CREATE VIEW BPweeklyTotalsByStageNullAsZero AS
  SELECT WeekSinceAnchor,
         coalesce(Low,'0')           AS Low,
         coalesce(NormalLower,'0')   AS NormalLower,
         coalesce(Normal,'0')        AS Normal,
         coalesce(ElevatedLower,'0') AS ElevatedLower,
         coalesce(Elevated,'0')      AS Elevated,
         coalesce(Stage1Lower,'0')   AS Stage1Lower,
         coalesce(Stage1,'0')        AS Stage1,
         coalesce(Stage2Lower,'0')   AS Stage2Lower,
         coalesce(Stage2,'0')        AS Stage2,
         coalesce(Stage2High,'0')    AS Stage2High
  FROM BPweeklyTotalsByStage
;


COPY (SELECT * FROM BPweeklyTotalsByStageNullAsZero
      ORDER BY WeekSinceAnchor)
  TO './output/BPreport.csv'
     (FORMAT CSV, HEADER)
;
