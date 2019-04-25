USE [AnimalProductsCoSD]
GO
/****** Object:  StoredProcedure [CoSD].[sp_ap_data_to_repository]    Script Date: 4/25/2019 7:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [CoSD].[sp_ap_data_to_repository] -- Replace alter with create in case the stored procedure doesnt exist in the database
WITH EXECUTE AS OWNER
AS

BEGIN TRANSACTION;
BEGIN TRY
PRINT ''
PRINT '***********AP to repository data movememnt started***********'
PRINT '***********Deleting the data in repository from AnimalProducts table***********'

DELETE FROM [RepositoryCoSD].[DBO].AnimalProducts

/****** This section pushes data from AnimalProductCosd to RepositoryCoSD, specfic to APCoSD]    ******/
PRINT '***********Insertion to repository AnimalProducts starts***********'
INSERT INTO [RepositoryCoSD].dbo.AnimalProducts
SELECT
concat(DataSeriesID,'-',UnitID,'-',GeographyID,'-',TimeID,'-',LifecyclePhaseID,'-',GroupID),
 [DataSeriesID] 
      ,[CommodtiySubCommodityID]
      ,[Commodity]
      ,[SubCommodity]
      ,[SectorID]
      ,[Sector]
      ,[GroupID]
      ,[GroupName]
      ,[StatisticTypeID]
      ,[StatisticType]
      ,[SourceID]
      ,[Source]
      ,[SourceDescription]
      ,[PhysicalAttributeTypeID]
      ,[PhysicalAttributeType]
      ,[PhysicalAttributeDesc]
      ,[UtilizationPracticeID]
      ,[UtilizationPractice]
      ,[ProductionPracticeID]
      ,[ProductionPractice]
      ,[SourceSeriesID]
      ,[TimeID]
	  ,[FrequencyID]
      ,[TimeFrequency]
      ,[Date]
      ,[GeographyID]
	  ,[GeographyTypeID]
      ,[GeographyType]
      ,[City]
      ,[County]
      ,[State]
      ,[Region]
      ,[Country]
      ,[UnitID]
      ,[Unit]
      ,[LifecyclePhaseID]
      ,[LifecyclePhaseDescription]
      ,[Value] FROM AnimalProductsCoSD.CoSD.Public_Standard_View
	  where PrivacyID=5


-- Second Insert from R table
INSERT INTO [RepositoryCoSD].dbo.AnimalProducts
 select concat(cvoR.R_dataseriesID,'-',utlu.ERSUnit_ID,'-',gglu.ERSGeographyDimension_ID,'-',tlu.ERSTimeDimension_ID,'-',lflu.ERSDataLifecyclePhase_ID,'-',glu.ERSGroup_ID),cvoR.R_dataseriesID,csc.ERSCommoditySubCommodity_ID,CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) 
                                                    > 0 THEN SUBSTRING(csc.ERSCommoditySubCommodity_Desc, 1, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) - 1) ELSE csc.ERSCommoditySubCommodity_Desc END Commodity, 
                                                    CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) > 0 THEN LTRIM(SUBSTRING(csc.ERSCommoditySubCommodity_Desc, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) + 1, 
                                                    len(csc.ERSCommoditySubCommodity_Desc))) ELSE 'No SubCommodity' END AS SubCommodity,slu.ERSSector_ID,slu.ERSSector_Desc,glu.ERSGroup_ID,glu.ERSGroup_Desc,
													stlu.ERSStatisticType_ID AS StatisticTypeID, stlu.ERSStatisticType_Attribute AS StatisticType, scl.ERSSource_ID AS SourceID, scl.ERSSource_Desc AS Source, 
                                                    scl.ERSSource_LongDesc AS SourceDescription, phlu.ERSPhysicalAttribute_ID AS PhysicalAttributeTypeID, phlu.ERSPhysicalAttribute_Desc AS PhysicalAttributeType, 
                                                    cds.ERSCommodity_PhysicalAttribute_Desc AS PhysicalAttributeDesc, ulu.ERSUtilPractice_ID AS UtilizationPracticeID, ulu.ERSUtilPractice_Desc AS UtilizationPractice, 
                                                    plu.ERSProdPractice_ID AS ProductionPracticeID, plu.ERSProdPractice_Desc AS ProductionPractice, CASE WHEN cds.ERSCommodity_SourceSeriesID IS NULL 
                                                    THEN 'No SourceSeriesID' ELSE cds.ERSCommodity_SourceSeriesID END AS SourceSeriesID, tlu.ERSTimeDimension_ID AS TimeID, tlu.ERSTimeDimension_TimeDimensionType_ID AS FrequencyID, 
                                                    Replace(tylu.ERSTimeDimensionType_Desc, 'ERS', '') AS TimeFrequency, tlu.ERSTimeDimension_Date AS DATE, gglu.ERSGeographyDimension_ID AS GeographyID, 
                                                    gglu.ERSGeographyDimension_ERSGeographyType_ID AS GeographyTypeID, gtlu.ERSGeographyType_Desc AS GeographyType, CASE WHEN COALESCE (gglu.ERSGeographyDimension_City, '') 
                                                    = '' THEN 'No City' ELSE gglu.ERSGeographyDimension_City END AS City, CASE WHEN COALESCE (gglu.ERSGeographyDimension_County, '') 
                                                    = '' THEN 'No County' ELSE gglu.ERSGeographyDimension_County END AS County, CASE WHEN COALESCE (gglu.ERSGeographyDimension_State, '') 
                                                    = '' THEN 'No State' ELSE gglu.ERSGeographyDimension_State END AS STATE, CASE WHEN COALESCE (gglu.ERSGeographyDimension_Region, '') 
                                                    = '' THEN 'No Region' ELSE gglu.ERSGeographyDimension_Region END AS Region, CASE WHEN COALESCE (gglu.ERSGeographyDimension_Country, '') 
                                                    = '' THEN 'No Country' ELSE gglu.ERSGeographyDimension_Country END AS Country, utlu.ERSUnit_ID AS UnitID, utlu.ERSUnit_Desc AS Unit, dv.ERSDataValues_DataRowLifecyclePhaseID AS LifecyclePhaseID, 
                                                    lflu.ERSDataLifecyclePhase_Desc AS LifecyclePhaseDescription, dv.ERSDataValues_AttributeValue AS Value from cosd.ERSConstructedVariablesOutcomesR cvoR INNER JOIN
