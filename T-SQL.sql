USE [AnimalProductsCoSD]
GO
/****** Object:  StoredProcedure [CoSD].[sp_cc_to_ap]    Script Date: 4/25/2019 7:44:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [CoSD].[sp_cc_to_ap] -- Replace alter with create in case the stored procedure doesnt exist in the database
AS

--Begins the transaction
BEGIN TRANSACTION;

BEGIN TRY

/****This section updates any record from CrossCommodityCoSD which already exist in AnimalProductCosD****/
PRINT '*********************Start Conversion Factors to AP*********************'
PRINT ''

UPDATE [AnimalProductsCoSD].[CoSD].[ERSConversionFactors]
SET  [ERSConversionFactor_CF]=b.[ERSConversionFactor_CF]
	 ,[ERSConversionFactor_ERSCommodity_ID] = b.[ERSConversionFactor_ERSCommodity_ID]
     ,[ERSConversionFactor_StartYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]
     ,[ERSConversionFactor_EndYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]
     ,[ERSConversionFactor_Desc]=b.[ERSConversionFactor_Desc]
     ,[ERSConversionFactor_CFSource]=b.[ERSConversionFactor_CFSource]
     ,[ERSConversionFactor_CFMarketSegment]=b.[ERSConversionFactor_CFMarketSegment]
FROM  [AnimalProductsCoSD].[CoSD].[ERSConversionFactors] a
        INNER JOIN [CrossCommodityCoSD].[CoSD].[ERSConversionFactors] b ON
	      a.[ERSConversionFactor_ERSCommodity_ID] = b.[ERSConversionFactor_ERSCommodity_ID]
      and a.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]
      and a.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]
      and a.[ERSConversionFactor_Desc]=b.[ERSConversionFactor_Desc]
      and a.[ERSConversionFactor_CFSource]=b.[ERSConversionFactor_CFSource]
      and a.[ERSConversionFactor_CFMarketSegment]=b.[ERSConversionFactor_CFMarketSegment]

PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' Conversion Factors successfully updated in AnimalProductsCoSD'
PRINT ''

--/****This section inserts any records from CrossCommodityCoSD which does not exist in AnimalProductCosD****/

--INSERT INTO [AnimalProductsCoSD].[CoSD].[ERSConversionFactors]
--SELECT [ERSConversionFactor_ERSCommodity_ID]
--      ,[ERSConversionFactor_StartYear_ERSTimeDimension_ID]
--      ,[ERSConversionFactor_EndYear_ERSTimeDimension_ID]
--      ,[ERSConversionFactor_Desc]
--      ,[ERSConversionFactor_CF]
--      ,[ERSConversionFactor_CFSource]
--      ,[ERSConversionFactor_CFMarketSegment]
--FROM [CrossCommodityCoSD].[CoSD].[ERSConversionFactors]
--EXCEPT
--(SELECT  DISTINCT  a.[ERSConversionFactor_ERSCommodity_ID]
--      ,a.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]
--      ,a.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]
--      ,a.[ERSConversionFactor_Desc]
--      ,a.[ERSConversionFactor_CF]
--      ,a.[ERSConversionFactor_CFSource]
--      ,a.[ERSConversionFactor_CFMarketSegment]
--FROM    [AnimalProductsCoSD].[CoSD].[ERSConversionFactors] a
--        INNER JOIN [CrossCommodityCoSD].[CoSD].[ERSConversionFactors] b ON
--	      a.[ERSConversionFactor_ERSCommodity_ID] = b.[ERSConversionFactor_ERSCommodity_ID]
--      and a.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_StartYear_ERSTimeDimension_ID]
--      and a.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]=b.[ERSConversionFactor_EndYear_ERSTimeDimension_ID]
--      and a.[ERSConversionFactor_Desc]=b.[ERSConversionFactor_Desc]
--      and a.[ERSConversionFactor_CFSource]=b.[ERSConversionFactor_CFSource]
--      and a.[ERSConversionFactor_CFMarketSegment]=b.[ERSConversionFactor_CFMarketSegment])

--PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' Conversion Factors successfully inserted into AnimalProductsCoSD'
--PRINT ''
--PRINT '*********************End Conversion Factors to AP*********************'

PRINT '*********************Start CrossCommodity Data Values to AP*********************'
PRINT ''
/****This section updates any datavalues from CrossCommodityCoSD which already exist in AnimalProductCosD****/
UPDATE [AnimalProductsCoSD].[CoSD].[ERSDataValues]
SET  [ERSDataValues_AttributeValue]=b.[ERSDataValues_AttributeValue],
	 [ERSDataValues_DataRowLifecyclePhaseID]=b.[ERSDataValues_DataRowLifecyclePhaseID]
FROM  [AnimalProductsCoSD].[CoSD].[ERSDataValues] a
        INNER JOIN [CrossCommodityCoSD].[CoSD].[View_CC_DataValues] b ON
	       a.[ERSDataValues_ERSSource_ID]=b.[ERSDataValues_ERSSource_ID]
	   and a.[ERSDataValues_ERSOutput_ID]=b.[ERSDataValues_ERSOutput_ID]
	   and a.[ERSDataValues_ERSTimeDimension_ID]=b.[ERSDataValues_ERSTimeDimension_ID]
	   and a.[ERSDataValues_ERSCommodity_ID]=b.[CoSD_Destination_ID]
	   and a.[ERSDataValues_ERSDataFeedType_ID]=b.[ERSDataValues_ERSDataFeedType_ID]	
	   and a.[ERSDataValues_ERSUnit_ID]=b.[ERSDataValues_ERSUnit_ID] 
	   and a.[ERSDataValues_ERSGeography_ID]=b.[ERSDataValues_ERSGeography_ID]
	   and a.[ERSDataValues_ERSCollection_ID]=b.[ERSDataValues_ERSCollection_ID] 
	   and a.[ERSDataRowPrivacy_ID] = b.[ERSDataRowPrivacy_ID]  
	   --and a.[ERSDataValues_DataRowLifecyclePhaseID]=b.[ERSDataValues_DataRowLifecyclePhaseID]  
	-- and a.[ERSDataValues_AttributeValue_Desc]=b.[ERSDataValues_AttributeValue_Desc]
