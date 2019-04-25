USE [AnimalProductsCoSD]
GO
/****** Object:  StoredProcedure [CoSD].[BusinessLogicUtility]    Script Date: 4/25/2019 7:40:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--// *********************************************************************** 
--// Project          : StoredProcedure for Utility functions 
--// 
--// Created          : 07/16/2018 
--// Version          : 1.0 
--// *********************************************************************** 
--//  
--// Copyright (c) . All rights reserved. 
--//  
--//  This file only contains SQL Statements which will be executed after the Business Logic procedure is executed. 
--//  It includes logic that is not handled by the engine. This SP is to be used for the addition of any further logic.
--// 
--//  
--// *********************************************************************** 
--// Index-----------------------------------------------------------------  
--•    Section 1: Deleting the data from constructed variables so that correct data is loaded onto the table. 
--•    Section 2: Calculating summation of values for all countires which will be loaded onto constructed variables for different time dimensions, this is for old data series
--•    Section 3: SQL statement which will update the stocks in the constrcuted variable table
--•    Section 4: SQL statement which will calculate average for two times dimensions i.e. all months
--•    Section 5: SQL statement which will update the newdataseries in the constructed variables
--•    Section 6: SQL statement which calculates the summation of new data series


ALTER PROCEDURE [CoSD].[BusinessLogicUtility]
AS
--------------------------------------------------------------------------------------------------------------------------- 
--Section 1 - This section deletes the incorrect values from constructed variables-- 
--------------------------------------------------------------------------------------------------------------------------- 
BEGIN
  DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    AND ersbusinesslogic_type = 'time aggregation')

  DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    AND ersbusinesslogic_type = 'HS10 aggregation')

  DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'year-to-date months -2')

	DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'year-to-date months')

  DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM cosd.ersbusinesslogic
    WHERE ersbusinesslogic_formula LIKE '%Avg%'
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months')

	 DELETE FROM cosd.ersconstructedvariablesoutcomes
  WHERE ersconstructedvariable_businesslogicid IN (SELECT
      ersbusinesslogic_id
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'year-to-date months')

END

  --------------------------------------------------------------------------------------------------------------------------- 
  --Section 1. Ends-- 
  --------------------------------------------------------------------------------------------------------------------------- 

    --------------------------------------------------------------------------------------------------------------------------- 
    ---Section 2. Finding summation of values for all countires which will be loaded onto constructed variables  -- 
	---Section 2.1 This part of code finds for 'all months' input time dimension period for single commodity IDs
    --------------------------------------------------------------------------------------------------------------------------- 
  BEGIN
    ;
    WITH datafromdatavalues (ersdatavalues_erscommodity_id, ersgeographydimension_id, erstimedimension_year, total)
    AS (SELECT
      a.ersdatavalues_erscommodity_id,
      c.ersgeographydimension_id,
      b.erstimedimension_year,
      SUM(a.ersdatavalues_attributevalue) AS Total
    FROM cosd.ersdatavalues a,
         cosd.erstimedimension_lu b,
         cosd.ersgeographydimension_lu c
    WHERE a.ersdatavalues_erscommodity_id IN (SELECT
      ersbusinesslogic_inputdataseries
    FROM .[CoSD].[ersbusinesslogic]
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'all months'
    AND ersbusinesslogic_type = 'time aggregation')
    AND a.ersdatavalues_erstimedimension_id =
    b.erstimedimension_id
    --AND c.ersgeographydimension_country != 'WORLD'
    AND a.ersdatavalues_ersgeography_id = c.ersgeographydimension_id
    GROUP BY b.erstimedimension_year,
             a.ersdatavalues_erscommodity_id,
             c.ersgeographydimension_id),
    datafrombussiness (ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date)
    AS (SELECT
      ersbusinesslogic_id,
      ersbusinesslogic_outputdestination,
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_year,
      b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    AND ersbusinesslogic_type = 'time aggregation'
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id)
    INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
      SELECT
        ersbusinesslogic_id,
        total,
        Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
        erstimedimension_date),
        ': ', MONTH(erstimedimension_date)),
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
        ersbusinesslogic_outputtimedimensionvalue,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
        erstimedimension_date,
        ersbusinesslogic_inputtimedimensiontypeid,
        ersgeographydimension_id,
        erstimedimension_id
      FROM datafrombussiness,
           datafromdatavalues
      WHERE datafromdatavalues.ersdatavalues_erscommodity_id =
      datafrombussiness.ersbusinesslogic_inputdataseries
      AND datafromdatavalues.erstimedimension_year =
      datafrombussiness.erstimedimension_year

	  END
       --------------------------------------------------------------------------------------------------------------------------- 
    	---Section 2.2 This part of code calculates the sum for 'all months' for mutiple commodity IDs.
    --------------------------------------------------------------------------------------------------------------------------- 
  BEGIN
  
    ;

    WITH dataforids
    AS (SELECT
      value,
      ersbusinesslogic_inputdataseries
    FROM .[CoSD].[ersbusinesslogic]
    CROSS APPLY (SELECT
      Seq = ROW_NUMBER()
      OVER (
      ORDER BY (SELECT
        NULL)
      ),
      Value = v.value('(./text())[1]',
      'varchar(max)')
    FROM (VALUES (
    CONVERT(xml, '<x>'
    + REPLACE(ersbusinesslogic_inputdataseries,
    ','
    , '</x><x>')
    + '</x>'))) x (n)
    CROSS APPLY n.nodes('x') node (v)) B
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    AND ersbusinesslogic_type = 'HS10 aggregation'),
    datafromdatavalues (total, ersbusinesslogic_inputdataseries, date, ersgeographydimension_id, erstimedimension_id)
    AS (SELECT
      SUM(ersdatavalues_attributevalue) AS Total,
      dataforids.ersbusinesslogic_inputdataseries,
      Format(b.erstimedimension_date, 'yyyy-MM-dd') AS Date,
      c.ersgeographydimension_id,
      b.erstimedimension_id
    FROM cosd.ersdatavalues a,
         cosd.erstimedimension_lu b,
         dataforids,
         cosd.ersgeographydimension_lu c
    WHERE a.ersdatavalues_erscommodity_id = dataforids.value
    AND a.ersdatavalues_erstimedimension_id = b.erstimedimension_id
    AND c.ersgeographydimension_id =
    a.ersdatavalues_ersgeography_id
    GROUP BY ersgeographydimension_id,
             dataforids.ersbusinesslogic_inputdataseries,
             b.erstimedimension_date,
             erstimedimension_id),
    datafrombussiness (ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_date)
    AS (SELECT
      ersbusinesslogic_id,
      ersbusinesslogic_outputdestination,
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b,
         cosd.ersgeographydimension_lu c
    WHERE a.ersbusinesslogic_outputgeographydimensionid =
    c.ersgeographydimension_id
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    AND ersbusinesslogic_type = 'HS10 aggregation'
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id)
    INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
      SELECT
        ersbusinesslogic_id,
        total,
        Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
        erstimedimension_date)),
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
        ersbusinesslogic_outputtimedimensionvalue,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
        date,
        ersbusinesslogic_inputtimedimensiontypeid,
        ersgeographydimension_id,
        datafrombussiness.erstimedimension_id
      FROM datafrombussiness,
           datafromdatavalues
      WHERE datafromdatavalues.ersbusinesslogic_inputdataseries =
      datafrombussiness.ersbusinesslogic_inputdataseries
      AND datafrombussiness.erstimedimension_id =
      datafromdatavalues.erstimedimension_id
	
	  END
    ----------------------------------------------------------------------------------------------------------------------------- 
    --Section 2.3 This part of code calculates the sum for 'year to date -2' input time dimension period; for current year and previous year.
    ----------------------------------------------------------------------------------------------------------------------------- 
  BEGIN
  
  ;

    WITH datafromdatavalues (total, ersdatavalues_erscommodity_id, ersgeographydimension_id, erstimedimension_year)
    AS (SELECT
      SUM(A.ERSDATAVALUES_ATTRIBUTEVALUE) AS TOTAL,
      A.ERSDATAVALUES_ERSCOMMODITY_ID,
      B.ERSGEOGRAPHYDIMENSION_ID,
      C.ERSTIMEDIMENSION_YEAR
    FROM COSD.ERSDATAVALUES A,
         COSD.ERSGEOGRAPHYDIMENSION_LU B,
         COSD.ERSTIMEDIMENSION_LU C
    WHERE A.ERSDATAVALUES_ERSCOMMODITY_ID IN (SELECT
      ERSBUSINESSLOGIC_INPUTDATASERIES
    FROM .[COSD].[ERSBUSINESSLOGIC]
    WHERE ERSBUSINESSLOGIC_INPUTGEOGRAPHYDIMENSIONID = 7493
    AND ERSBUSINESSLOGIC_INPUTTIMEDIMENSIONVALUE =
    'YEAR-TO-DATE MONTHS -2')
    AND A.ERSDATAVALUES_ERSGEOGRAPHY_ID = B.ERSGEOGRAPHYDIMENSION_ID
    AND B.ERSGEOGRAPHYDIMENSION_ID = A.ERSDATAVALUES_ERSGEOGRAPHY_ID
    AND C.ERSTIMEDIMENSION_ID = A.ERSDATAVALUES_ERSTIMEDIMENSION_ID
  --  AND B.ERSGEOGRAPHYDIMENSION_COUNTRY != 'WORLD'
    AND C.ERSTIMEDIMENSION_YEAR =
    YEAR(GETDATE()) - 1
    
    AND C.ERSTIMEDIMENSION_MONTH BETWEEN 1 AND MONTH(GETDATE())-2
    GROUP BY C.ERSTIMEDIMENSION_YEAR,
             ERSDATAVALUES_ERSCOMMODITY_ID,
             B.ERSGEOGRAPHYDIMENSION_COUNTRY,
             B.ERSGEOGRAPHYDIMENSION_ID),
    datafrombussiness (ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date)
    AS (SELECT
      ersbusinesslogic_id,
      Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
      erstimedimension_date),
      ': ', MONTH(erstimedimension_date)),
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_year,
        b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'year-to-date months -2'
    AND ersbusinesslogic_type = 'time aggregation'
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id)
    INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
       SELECT
        ersbusinesslogic_id,
        total,
        ersbusinesslogic_outputdestination,
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
       ersbusinesslogic_outputdestination,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
       	case when month(getdate()) > 9 then
      Concat(year(erstimedimension_date),'-',month(getdate()), '-', '01') else  Concat(year(erstimedimension_date),'-','0',month(getdate()), '-', '01') end,  
        ersbusinesslogic_inputtimedimensiontypeid,
        ersgeographydimension_id,
        erstimedimension_id
      FROM datafrombussiness,
           datafromdatavalues
      WHERE datafromdatavalues.ersdatavalues_erscommodity_id =
      datafrombussiness.ersbusinesslogic_inputdataseries
      AND datafromdatavalues.erstimedimension_year =
      datafrombussiness.erstimedimension_year
  END

  --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 2.3 ends here------- 
  ---------------------------------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 2.4 starts here------- 
  ---------------------------------------------------------------------------------------------------------------------------
  BEGIN
  
  ;

    WITH datafromdatavalues (total, ersdatavalues_erscommodity_id, ersgeographydimension_id, erstimedimension_year)
    AS (SELECT
      SUM(A.ERSDATAVALUES_ATTRIBUTEVALUE) AS TOTAL,
      A.ERSDATAVALUES_ERSCOMMODITY_ID,
      B.ERSGEOGRAPHYDIMENSION_ID,
      C.ERSTIMEDIMENSION_YEAR
    FROM COSD.ERSDATAVALUES A,
         COSD.ERSGEOGRAPHYDIMENSION_LU B,
         COSD.ERSTIMEDIMENSION_LU C
    WHERE A.ERSDATAVALUES_ERSCOMMODITY_ID IN (SELECT
      ERSBUSINESSLOGIC_INPUTDATASERIES
    FROM .[COSD].[ERSBUSINESSLOGIC]
    WHERE ERSBUSINESSLOGIC_INPUTGEOGRAPHYDIMENSIONID = 7493
    AND ERSBUSINESSLOGIC_INPUTTIMEDIMENSIONVALUE =
    'YEAR-TO-DATE MONTHS')
    AND A.ERSDATAVALUES_ERSGEOGRAPHY_ID = B.ERSGEOGRAPHYDIMENSION_ID
    AND B.ERSGEOGRAPHYDIMENSION_ID = A.ERSDATAVALUES_ERSGEOGRAPHY_ID
    AND C.ERSTIMEDIMENSION_ID = A.ERSDATAVALUES_ERSTIMEDIMENSION_ID
   -- AND B.ERSGEOGRAPHYDIMENSION_COUNTRY != 'WORLD'
    AND C.ERSTIMEDIMENSION_YEAR =
     YEAR(GETDATE())
    
    AND C.ERSTIMEDIMENSION_MONTH BETWEEN 1 AND MONTH(GETDATE())-2
    GROUP BY C.ERSTIMEDIMENSION_YEAR,
             ERSDATAVALUES_ERSCOMMODITY_ID,
             B.ERSGEOGRAPHYDIMENSION_COUNTRY,
             B.ERSGEOGRAPHYDIMENSION_ID),
    datafrombussiness (ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date)
    AS (SELECT
      ersbusinesslogic_id,
      Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
      erstimedimension_date),
      ': ', MONTH(erstimedimension_date)),
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_year,
        b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue =
    'year-to-date months'
    AND ersbusinesslogic_type = 'time aggregation'
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id)
    INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
       SELECT
        ersbusinesslogic_id,
        total,
        ersbusinesslogic_outputdestination,
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
       ersbusinesslogic_outputdestination,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
		case when month(getdate()) > 9 then
      Concat(year(erstimedimension_date),'-',month(getdate()), '-', '01') else  Concat(year(erstimedimension_date),'-','0',month(getdate()), '-', '01') end,  
        ersbusinesslogic_inputtimedimensiontypeid,
        ersgeographydimension_id,
        erstimedimension_id
      FROM datafrombussiness,
           datafromdatavalues
      WHERE datafromdatavalues.ersdatavalues_erscommodity_id =
      datafrombussiness.ersbusinesslogic_inputdataseries
      AND datafromdatavalues.erstimedimension_year =
      datafrombussiness.erstimedimension_year
 
  END

  --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 2.4 ends here------- 
  ---------------------------------------------------------------------------------------------------------------------------
 
 --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 2 ends here------- 
  ---------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------- 
  ---Section 3 SQL statement which will update the stocks in the constrcuted variable table------- 
  ---------------------------------------------------------------------------------------------------------------------------
 

  BEGIN
    UPDATE cosd.ersconstructedvariablesoutcomes
    SET ersconstructedvariable_timedimensiondate = (
    CASE
      WHEN (DAY(ersconstructedvariable_timedimensiondate) = 1) THEN ersconstructedvariable_timedimensiondate
      WHEN (DAY(ersconstructedvariable_timedimensiondate) != 1) THEN DATEADD(DAY, 1, ersconstructedvariable_timedimensiondate)
    END)
    WHERE ersconstructedvariable_id IN (SELECT
      ersconstructedvariable_id
    FROM cosd.ersconstructedvariablesoutcomes
    WHERE ersconstructedvariable_outputname LIKE
    '%beginning stocks%'
    AND ersconstructedvariable_inputsources
    LIKE '%NASS%')

    UPDATE cosd.ersconstructedvariablesoutcomes
    SET ersconstructedvariable_outputdestination =
    SUBSTRING(ersconstructedvariable_outputdestination, 0, 10)
    WHERE ersconstructedvariable_id IN (SELECT
      ersconstructedvariable_id
    FROM cosd.ersconstructedvariablesoutcomes
    WHERE ersconstructedvariable_outputname LIKE
    '%beginning stocks%'
    AND ersconstructedvariable_inputsources
    LIKE '%NASS%')

	update cvo
set cvo.ERSConstructedVariable_TimeDimensionID = tlu.ERSTimeDimension_ID
from cosd.ERSConstructedVariablesOutcomes cvo INNER JOIN cosd.ERSTimeDimension_LU tlu
on tlu.ERSTimeDimension_Date=cvo.ERSConstructedVariable_TimeDimensionDate
where ersconstructedvariable_outputname LIKE
    '%beginning stocks%'
    AND ersconstructedvariable_inputsources
    LIKE '%NASS%'


  END

    --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 3. ends here------- 
  ---------------------------------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 4 . SQL statement which calculates the average for all months------   
  --------------------------------------------------------------------------------------------------------------------------- 
  BEGIN
 ;
WITH samplefordata
AS (SELECT
  *
FROM cosd.ersbusinesslogic
WHERE ersbusinesslogic_formula LIKE '%AVG%'
AND ersbusinesslogic_inputtimedimensionvalue = 'all months'),
averagevalue
AS (SELECT
  cosd.ersbusinesslogic.ersbusinesslogic_id,
  cosd.ERSBusinessLogic.ERSBusinessLogic_InputDataSeries,
  cosd.ERSTimeDimension_LU.ERSTimeDimension_Year,
  AVG(cosd.ersdatavalues.ersdatavalues_attributevalue) AS outputvalue

FROM cosd.ersdatavalues,
     cosd.erstimedimension_lu,
     cosd.ersbusinesslogic,
     cosd.ersgeographydimension_lu,
     samplefordata

WHERE cosd.ersdatavalues.ersdatavalues_erscommodity_id = samplefordata.ersbusinesslogic_inputdataseries
AND cosd.ersbusinesslogic.ersbusinesslogic_id = samplefordata.ersbusinesslogic_id
AND cosd.ersbusinesslogic.ersbusinesslogic_inputtimedimensionvalue = 'all months'
AND cosd.erstimedimension_lu.erstimedimension_timedimensiontype_id = 11
AND cosd.ersdatavalues.ersdatavalues_erstimedimension_id =
cosd.erstimedimension_lu.erstimedimension_id
AND cosd.ersbusinesslogic.ersbusinesslogic_inputgeographydimensionid =
cosd.ersgeographydimension_lu.ersgeographydimension_id
AND cosd.ersdatavalues.ersdatavalues_ersunit_id =
cosd.ersbusinesslogic.ersbusinesslogic_inputunitid

GROUP BY cosd.ersbusinesslogic.ersbusinesslogic_id,
         cosd.ERSBusinessLogic.ERSBusinessLogic_InputDataSeries,
         ERSTimeDimension_Year),
gettimedimensionid
AS (SELECT DISTINCT
  ERSTimeDimension_ID,
  averagevalue.ERSTimeDimension_Year
FROM cosd.ERSTimeDimension_LU,
     averagevalue
WHERE averagevalue.ERSTimeDimension_Year = cosd.ERSTimeDimension_LU.ERSTimeDimension_Year
AND cosd.ERSTimeDimension_LU.ERSTimeDimension_TimeDimensionType_ID = 17)

INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])

SELECT
  cosd.ersbusinesslogic.ersbusinesslogic_id,
  averagevalue.outputvalue,
  cosd.ersbusinesslogic.ersbusinesslogic_outputdestination,
  cosd.ersbusinesslogic.ersbusinesslogic_longdesc,
  GETDATE(),
  cosd.ersbusinesslogic.ersbusinesslogic_outputunitid,
  cosd.ersbusinesslogic.ersbusinesslogic_privacyid,
  cosd.ersbusinesslogic.ersbusinesslogic_inputsources,
  cosd.ersbusinesslogic.ersbusinesslogic_inputsourceid,
  cosd.ersbusinesslogic.ersbusinesslogic_outputtimedimensionvalue,
  cosd.ersbusinesslogic.ersbusinesslogic_outputtimedimensiontypeid,
  cosd.ersbusinesslogic.ersbusinesslogic_outputname,
  Concat(averagevalue.erstimedimension_year,
  '-' + '01' + '-' + '01'),
  4 AS
  [ERSConstructedVariable_DataRowLifecyclePhaseID],
  cosd.ersbusinesslogic.ersbusinesslogic_outputgeographydimensionid,
  gettimedimensionid.ERSTimeDimension_ID



FROM cosd.ersbusinesslogic,
     gettimedimensionid,
     averagevalue

WHERE averagevalue.ERSBusinessLogic_ID = cosd.ERSBusinessLogic.ERSBusinessLogic_ID
AND averagevalue.ERSTimeDimension_Year = gettimedimensionid.ERSTimeDimension_Year
AND averagevalue.ERSBusinessLogic_InputDataSeries = cosd.ERSBusinessLogic.ERSBusinessLogic_InputDataSeries		
   
   
   END
  
  --------------------------------------------------------------------------------------------------------------------------- 
  ---Section 4 ends------- 
  --------------------------------------------------------------------------------------------------------------------------- 

  --------------------------------------------------------------------------------------------------------------------------- 
	---Section 5. SQL statement to update newdataseries column after all the inserts have taken place------   
   --------------------------------------------------------------------------------------------------------------------------  
 BEGIN
    	
			
				SELECT
					cosd.erscommoditydataseries.erscommodity_id AS
					datatobeupdated,ERSBusinessLogic_ID
					INTO #temptable
				FROM cosd.erscommoditydataseries INNER JOIN cosd.ersconstructedvariablesoutcomes
					ON 
					SUBSTRING(
					cosd.erscommoditydataseries.erscommodity_sourceseriesid,
					CHARINDEX('(', cosd.erscommoditydataseries.erscommodity_sourceseriesid)
					+ 1,
					CHARINDEX(')',
					cosd.erscommoditydataseries.erscommodity_sourceseriesid)
					-
					CHARINDEX('(',
					cosd.erscommoditydataseries.erscommodity_sourceseriesid) - 1) =
					SUBSTRING(
					cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_outputdestination,
					CHARINDEX('(', cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_outputdestination)
					+ 1, CHARINDEX(')',
					cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_outputdestination) -
					CHARINDEX('(',
					cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_outputdestination)
					- 1)
					INNER JOIN cosd.ERSBusinessLogic   
					
					ON
					cosd.ERSBusinessLogic.ERSBusinessLogic_ID=ERSConstructedVariable_BusinessLogicID
				where erscommodity_sourceseriesid LIKE '%(N%'
				AND cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_outputdestination
				LIKE '%CV(N%'
				AND cosd.ersconstructedvariablesoutcomes.ersconstructedvariable_newdataseriesid
				IS
				NULL
				update cosd.ERSConstructedVariablesOutcomes set ERSConstructedVariable_NewDataSeriesID=_dummy.datatobeupdated
				from cosd.ERSConstructedVariablesOutcomes dummy  JOIN #temptable _dummy
				on dummy.ERSConstructedVariable_BusinessLogicID= _dummy.ERSBusinessLogic_ID

				DROP table #temptable

 END
 
  --------------------------------------------------------------------------------------------------------------------------- 
												  ---Section 5 Ends  
  ---------------------------------------------------------------------------------------------------------------------------- 

  
  --------------------------------------------------------------------------------------------------------------------------- 
   ---Section 6. Starts------   
  ---------------------------------------------------------------------------------------------------------------------------- 
    --------------------------------------------------------------------------------------------------------------------------- 
   ---Section 6.1 This section finds the sum for new data series from the CV table i.e. finds sum for current year using the 
							 --- year-to-date months as input time dimension------   
  ---------------------------------------------------------------------------------------------------------------------------- 

  BEGIN
  
;with datafromBL  as 
(select  ERSBusinessLogic_InputDataSeries,ERSBusinessLogic_ID  from cosd.ERSBusinessLogic where
 ERSBusinessLogic_InputDataSeries  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') 
and ERSBusinessLogic_InputTimeDimensionValue='year-to-date months'
and ERSBusinessLogic_InputGeographyDimensionID=7493)
, summationvalue as 
(
select sum(ERSConstructedVariable_OutputValue) as total,datafromBL.ERSBusinessLogic_InputDataSeries,datafromBL.ERSBusinessLogic_ID,
ERSConstructedVariable_OutputGeographyDimensionID
from cosd.ERSConstructedVariablesOutcomes,datafromBL where
 ERSConstructedVariable_NewDataSeriesID=datafromBL.ERSBusinessLogic_InputDataSeries
and year(ERSConstructedVariable_TimeDimensionDate) = year(getdate()) 
and month(ERSConstructedVariable_TimeDimensionDate) between 1 and month(getdate())
group by datafromBL.ERSBusinessLogic_InputDataSeries,datafromBL.ERSBusinessLogic_ID,
ERSConstructedVariable_OutputGeographyDimensionID)


, datafromBLtbl(ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date) as

(
SELECT distinct
      ersbusinesslogic_id,
      Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
      erstimedimension_date),
      ': ', MONTH(erstimedimension_date)),
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_year,
        b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
		 ,cosd.ERSConstructedVariablesOutcomes c
    WHERE  ERSBusinessLogic_InputDataSeries  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') 
and ERSBusinessLogic_InputTimeDimensionValue='year-to-date months'
and ERSBusinessLogic_InputGeographyDimensionID=7493
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id
	and c.ERSConstructedVariable_NewDataSeriesID=a.ERSBusinessLogic_InputDataSeries
	and month(ERSTimeDimension_Date) between 1 and month(getdate())
	and year(ERSTimeDimension_Date) = year(getdate()))
	INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
   
       SELECT
        summationvalue.ERSBusinessLogic_ID,
        total,
        ersbusinesslogic_outputdestination,
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
       ersbusinesslogic_outputtimedimensionvalue,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
			case when month(getdate()) > 9 then
      Concat(year(erstimedimension_date),'-',month(getdate()), '-', '01') else  Concat(year(erstimedimension_date),'-','0',month(getdate()), '-', '01') end,  
       ersbusinesslogic_inputtimedimensiontypeid,
       summationvalue.ERSConstructedVariable_OutputGeographyDimensionID,
        erstimedimension_id
      FROM datafromBLtbl,
           summationvalue
      WHERE summationvalue.ERSBusinessLogic_ID=
      datafromBLtbl.ERSBusinessLogic_ID
	  and summationvalue.ERSBusinessLogic_InputDataSeries=datafromBLtbl.ersbusinesslogic_inputdataseries
END
	    --------------------------------------------------------------------------------------------------------------------------- 
   ---Section 6.2 This section finds the sum for new data series from the CV table i.e. finds sum for previous year using the 
							 --- year-to-date months -2 as input time dimension------   
  ---------------------------------------------------------------------------------------------------------------------------- 
  BEGIN
	  
	  --- year to date months -2
	   ;with datafromBL  as 
(select  ERSBusinessLogic_InputDataSeries,ERSBusinessLogic_ID  from cosd.ERSBusinessLogic where
 ERSBusinessLogic_InputDataSeries  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') 
and ERSBusinessLogic_InputTimeDimensionValue='year-to-date months -2'
and ERSBusinessLogic_InputGeographyDimensionID=7493)
, summationvalue as 
(
select sum(ERSConstructedVariable_OutputValue) as total,datafromBL.ERSBusinessLogic_InputDataSeries,datafromBL.ERSBusinessLogic_ID,
ERSConstructedVariable_OutputGeographyDimensionID
from cosd.ERSConstructedVariablesOutcomes,datafromBL where
 ERSConstructedVariable_NewDataSeriesID=datafromBL.ERSBusinessLogic_InputDataSeries
and year(ERSConstructedVariable_TimeDimensionDate) = year(getdate()) -1
and month(ERSConstructedVariable_TimeDimensionDate) between 1 and month(getdate()) -2
group by datafromBL.ERSBusinessLogic_InputDataSeries,datafromBL.ERSBusinessLogic_ID,
ERSConstructedVariable_OutputGeographyDimensionID)


, datafromBLtbl(ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date) as

(
SELECT distinct
      ersbusinesslogic_id,
      Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
      erstimedimension_date),
      ': ', MONTH(erstimedimension_date)),
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      ersbusinesslogic_inputdataseries,
      b.erstimedimension_year,
        b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
		 ,cosd.ERSConstructedVariablesOutcomes c
    WHERE  ERSBusinessLogic_InputDataSeries  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') 
and ERSBusinessLogic_InputTimeDimensionValue='year-to-date months -2'
and ERSBusinessLogic_InputGeographyDimensionID=7493
    AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id
	and c.ERSConstructedVariable_NewDataSeriesID=a.ERSBusinessLogic_InputDataSeries
	and month(ERSTimeDimension_Date) between 1 and month(getdate()) -2
	and year(ERSTimeDimension_Date) = year(getdate())-1)
	
	INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])
	
   
       SELECT
        summationvalue.ERSBusinessLogic_ID,
        total,
        ersbusinesslogic_outputdestination,
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
       ersbusinesslogic_outputtimedimensionvalue,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
 	case when month(getdate()) > 9 then
      Concat(year(erstimedimension_date),'-',month(getdate()), '-', '01') else  Concat(year(erstimedimension_date),'-','0',month(getdate()), '-', '01') end,  
 
        ersbusinesslogic_inputtimedimensiontypeid,
       summationvalue.ERSConstructedVariable_OutputGeographyDimensionID,
        erstimedimension_id
      FROM datafromBLtbl,
           summationvalue
      WHERE summationvalue.ERSBusinessLogic_ID=
      datafromBLtbl.ERSBusinessLogic_ID
	  and summationvalue.ERSBusinessLogic_InputDataSeries=datafromBLtbl.ersbusinesslogic_inputdataseries
    END
	  --------------------------------------------------------------------------------------------------------------------------- 
   ---Section 6.3 This section finds the sum for new data series from the CV table i.e. finds sum for all years using the 
							 --- all months as input time dimension------   
  ---------------------------------------------------------------------------------------------------------------------------- 

	BEGIN
	; with datafromBL as 
(SELECT distinct
      value,
      ersbusinesslogic_inputdataseries,ERSBusinessLogic_ID
    FROM cosd.ERSConstructedVariablesOutcomes, .[CoSD].[ersbusinesslogic]
    CROSS APPLY (SELECT
      Seq = ROW_NUMBER()
      OVER (
      ORDER BY (SELECT
        NULL)
      ),
      Value = v.value('(./text())[1]',
      'varchar(max)')
    FROM (VALUES (
    CONVERT(xml, '<x>'
    + REPLACE(ersbusinesslogic_inputdataseries,
    ','
    , '</x><x>')
    + '</x>'))) x (n)
    CROSS APPLY n.nodes('x') node (v)) B
    WHERE ersbusinesslogic_inputgeographydimensionid = 7493
    AND ersbusinesslogic_inputtimedimensionvalue = 'all months'
    and cosd.ERSConstructedVariablesOutcomes.ERSConstructedVariable_NewDataSeriesID = 
value
and  value  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') ),

datafromCV as 
(
select sum(ERSConstructedVariable_OutputValue) as Total,datafromBL.value,datafromBL.ERSBusinessLogic_ID,
cosd.ERSTimeDimension_LU.ERSTimeDimension_Year,ERSConstructedVariable_OutputGeographyDimensionID from
 cosd.ERSConstructedVariablesOutcomes,datafromBL,cosd.ERSTimeDimension_LU where
 ERSConstructedVariable_NewDataSeriesID=datafromBL.value
 and cosd.ERSTimeDimension_LU.ERSTimeDimension_ID=cosd.ERSConstructedVariablesOutcomes.ERSConstructedVariable_TimeDimensionID
group by datafromBL.Value,datafromBL.ERSBusinessLogic_ID,ERSTimeDimension_Year,ERSConstructedVariable_OutputGeographyDimensionID
),
datafromBLtbl(ersbusinesslogic_id, ersbusinesslogic_outputdestination, ersbusinesslogic_longdesc, ersbusinesslogic_outputunitid, ersbusinesslogic_privacyid, ersbusinesslogic_inputsources, ersbusinesslogic_inputsourceid, ersbusinesslogic_outputtimedimensionvalue, ersbusinesslogic_outputtimedimensiontypeid, ersbusinesslogic_outputname, ersbusinesslogic_outputgeographydimensionid, ersbusinesslogic_inputtimedimensiontypeid, erstimedimension_id, ersbusinesslogic_inputdataseries, erstimedimension_year, erstimedimension_date) as

(
SELECT distinct
      d.ERSBusinessLogic_ID,
      Concat(ersbusinesslogic_outputdestination, ' ', YEAR(
      erstimedimension_date),
      ': ', MONTH(erstimedimension_date)),
      ersbusinesslogic_longdesc,
      ersbusinesslogic_outputunitid,
      ersbusinesslogic_privacyid,
      ersbusinesslogic_inputsources,
      ersbusinesslogic_inputsourceid,
      ersbusinesslogic_outputtimedimensionvalue,
      ersbusinesslogic_outputtimedimensiontypeid,
      ersbusinesslogic_outputname,
      ersbusinesslogic_outputgeographydimensionid,
      '4' AS ERSBusinessLogic_InputTimeDimensionTypeID,
      b.erstimedimension_id,
      a.ERSBusinessLogic_InputDataSeries,
      b.erstimedimension_year,
        b.erstimedimension_date
    FROM cosd.ersbusinesslogic a,
         cosd.erstimedimension_lu b
		 ,datafromBL d
		 ,cosd.ERSConstructedVariablesOutcomes c
    where Value  in (select ERSCommodity_ID from cosd.ERSCommodityDataSeries 
where ERSCommodity_SourceSeriesID  like '%(N%') 
and ERSBusinessLogic_InputTimeDimensionValue='all months'
and ERSBusinessLogic_InputGeographyDimensionID=7493
AND a.ersbusinesslogic_outputtimedimensiontypeid = b.erstimedimension_timedimensiontype_id
and c.ERSConstructedVariable_NewDataSeriesID=d.Value)

INSERT INTO [CoSD].[ersconstructedvariablesoutcomes] ([ersconstructedvariable_businesslogicid],
    [ersconstructedvariable_outputvalue],
    [ersconstructedvariable_outputdestination],
    [ersconstructedvariable_longdescription],
    [ersconstructedvariable_executiondate],
    [ersconstructedvariable_outputunitid],
    [ersconstructedvariable_datarowprivacyid],
    [ersconstructedvariable_inputsources],
    [ersconstructedvariable_inputsourceid],
    [ersconstructedvariable_outputtimedimensionvalue],
    [ersconstructedvariable_outputtimedimensiontypeid],
    [ersconstructedvariable_outputname],
    [ersconstructedvariable_timedimensiondate],
    [ersconstructedvariable_datarowlifecyclephaseid],
    [ersconstructedvariable_outputgeographydimensionid],
    [ersconstructedvariable_timedimensionid])	
   
       SELECT
        datafromCV.ERSBusinessLogic_ID,
        total,
        ersbusinesslogic_outputdestination,
        ersbusinesslogic_longdesc,
        GETDATE(),
        ersbusinesslogic_outputunitid,
        ersbusinesslogic_privacyid,
        ersbusinesslogic_inputsources,
        ersbusinesslogic_inputsourceid,
       ersbusinesslogic_outputtimedimensionvalue,
        ersbusinesslogic_outputtimedimensiontypeid,
        ersbusinesslogic_outputname,
        erstimedimension_date,
        ersbusinesslogic_inputtimedimensiontypeid,
       datafromCV.ERSConstructedVariable_OutputGeographyDimensionID,
        erstimedimension_id
      FROM datafromBLtbl,
           datafromCV
      WHERE datafromCV.ERSBusinessLogic_ID=
      datafromBLtbl.ERSBusinessLogic_ID
	  and datafromCV.Value=datafromBLtbl.ersbusinesslogic_inputdataseries
	  and datafromBLtbl.erstimedimension_year=datafromCV.ERSTimeDimension_Year
    END

  --------------------------------------------------------------------------------------------------------------------------- 
												  ---Section 6 Ends  
  ---------------------------------------------------------------------------------------------------------------------------- 
 