cosd.ERSDataValues as dv on dv.ERSDataValues_ERSCommodity_ID=cvoR.R_dataseriesID INNER JOIN
cosd.ERSCommodityDataSeries as cds on cds.ERSCommodity_ID=cvoR.R_dataseriesID INNER JOIN
cosd.ERSCommoditySubCommodity_LU as csc on csc.ERSCommoditySubCommodity_ID=cds.ERSCommoditySubCommodity_ID INNER JOIN
cosd.ERSSector_LU as slu on slu.ERSSector_ID=cds.ERSCommodity_ERSSector_ID INNER JOIN
cosd.ERSGroup_LU as glu on glu.ERSGroup_ID=cds.ERSCommodity_ERSGroup_ID INNER JOIN
cosd.ERSStatisticType_LU as stlu on stlu.ERSStatisticType_ID=cds.ERSCommodity_ERSStatisticType_ID INNER JOIN
cosd.ERSSource_LU as scl on scl.ERSSource_ID=dv.ERSDataValues_ERSSource_ID INNER JOIN
cosd.ERSPhysicalAttribute_LU as phlu on phlu.ERSPhysicalAttribute_ID=cds.ERSCommodity_ERSPhysicalAttribute_ID INNER JOIN
cosd.ERSUtilPractice_LU as ulu on ulu.ERSUtilPractice_ID=cds.ERSCommodity_ERSUtilPractice_ID INNER JOIN
cosd.ERSProdPractice_LU as plu on plu.ERSProdPractice_ID=cds.ERSCommodity_ERSProdPractice_ID INNER JOIN
cosd.ERSTimeDimension_LU as tlu on tlu.ERSTimeDimension_ID=dv.ERSDataValues_ERSTimeDimension_ID INNER JOIN
cosd.ERSTimeDimensionType_LU tylu on tylu.ERSTimeDimensionType_ID=tlu.ERSTimeDimension_TimeDimensionType_ID INNER JOIN
cosd.ERSGeographyDimension_LU as gglu on gglu.ERSGeographyDimension_ID=dv.ERSDataValues_ERSGeography_ID INNER JOIN
cosd.ERSGeographyType_LU as gtlu on gtlu.ERSGeographyType_ID=gglu.ERSGeographyDimension_ERSGeographyType_ID INNER JOIN
cosd.ERSUnit_LU as utlu on utlu.ERSUnit_ID=dv.ERSDataValues_ERSUnit_ID INNER JOIN
cosd.ERSDataLifecycle_LU as lflu on lflu.ERSDataLifecyclePhase_ID=dv.ERSDataValues_DataRowLifecyclePhaseID

COMMIT TRANSACTION;
PRINT '***********Insertion completed successfully***********'
RETURN 1


END TRY

BEGIN CATCH
PRINT 'FAILED'
PRINT '***********Error occured. All the above Lookup transactions are rolledback***********'
PRINT 'Error Line Number : '+CAST (ERROR_LINE() AS VARCHAR )
PRINT 'Error Message : '+Error_Message()

--Rollback the transaction if something goes wrong
ROLLBACK TRANSACTION;
RETURN 0
END CATCH