WHERE a.ERSDataValues_ERSCommodity_ID IN 

(select [ERSMappingDestination_ID] from [CrossCommodityCoSD].[CoSD].[ERSCrossCommodityMapping]
  where ERSMappingCoSD_ID = 1)

PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' Data Values successfully updated in AnimalProductsCoSD'
PRINT ''

/****This section inserts datavalues from CrossCommodityCoSD into AnimalProductCosD****/
INSERT INTO [AnimalProductsCoSD].[CoSD].[ERSDataValues]
SELECT [ERSDataValues_ERSSource_ID]
      ,[ERSDataValues_ERSOutput_ID]
      ,[ERSDataValues_ERSTimeDimension_ID]
      ,[CoSD_Destination_ID]
      ,[ERSDataValues_ERSDataFeedType_ID]
      ,[ERSDataValues_ERSUnit_ID]
      ,[ERSDataValues_ERSGeography_ID]
      ,[ERSDataValues_ERSCollection_ID]
      ,[ERSDataRowPrivacy_ID]
      ,[ERSDataValues_DataRowLifecyclePhaseID]
      ,[ERSDataValues_AttributeValue_Desc]
      ,[ERSDataValues_AttributeValue]		
FROM [CrossCommodityCoSD].[CoSD].[View_CC_DataValues]
WHERE [CoSD_Destination_ID] 
IN (SELECT ERSMappingDestination_ID FROM [CrossCommodityCoSD].[CoSD].[ERSCrossCommodityMapping]
WHERE ERSMappingCoSD_ID = 1)
EXCEPT
(SELECT  DISTINCT  a.[ERSDataValues_ERSSource_ID]
      ,a.[ERSDataValues_ERSOutput_ID]
      ,a.[ERSDataValues_ERSTimeDimension_ID]
      ,a.[ERSDataValues_ERSCommodity_ID]
      ,a.[ERSDataValues_ERSDataFeedType_ID]
      ,a.[ERSDataValues_ERSUnit_ID]
      ,a.[ERSDataValues_ERSGeography_ID]
      ,a.[ERSDataValues_ERSCollection_ID]
      ,a.[ERSDataRowPrivacy_ID]
      ,a.[ERSDataValues_DataRowLifecyclePhaseID]
      ,a.[ERSDataValues_AttributeValue_Desc]
      ,a.[ERSDataValues_AttributeValue]
FROM   [AnimalProductsCoSD].[CoSD].[ERSDataValues] a
        INNER JOIN [CrossCommodityCoSD].[CoSD].[View_CC_DataValues] b ON
	       a.[ERSDataValues_ERSSource_ID]=b.[ERSDataValues_ERSSource_ID]
	   and a.[ERSDataValues_ERSOutput_ID]=b.[ERSDataValues_ERSOutput_ID]
	   and a.[ERSDataValues_ERSTimeDimension_ID]=b.[ERSDataValues_ERSTimeDimension_ID]
	   and a.[ERSDataValues_ERSCommodity_ID]=b.[CoSD_Destination_ID]--[ERSDataValues_ERSCommodity_ID] 
	   and a.[ERSDataValues_ERSDataFeedType_ID]=b.[ERSDataValues_ERSDataFeedType_ID]	
	   and a.[ERSDataValues_ERSUnit_ID]=b.[ERSDataValues_ERSUnit_ID] 
	   and a.[ERSDataValues_ERSGeography_ID]=b.[ERSDataValues_ERSGeography_ID]
	   and a.[ERSDataValues_ERSCollection_ID]=b.[ERSDataValues_ERSCollection_ID] 
	   and a.[ERSDataRowPrivacy_ID] = b.[ERSDataRowPrivacy_ID]  
	   and a.[ERSDataValues_DataRowLifecyclePhaseID]=b.[ERSDataValues_DataRowLifecyclePhaseID]  
	   --and a.[ERSDataValues_AttributeValue_Desc]=b.[ERSDataValues_AttributeValue_Desc]	 
	   and a.[ERSDataValues_AttributeValue]=b.[ERSDataValues_AttributeValue]
)


PRINT CAST(@@ROWCOUNT AS VARCHAR) + ' Data Values successfully inserted into AnimalProductsCoSD'
PRINT ''
PRINT '*********************End CrossCommodity Data Values to AP*********************'

PRINT ''
PRINT 'SUCCESS!!!'
PRINT 'CrossCommodity to AP executed successfully' 
--Commit the transaction if everything is successfull
COMMIT TRANSACTION;
RETURN 1
END TRY

BEGIN CATCH
PRINT 'FAILED!!!'
PRINT '************************Error occured. All the above transactions are rolledback************************'
PRINT 'Error Line Number : '+CAST (ERROR_LINE() AS VARCHAR )
PRINT 'Error Message : '+Error_Message()

--Rollback the transaction if something goes wrong
ROLLBACK TRANSACTION;
RETURN 0
END CATCH


