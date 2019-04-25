SELECT        ROW_NUMBER() OVER (ORDER BY CASE DataSeriesID WHEN - 1 THEN 1 WHEN 0 THEN 1 END) AS ID, DataSeriesID, CommodtiySubCommodityID, Commodity, SubCommodity, SectorID, Sector, GroupID, GroupName, 
StatisticTypeID, StatisticType, SourceID, Source, SourceDescription, PhysicalAttributeTypeID, PhysicalAttributeType, PhysicalAttributeDesc, UtilizationPracticeID, UtilizationPractice, ProductionPracticeID, ProductionPractice, 
SourceSeriesID, TimeID, FrequencyID, TimeFrequency, [Date], GeographyID, GeographyTypeID, GeographyType, City, County, [State], Region, Country, UnitID, Unit, LifecyclePhaseID, LifecyclePhaseDescription, Value,PrivacyID,PrivacyDesc
FROM            (SELECT DISTINCT 
                                                    dv.ERSDataValues_ERSCommodity_ID AS DataSeriesID, cds.ERSCommoditySubCommodity_ID AS CommodtiySubCommodityID, CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) 
                                                    > 0 THEN SUBSTRING(csc.ERSCommoditySubCommodity_Desc, 1, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) - 1) ELSE csc.ERSCommoditySubCommodity_Desc END Commodity, 
                                                    CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) > 0 THEN LTRIM(SUBSTRING(csc.ERSCommoditySubCommodity_Desc, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) + 1, 
                                                    len(csc.ERSCommoditySubCommodity_Desc))) ELSE 'No SubCommodity' END AS SubCommodity, su.ERSSector_ID AS SectorID, su.ERSSector_Desc AS Sector, gu.ERSGroup_ID AS GroupID, 
                                                    gu.ERSGroup_Desc AS GroupName, stu.ERSStatisticType_ID AS StatisticTypeID, stu.ERSStatisticType_Attribute AS StatisticType, slu.ERSSource_ID AS SourceID, slu.ERSSource_Desc AS Source, 
                                                    slu.ERSSource_LongDesc AS SourceDescription, phlu.ERSPhysicalAttribute_ID AS PhysicalAttributeTypeID, phlu.ERSPhysicalAttribute_Desc AS PhysicalAttributeType, 
                                                    cds.ERSCommodity_PhysicalAttribute_Desc AS PhysicalAttributeDesc, upu.ERSUtilPractice_ID AS UtilizationPracticeID, upu.ERSUtilPractice_Desc AS UtilizationPractice, 
                                                    pu.ERSProdPractice_ID AS ProductionPracticeID, pu.ERSProdPractice_Desc AS ProductionPractice, CASE WHEN cds.ERSCommodity_SourceSeriesID IS NULL 
                                                    THEN 'No SourceSeriesID' ELSE cds.ERSCommodity_SourceSeriesID END AS SourceSeriesID, tu.ERSTimeDimension_ID AS TimeID, tu.ERSTimeDimension_TimeDimensionType_ID AS FrequencyID, 
                                                    Replace(tdt.ERSTimeDimensionType_Desc, 'ERS', '') AS TimeFrequency, tu.ERSTimeDimension_Date AS DATE, gdu.ERSGeographyDimension_ID AS GeographyID, 
                                                    gdu.ERSGeographyDimension_ERSGeographyType_ID AS GeographyTypeID, gtu.ERSGeographyType_Desc AS GeographyType, CASE WHEN COALESCE (gdu.ERSGeographyDimension_City, '') 
                                                    = '' THEN 'No City' ELSE gdu.ERSGeographyDimension_City END AS City, CASE WHEN COALESCE (gdu.ERSGeographyDimension_County, '') 
                                                    = '' THEN 'No County' ELSE gdu.ERSGeographyDimension_County END AS County, CASE WHEN COALESCE (gdu.ERSGeographyDimension_State, '') 
                                                    = '' THEN 'No State' ELSE gdu.ERSGeographyDimension_State END AS STATE, CASE WHEN COALESCE (gdu.ERSGeographyDimension_Region, '') 
                                                    = '' THEN 'No Region' ELSE gdu.ERSGeographyDimension_Region END AS Region, CASE WHEN COALESCE (gdu.ERSGeographyDimension_Country, '') 
                                                    = '' THEN 'No Country' ELSE gdu.ERSGeographyDimension_Country END AS Country, ulu.ERSUnit_ID AS UnitID, ulu.ERSUnit_Desc AS Unit, dv.ERSDataValues_DataRowLifecyclePhaseID AS LifecyclePhaseID, 
                                                    dlu.ERSDataLifecyclePhase_Desc AS LifecyclePhaseDescription, dv.ERSDataValues_AttributeValue AS Value,plu.ERSDataPrivacy_ID as PrivacyID,plu.ERSDataPrivacy_Desc as PrivacyDesc
                          FROM            CoSD.ERSCommodityDataSeries AS cds INNER JOIN
                                                    cosd.ERSPhysicalAttribute_LU AS phlu ON phlu.ERSPhysicalAttribute_ID = cds.ERSCommodity_ERSPhysicalAttribute_ID INNER JOIN
                                                    CoSD.ERSDataValues AS dv ON cds.ERSCommodity_ID = dv.ERSDataValues_ERSCommodity_ID INNER JOIN
                                                    CoSD.ERSSector_LU AS su ON cds.ERSCommodity_ERSSector_ID = su.ERSSector_ID INNER JOIN
                                                    CoSD.ERSGroup_LU AS gu ON cds.ERSCommodity_ERSGroup_ID = gu.ERSGroup_ID INNER JOIN
                                                    CoSD.ERSProdPractice_LU AS pu ON cds.ERSCommodity_ERSProdPractice_ID = pu.ERSProdPractice_ID INNER JOIN
                                                    CoSD.ERSUtilPractice_LU AS upu ON cds.ERSCommodity_ERSUtilPractice_ID = upu.ERSUtilPractice_ID AND cds.ERSCommodity_ERSUtilPractice_ID = upu.ERSUtilPractice_ID INNER JOIN
                                                    CoSD.ERSUnit_LU AS ulu ON dv.ERSDataValues_ERSUnit_ID = ulu.ERSUnit_ID INNER JOIN
                                                    CoSD.ERSSource_LU AS slu ON cds.ERSCommodity_ERSSource_ID = slu.ERSSource_ID INNER JOIN
                                                    CoSD.ERSStatisticType_LU AS stu ON cds.ERSCommodity_ERSStatisticType_ID = stu.ERSStatisticType_ID INNER JOIN
                                                    CoSD.ERSTimeDimension_LU AS tu ON dv.ERSDataValues_ERSTimeDimension_ID = tu.ERSTimeDimension_ID INNER JOIN
                                                    CoSD.ERSGeographyDimension_LU AS gdu ON dv.ERSDataValues_ERSGeography_ID = gdu.ERSGeographyDimension_ID INNER JOIN
                                                    CoSD.ERSTimeDimensionType_LU AS tdt ON tu.ERSTimeDimension_TimeDimensionType_ID = tdt.ERSTimeDimensionType_ID INNER JOIN
                                                    CoSD.ERSGeographyType_LU AS gtu ON gdu.ERSGeographyDimension_ERSGeographyType_ID = gtu.ERSGeographyType_ID INNER JOIN
                                                    CoSD.ERSCommoditySubCommodity_LU AS csc ON csc.ERSCommoditySubCommodity_ID = cds.ERSCommoditySubCommodity_ID INNER JOIN
                                                    cosd.ERSDataLifecycle_LU AS dlu ON dlu.ERSDataLifecyclePhase_ID = dv.ERSDataValues_DataRowLifecyclePhaseID INNER JOIN
													cosd.ERSDataPrivacy_LU as plu on plu.ERSDataPrivacy_ID=dv.ERSDataRowPrivacy_ID
                          WHERE        dv.ERSDataRowPrivacy_ID in (1,5) AND dv.ERSDataValues_AttributeValue IS NOT NULL
                          UNION ALL
                          SELECT DISTINCT 
                                                   cds.ERSCommodity_ID AS DataSeriesID, csc.ERSCommoditySubCommodity_ID AS CommodtiySubCommodityID, CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) 
                                                   > 0 THEN SUBSTRING(csc.ERSCommoditySubCommodity_Desc, 1, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) - 1) ELSE csc.ERSCommoditySubCommodity_Desc END Commodity, 
                                                   CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) > 0 THEN LTRIM(SUBSTRING(csc.ERSCommoditySubCommodity_Desc, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) + 1, 
                                                   len(csc.ERSCommoditySubCommodity_Desc))) ELSE 'No SubCommodity' END AS SubCommodity, slu.ERSSector_ID AS SectorID, slu.ERSSector_Desc AS Sector, glu.ERSGroup_ID AS GroupID, 
                                                   glu.ERSGroup_Desc AS GroupName, stu.ERSStatisticType_ID AS StatisticTypeID, stu.ERSStatisticType_Attribute AS StatisticType, selu.ERSSource_ID AS SourceID, 
                                                   cvo.ERSConstructedVariable_InputSources AS Source, selu.ERSSource_LongDesc AS SourceDescription, cds.ERSCommodity_ERSPhysicalAttribute_ID AS PhysicalAttributeTypeID, 
                                                   phlu.ERSPhysicalAttribute_Desc AS PhysicalAttributeType, cds.ERSCommodity_PhysicalAttribute_Desc AS PhysicalAttributeDesc, ulu.ERSUtilPractice_ID AS UtilizationPracticeID, 
                                                   ulu.ERSUtilPractice_Desc AS UtilizationPractice, plu.ERSProdPractice_ID AS ProductionPracticeID, plu.ERSProdPractice_Desc AS ProductionPractice, 
                                                   CASE WHEN cds.ERSCommodity_SourceSeriesID LIKE '%(N%' THEN 'No SourceSeriesID' ELSE cds.ERSCommodity_SourceSeriesID END AS SourceSeriesID, tlu.ERSTimeDimension_ID AS TimeID, 
                                                   tlu.ERSTimeDimension_TimeDimensionType_ID AS FrequncyID, replace(tdlu.ERSTimeDimensionType_Desc, 'ERS', '') AS TimeFrequency, cvo.ERSConstructedVariable_TimeDimensionDate AS DATE, 
                                                   gdlu.ERSGeographyDimension_ID AS GeographyID, gdlu.ERSGeographyDimension_ERSGeographyType_ID AS GeographyTypeID, gtlu.ERSGeographyType_Desc AS GeographyType, 
                                                   CASE WHEN COALESCE (gdlu.ERSGeographyDimension_City, '') = '' THEN 'No City' ELSE gdlu.ERSGeographyDimension_City END AS City, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_County, '') 
                                                   = '' THEN 'No County' ELSE gdlu.ERSGeographyDimension_County END AS County, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_State, '') 
                                                   = '' THEN 'No State' ELSE gdlu.ERSGeographyDimension_State END AS STATE, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_Region, '') 
                                                   = '' THEN 'No Region' ELSE gdlu.ERSGeographyDimension_Region END AS Region, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_Country, '') 
                                                   = '' THEN 'No Country' ELSE gdlu.ERSGeographyDimension_Country END AS Country, unlu.ERSUnit_ID AS UnitID, unlu.ERSUnit_Desc AS Unit, 
                                                   cvo.ERSConstructedVariable_DataRowLifecyclePhaseID AS LifecyclePhaseID, dlu.ERSDataLifecyclePhase_Desc AS LifecyclePhaseDescription, cvo.ERSConstructedVariable_OutputValue AS Value,pplu.ERSDataPrivacy_ID as PrivacyID,pplu.ERSDataPrivacy_Desc as PrivacyDesc
                          FROM            CoSD.ERSConstructedVariablesOutcomes AS cvo INNER JOIN
                                                   CoSD.ERSCommodityDataSeries AS cds ON cvo.ERSConstructedVariable_NewDataSeriesID = cds.ERSCommodity_ID INNER JOIN
                                                   cosd.ERSPhysicalAttribute_LU AS phlu ON phlu.ERSPhysicalAttribute_ID = cds.ERSCommodity_ERSPhysicalAttribute_ID INNER JOIN
                                                   CoSD.ERSSector_LU AS slu ON cds.ERSCommodity_ERSSector_ID = slu.ERSSector_ID INNER JOIN
                                                   CoSD.ERSGroup_LU AS glu ON cds.ERSCommodity_ERSGroup_ID = glu.ERSGroup_ID INNER JOIN
                                                   CoSD.ERSCommoditySubCommodity_LU AS csc ON cds.ERSCommoditySubCommodity_ID = csc.ERSCommoditySubCommodity_ID INNER JOIN
                                                   CoSD.ERSStatisticType_LU AS stu ON cds.ERSCommodity_ERSStatisticType_ID = stu.ERSStatisticType_ID INNER JOIN
                                                   CoSD.ERSUtilPractice_LU AS ulu ON cds.ERSCommodity_ERSUtilPractice_ID = ulu.ERSUtilPractice_ID INNER JOIN
                                                   CoSD.ERSProdPractice_LU AS plu ON cds.ERSCommodity_ERSProdPractice_ID = plu.ERSProdPractice_ID INNER JOIN
                                                   CoSD.ERSGeographyDimension_LU AS gdlu ON cvo.ERSConstructedVariable_OutputGeographyDimensionID = gdlu.ERSGeographyDimension_ID INNER JOIN
                                                   CoSD.ERSUnit_LU AS unlu ON cvo.ERSConstructedVariable_OutputUnitID = unlu.ERSUnit_ID INNER JOIN
                                                   CoSD.ERSGeographyType_LU AS gtlu ON gdlu.ERSGeographyDimension_ERSGeographyType_ID = gtlu.ERSGeographyType_ID INNER JOIN
                                                   cosd.ERSTimeDimension_LU AS tlu ON tlu.ERSTimeDimension_ID = cvo.ERSConstructedVariable_TimeDimensionID AND tlu.ERSTimeDimension_Date = cvo.ERSConstructedVariable_TimeDimensionDate AND 
                                                   year(tlu.ERSTimeDimension_Date) = year(cvo.ERSConstructedVariable_TimeDimensionDate) AND month(tlu.ERSTimeDimension_Date) = month(ERSConstructedVariable_TimeDimensionDate) INNER JOIN
                                                   cosd.ERSTimeDimensionType_LU AS tdlu ON tdlu.ERSTimeDimensionType_ID = tlu.ERSTimeDimension_TimeDimensionType_ID INNER JOIN
                                                   cosd.ERSSource_LU AS selu ON cvo.ERSConstructedVariable_InputSourceID = selu.ERSSource_ID INNER JOIN
                                                   cosd.ERSDataLifecycle_LU dlu ON dlu.ERSDataLifecyclePhase_ID = cvo.ERSConstructedVariable_DataRowLifecyclePhaseID INNER JOIN
												   cosd.ERSDataPrivacy_LU as pplu on pplu.ERSDataPrivacy_ID=cvo.ERSConstructedVariable_DataRowPrivacyID
                          WHERE        cvo.ERSConstructedVariable_DataRowPrivacyID in (1,5) AND cvo.ERSConstructedVariable_NewDataSeriesID IS NOT NULL AND cvo.ERSConstructedVariable_OutputValue IS NOT NULL
                          UNION ALL
                          SELECT DISTINCT 
                                                   cds.ERSCommodity_ID AS DataSeriesID, csc.ERSCommoditySubCommodity_ID AS CommoditySubCommodityID, CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) 
                                                   > 0 THEN SUBSTRING(csc.ERSCommoditySubCommodity_Desc, 1, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) - 1) ELSE csc.ERSCommoditySubCommodity_Desc END Commodity, 
                                                   CASE WHEN CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) > 0 THEN LTRIM(SUBSTRING(csc.ERSCommoditySubCommodity_Desc, CHARINDEX(',', csc.ERSCommoditySubCommodity_Desc) + 1, 
                                                   len(csc.ERSCommoditySubCommodity_Desc))) ELSE 'No SubCommodity' END AS SubCommodity, slu.ERSSector_ID AS SectorID, slu.ERSSector_Desc AS Sector, glu.ERSGroup_ID AS GroupID, 
                                                   glu.ERSGroup_Desc AS GroupName, stu.ERSStatisticType_ID AS StatisticTypeID, stu.ERSStatisticType_Attribute AS StatisticType, selu.ERSSource_ID AS SourceID, 
                                                   cvo.ERSConstructedVariable_InputSources AS Source, selu.ERSSource_LongDesc AS SourceDescription, cds.ERSCommodity_ERSPhysicalAttribute_ID AS PhysicalAttributeTypeID, 
                                                   phlu.ERSPhysicalAttribute_Desc AS PhysicalAttributeType, cds.ERSCommodity_PhysicalAttribute_Desc AS PhysicalAttributeDesc, ulu.ERSUtilPractice_ID AS UtilizationPracticeID, 
                                                   ulu.ERSUtilPractice_Desc AS UtilizationPractice, plu.ERSProdPractice_ID AS ProductionPracticeID, plu.ERSProdPractice_Desc AS ProductionPractice, CASE WHEN cds.ERSCommodity_SourceSeriesID IS NULL 
                                                   THEN 'No SourceSeriesID' ELSE cds.ERSCommodity_SourceSeriesID END AS SourceSeriesID, tlu.ERSTimeDimension_ID AS TimeID, tlu.ERSTimeDimension_TimeDimensionType_ID AS FrequencyID, 
                                                   replace(tdlu.ERSTimeDimensionType_Desc, 'ERS', '') AS TimeFrequency, cvo.ERSConstructedVariable_TimeDimensionDate AS DATE, gdlu.ERSGeographyDimension_ID AS GeographyID, 
                                                   gdlu.ERSGeographyDimension_ERSGeographyType_ID AS GeographyTypeID, gtlu.ERSGeographyType_Desc AS GeographyType, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_City, '') 
                                                   = '' THEN 'No City' ELSE gdlu.ERSGeographyDimension_City END AS City, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_County, '') 
                                                   = '' THEN 'No County' ELSE gdlu.ERSGeographyDimension_County END AS County, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_State, '') 
                                                   = '' THEN 'No State' ELSE gdlu.ERSGeographyDimension_State END AS STATE, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_Region, '') 
                                                   = '' THEN 'No Region' ELSE gdlu.ERSGeographyDimension_Region END AS Region, CASE WHEN COALESCE (gdlu.ERSGeographyDimension_Country, '') 
                                                   = '' THEN 'No Country' ELSE gdlu.ERSGeographyDimension_Country END AS Country, unlu.ERSUnit_ID AS UnitID, unlu.ERSUnit_Desc AS Unit, 
                                                   cvo.ERSConstructedVariable_DataRowLifecyclePhaseID AS LifecyclePhaseID, dlu.ERSDataLifecyclePhase_Desc AS LifecyclePhaseDescription, cvo.ERSConstructedVariable_OutputValue AS Value,pplu.ERSDataPrivacy_ID as PrivacyID,pplu.ERSDataPrivacy_Desc as PrivacyDesc
                          FROM            CoSD.ERSConstructedVariablesOutcomes AS cvo INNER JOIN
                                                   CoSD.ERSBusinessLogic AS BL ON cvo.ERSConstructedVariable_BusinessLogicID = bl.ERSBusinessLogic_ID INNER JOIN
                                                   cosd.ERSCommodityDataSeries AS CDS ON CDS.ERSCommodity_ID = Bl.ERSBusinessLogic_InputDataSeries INNER JOIN
                                                   cosd.ERSPhysicalAttribute_LU AS phlu ON phlu.ERSPhysicalAttribute_ID = cds.ERSCommodity_ERSPhysicalAttribute_ID INNER JOIN
                                                   CoSD.ERSSector_LU AS slu ON cds.ERSCommodity_ERSSector_ID = slu.ERSSector_ID INNER JOIN
                                                   CoSD.ERSGroup_LU AS glu ON cds.ERSCommodity_ERSGroup_ID = glu.ERSGroup_ID INNER JOIN
                                                   CoSD.ERSCommoditySubCommodity_LU AS csc ON cds.ERSCommoditySubCommodity_ID = csc.ERSCommoditySubCommodity_ID INNER JOIN
                                                   CoSD.ERSStatisticType_LU AS stu ON cds.ERSCommodity_ERSStatisticType_ID = stu.ERSStatisticType_ID INNER JOIN
                                                   CoSD.ERSUtilPractice_LU AS ulu ON cds.ERSCommodity_ERSUtilPractice_ID = ulu.ERSUtilPractice_ID INNER JOIN
                                                   CoSD.ERSProdPractice_LU AS plu ON cds.ERSCommodity_ERSProdPractice_ID = plu.ERSProdPractice_ID INNER JOIN
                                                   CoSD.ERSGeographyDimension_LU AS gdlu ON cvo.ERSConstructedVariable_OutputGeographyDimensionID = gdlu.ERSGeographyDimension_ID INNER JOIN
                                                   CoSD.ERSUnit_LU AS unlu ON cvo.ERSConstructedVariable_OutputUnitID = unlu.ERSUnit_ID INNER JOIN
                                                   CoSD.ERSGeographyType_LU AS gtlu ON gdlu.ERSGeographyDimension_ERSGeographyType_ID = gtlu.ERSGeographyType_ID INNER JOIN
                                                   cosd.ERSTimeDimension_LU AS tlu ON tlu.ERSTimeDimension_ID = cvo.ERSConstructedVariable_TimeDimensionID AND tlu.ERSTimeDimension_Date = cvo.ERSConstructedVariable_TimeDimensionDate AND 
                                                   year(tlu.ERSTimeDimension_Date) = year(cvo.ERSConstructedVariable_TimeDimensionDate) AND month(tlu.ERSTimeDimension_Date) = month(ERSConstructedVariable_TimeDimensionDate) INNER JOIN
                                                   cosd.ERSTimeDimensionType_LU AS tdlu ON tdlu.ERSTimeDimensionType_ID = tlu.ERSTimeDimension_TimeDimensionType_ID INNER JOIN
                                                   cosd.ERSSource_LU AS selu ON cvo.ERSConstructedVariable_InputSourceID = selu.ERSSource_ID INNER JOIN
                                                   cosd.ERSDataLifecycle_LU dlu ON dlu.ERSDataLifecyclePhase_ID = cvo.ERSConstructedVariable_DataRowLifecyclePhaseID INNER JOIN
												     cosd.ERSDataPrivacy_LU as pplu on pplu.ERSDataPrivacy_ID=cvo.ERSConstructedVariable_DataRowPrivacyID
                          WHERE        cvo.ERSConstructedVariable_DataRowPrivacyID in (1,5) AND BL.ERSBusinessLogic_InputsCount = 1 AND bl.ERSBusinessLogic_InputDataSeries NOT LIKE '%CV%' AND 
                                                   cvo.ERSConstructedVariable_NewDataSeriesID IS NULL AND cvo.ERSConstructedVariable_OutputValue IS NOT NULL
                          UNION ALL
                          SELECT DISTINCT 
                                                   CASE WHEN ERSMacro_Desc = 'GDP Deflators' THEN '-1' ELSE 0 END AS DataSeriesID, CASE WHEN ERSMacro_LongDesc = 'U.S. GDP Deflators' THEN '-1' ELSE 0 END AS CommodtiySubCommodityID, 
                                                   ERSMacro_Desc AS Commodity, ERSMacro_LongDesc AS SubCommodity, '4' AS SectorID, 'Macro' AS Sector, '17' AS GroupID, 'Macro' AS GroupName, 
                                                   CASE WHEN ERSMacro_Desc = 'GDP Deflators' THEN 226 ELSE 126 END AS StatisticTypeID, CASE WHEN ERSMacro_Desc = 'GDP Deflators' THEN 'GDP Deflators' ELSE 'U.S. population' END AS StatisticType, 
                                                   slu.ERSSource_ID AS SourceID, slu.ERSSource_Desc AS Source, slu.ERSSource_LongDesc AS SourceDescription, '17' AS PhysicalAttributeTypeID, 'No PhysicalAttributeType' AS PhysicalAttributeType, 
                                                   'No Physical Attribute' AS PhysicalAttributeDesc, '744' AS UtilizationPracticeID, 'No UtilizationPractice' AS UtilizationPractice, '80' AS ProductionPracticeID, 'No ProductionPractice' AS ProductionPractice, 
                                                   'No SourceSeriesID' AS SourceSeriesID, tlu.ERSTimeDimension_ID AS TimeID, tlu.ERSTimeDimension_TimeDimensionType_ID AS FrequencyID, replace(ttlu.ERSTimeDimensionType_Desc, 'ERS', '') 
                                                   AS TimeFrequency, tlu.ERSTimeDimension_Date AS DATE, glu.ERSGeographyDimension_ID AS GeographyID, glu.ERSGeographyDimension_ERSGeographyType_ID AS GeographyTypeID, 
                                                   gtlu.ERSGeographyType_Desc AS GeographyType, CASE WHEN COALESCE (glu.ERSGeographyDimension_City, '') = '' THEN 'No City' ELSE glu.ERSGeographyDimension_City END AS City, 
                                                   CASE WHEN COALESCE (glu.ERSGeographyDimension_County, '') = '' THEN 'No County' ELSE glu.ERSGeographyDimension_County END AS County, CASE WHEN COALESCE (glu.ERSGeographyDimension_State, '')
                                                    = '' THEN 'No State' ELSE glu.ERSGeographyDimension_State END AS STATE, CASE WHEN COALESCE (glu.ERSGeographyDimension_Region, '') 
                                                   = '' THEN 'No Region' ELSE glu.ERSGeographyDimension_Region END AS Region, CASE WHEN COALESCE (glu.ERSGeographyDimension_Country, '') 
                                                   = '' THEN 'No Country' ELSE glu.ERSGeographyDimension_Country END AS Country, ulu.ERSUnit_ID AS UnitID, ulu.ERSUnit_Desc AS Unit, 
                                                   CASE WHEN ERSMacro_Desc = 'GDP Deflators' THEN '-1' ELSE 0 END AS LifecyclePhaseID, 'No LifecyclePhaseDescription' AS LifecyclePhaseDescription, mlu.ERSMacro_Value AS Value, CASE WHEN ERSMacro_LongDesc = 'U.S. GDP Deflators' THEN '-1' ELSE 0 END AS PrivacyID,CASE WHEN ERSMacro_Desc = 'GDP Deflators' THEN 'GDP Deflators' ELSE 'U.S. population' END AS PrivacyDesc
                          FROM            cosd.ERSMacro_LU mlu INNER JOIN
                                                   cosd.ERSSource_LU slu ON slu.ERSSource_ID = mlu.ERSMacro_Source_ID INNER JOIN
                                                   cosd.ERSTimeDimension_LU tlu ON tlu.ERSTimeDimension_ID = mlu.ERSMacro_TimeDimension_ID INNER JOIN
                                                   cosd.ERSTimeDimensionType_LU ttlu ON ttlu.ERSTimeDimensionType_ID = tlu.ERSTimeDimension_TimeDimensionType_ID INNER JOIN
                                                   cosd.ERSGeographyDimension_LU glu ON glu.ERSGeographyDimension_ID = mlu.ERSMacro_GeographyDimension_ID INNER JOIN
                                                   cosd.ERSGeographyType_LU gtlu ON gtlu.ERSGeographyType_ID = glu.ERSGeographyDimension_ERSGeographyType_ID INNER JOIN
                                                   cosd.ERSUnit_LU ulu ON ulu.ERSUnit_ID = mlu.ERSMacro_Unit_ID) AS derived