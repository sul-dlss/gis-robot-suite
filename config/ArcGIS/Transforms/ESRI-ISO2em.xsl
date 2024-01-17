<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:et="http://www.esri.com/metadata/translator/transform/" xmlns:r="http://www.esri.com/metadata/translator/reader/" xmlns:em="http://www.esri.com/metadata/translator/instance/" xmlns:es="http://www.esri.com/metadata/translator/schema/" xmlns:gen="http://www.esri.com/metadata/translator/autogen/" xmlns:v="http://www.esri.com/metadata/translator/var/" xmlns="http://www.esri.com/metadata/translator/transform/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:srv="http://www.isotc211.org/2005/srv">
<xsl:variable name="RESOURCE_META" select="concat ('gen:',generate-id(/MD_Metadata), 'RESOURCE_META')" />
<xsl:variable name="RESOURCE" select="concat ('gen:',generate-id(/MD_Metadata), 'RESOURCE')" />
<!--== root ==-->
<xsl:template match="/">
<xsl:param name="subject" />
<r:mode>
<xsl:for-each select="*/@xml:base">
<xsl:attribute name="xml:base">
<xsl:value-of select="." />
</xsl:attribute>
</xsl:for-each>
<r:assert relation="em:Metadata">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
</r:assert>
<r:assert relation="em:Resource">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
</r:assert>
<xsl:apply-templates />
</r:mode>
</xsl:template>
<!--== MD_Metadata ==-->
<xsl:template match="metadata">
<xsl:param name="subject" />
<xsl:for-each select="Esri/PublishedDocID">
<r:assert relation="em:esriPublishedDocID">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Esri/MetaID">
<r:assert relation="em:esriMetaID">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Esri/ArcGISFormat">
<r:assert relation="em:arcgisFormat">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Esri/ArcGISProfile">
<r:assert relation="em:arcgisProfile">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Esri/DataProperties/itemProps/imsContentType[(text() = '001') or (text() = '002') or (text() = '003') or (text() = '004') or (text() = '005') or (text() = '006') or (text() = '007') or (text() = '008') or (text() = '009') or (text() = '010')]">
<r:assert relation="em:onLineDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="distInfo/distributor/distorTran/onLineSrc/orDesc[not(/metadata/Esri/DataProperties/itemProps/imsContentType) and ((text() = '001') or (text() = '002') or (text() = '003') or (text() = '004') or (text() = '005') or (text() = '006') or (text() = '007') or (text() = '008') or (text() = '009') or (text() = '010'))]">
<r:assert relation="em:onLineDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdFileID">
<r:assert relation="em:fileIdentifier">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdLang/languageCode/@value">
<r:assert relation="em:language">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdChar/CharSetCd">
<r:assert relation="em:characterSet">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdParentID">
<r:assert relation="em:parentFileIdentifier">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdHrLv/ScopeCd">
<r:assert relation="em:hierarchyLevel">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdHrLvName">
<r:assert relation="em:hierarchyLevelName">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdContact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:contact">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdDateSt">
<r:assert relation="em:dateStamp">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdStanName">
<r:assert relation="em:metadataStandardName">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="mdStanVer">
<r:assert relation="em:metadataStandardVersion">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataSetURI">
<r:assert relation="em:dataSetURI">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Esri/locales/locale">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:locale">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_Locale">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="Esri/locales">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:locale">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_Locale">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="spatRepInfo/GridSpatRep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:gridSpatialRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_GridSpatialRepresentation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="spatRepInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:gridSpatialRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_GridSpatialRepresentation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="spatRepInfo/Georect">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:georectifiedRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Georectified">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="spatRepInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:georectifiedRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Georectified">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="spatRepInfo/Georef">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:georeferenceableRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Georeferenceable">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="spatRepInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:georeferenceableRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Georeferenceable">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="spatRepInfo/VectSpatRep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:vectorSpatialRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_VectorSpatialRepresentation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="spatRepInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:vectorSpatialRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_VectorSpatialRepresentation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="refSysInfo/RefSystem/refSysID">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:referenceSystemInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="RS_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdExtInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:metadataExtensionInfo">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MetadataExtensionInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dataIdInfo[not(svType or svTypeVer or svAccProps or svExt or svCouplRes or svCouplType or svOper or svOperOn)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:identificationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DataIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dataIdInfo[svType or svTypeVer or svAccProps or svExt or svCouplRes or svCouplType or svOper or svOperOn]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:serviceIdentificationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_ServiceIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svIdInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:serviceIdentificationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_ServiceIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="contInfo/ImgDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:imageDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ImageDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="contInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:imageDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ImageDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="contInfo/CovDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:coverageDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_CoverageDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="contInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:coverageDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_CoverageDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="contInfo/FetCatDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:featureCatalogueDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_FeatureCatalogueDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="contInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:featureCatalogueDescription">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_FeatureCatalogueDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distInfo[(count(.//*[text()]) - count(./distributor/distorTran/onLineSrc/orDesc[starts-with(.,'0')])) &gt; 0]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributionInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distribution">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:dataQualityInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_DataQuality">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="porCatInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:portrayalCatalogueInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_PortrayalCatalogueReference">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdConst/LegConsts">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:legalConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_LegalConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="mdConst">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:legalConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_LegalConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdConst/SecConsts">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:securityConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_SecurityConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="mdConst">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:securityConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_SecurityConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdConst/Consts/useLimit">
<r:assert relation="em:useLimitation">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="appSchInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:applicationSchemaInfo">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ApplicationSchemaInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="mdMaint">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:metadataMaintenance">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MaintenanceInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== PT_Locale ==-->
<xsl:template name="PT_Locale">
<xsl:param name="subject" />
<xsl:for-each select="@language">
<r:assert relation="em:languageCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="@country">
<r:assert relation="em:countryCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="@encoding">
<r:assert relation="em:characterEncoding">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_MetadataExtensionInformation ==-->
<xsl:template name="MD_MetadataExtensionInformation">
<xsl:param name="subject" />
<xsl:for-each select="extOnRes[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://'))]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extensionOnLineResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="extEleInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extendedElementInformation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ExtendedElementInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_ExtendedElementInformation ==-->
<xsl:template name="MD_ExtendedElementInformation">
<xsl:param name="subject" />
<xsl:for-each select="extEleName">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extShortName">
<r:assert relation="em:shortName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extDomCode">
<r:assert relation="em:domainCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleDef">
<r:assert relation="em:definition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleOb/ObCd">
<r:assert relation="em:obligation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleCond">
<r:assert relation="em:condition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eleDataType/DatatypeCd">
<r:assert relation="em:dataType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleMxOc">
<r:assert relation="em:maximumOccurrence">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleDomVal">
<r:assert relation="em:domainValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleParEnt">
<r:assert relation="em:parentEntity">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleRule">
<r:assert relation="em:rule">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleRat">
<r:assert relation="em:rationale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="extEleSrc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_ApplicationSchemaInformation ==-->
<xsl:template name="MD_ApplicationSchemaInformation">
<xsl:param name="subject" />
<xsl:for-each select="asName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="asSchLang">
<r:assert relation="em:schemaLanguage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="asCstLang">
<r:assert relation="em:constraintLanguage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="asAscii">
<r:assert relation="em:schemaAscii">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="asGraFile">
<r:assert relation="em:graphicsFile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-binary" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="asSwDevFile">
<r:assert relation="em:softwareDevelopmentFile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-binary" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="asSwDevFiFt">
<r:assert relation="em:softwareDevelopmentFileFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Distribution ==-->
<xsl:template name="MD_Distribution">
<xsl:param name="subject" />
<xsl:for-each select="distributor[(count(.//*[text()]) - count(./distorTran/onLineSrc/orDesc[starts-with(.,'0')])) &gt; 0][((count(.//*[text()]) - (count(./distorTran/onLineSrc[not((starts-with(linkage,'http://') or starts-with(linkage,'ftp://')))]/*[text()]))) &gt; 0)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distributor">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distFormat">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributionFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distTranOps[unitsODist | transSize | onLineSrc | offLineMed][((count(unitsODist[text()]) + count(transSize[text()]) + count(offLineMed/*[text()]) + count(onLineSrc[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://'))]/*[text()])) &gt; 0)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:transferOptions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DigitalTransferOptions">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_DataQuality ==-->
<xsl:template name="DQ_DataQuality">
<xsl:param name="subject" />
<xsl:for-each select="dqScope">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:scope">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Scope">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQCompOm'] | dqReport[@type = 'DQCompOm']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:completenessOmissionReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQCompOm')]/DQCompOm">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:completenessOmissionReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQCompOm')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:completenessOmissionReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQCompComm'] | dqReport[@type = 'DQCompComm']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:completenessCommissionReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQCompComm')]/DQCompComm">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:completenessCommissionReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQTopConsis'] | dqReport[@type = 'DQTopConsis']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:topologicalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTopConsis')]/DQTopConsis">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:topologicalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTopConsis')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:topologicalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQFormConsis'] | dqReport[@type = 'DQFormConsis']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:formatConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQFormConsis')]/DQFormConsis">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:formatConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQFormConsis')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:formatConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQDomConsis'] | dqReport[@type = 'DQDomConsis']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:domainConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[(@type = 'DQDomConsis')]/DQDomConsis">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:domainConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[(@type = 'DQDomConsis')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:domainConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQConcConsis'] | dqReport[@type = 'DQConcConsis']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:conceptualConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQConcConsis')]/DQConcConsis">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:conceptualConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQConcConsis')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:conceptualConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQRelIntPosAcc'] | dqReport[@type = 'DQRelIntPosAcc']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:relativeInternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQRelIntPosAcc')]/DQRelIntPosAcc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:relativeInternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQRelIntPosAcc')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:relativeInternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQGridDataPosAcc'] | dqReport[@type = 'DQGridDataPosAcc']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:griddedDataPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQGridDataPosAcc')]/DQGridDataPosAcc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:griddedDataPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQGridDataPosAcc')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:griddedDataPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQAbsExtPosAcc'] | dqReport[@type = 'DQAbsExtPosAcc']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:absoluteExternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report/@dimension">
<r:assert relation="em:absoluteExternalPositionalAccuracyReportDimension">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQAbsExtPosAcc')]/DQAbsExtPosAcc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:absoluteExternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQAbsExtPosAcc')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:absoluteExternalPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQQuanAttAcc'] | dqReport[@type = 'DQQuanAttAcc']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:quantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQQuanAttAcc')]/DQQuanAttAcc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:quantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQQuanAttAcc')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:quantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQNonQuanAttAcc'] | dqReport[@type = 'DQNonQuanAttAcc']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:nonQuantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQNonQuanAttAcc')]/DQNonQuanAttAcc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:nonQuantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQNonQuanAttAcc')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:nonQuantitativeAttributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQThemClassCor'] | dqReport[@type = 'DQThemClassCor']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:thematicClassificationCorrectnessReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQThemClassCor')]/DQThemClassCor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:thematicClassificationCorrectnessReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQThemClassCor')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:thematicClassificationCorrectnessReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQTempValid'] | dqReport[@type = 'DQTempValid']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalValidityReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTempValid')]/DQTempValid">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:temporalValidityReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTempValid')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalValidityReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQTempConsis'] | dqReport[@type = 'DQTempConsis']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTempConsis')]/DQTempConsis">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:temporalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQTempConsis')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="report[@type = 'DQAccTimeMeas'] | dqReport[@type = 'DQAccTimeMeas']">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:accuracyOfATimeMeasurementReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQAccTimeMeas')]/DQAccTimeMeas">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:accuracyOfATimeMeasurementReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="dqReport[not(@type = 'DQAccTimeMeas')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:accuracyOfATimeMeasurementReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dataLineage">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:lineage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Lineage">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== LI_Lineage ==-->
<xsl:template name="LI_Lineage">
<xsl:param name="subject" />
<xsl:for-each select="statement">
<r:assert relation="em:statement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="prcStep[stepDesc | stepRat | stepDateTm | stepProc | stepSrc]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:processStep">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_ProcessStep">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dataSource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Source">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== LI_Source ==-->
<xsl:template name="LI_Source">
<xsl:param name="subject" />
<xsl:for-each select="srcDesc">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srcMedName/MedNameCd">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srcScale/rfDenom">
<r:assert relation="em:scaleDenominator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srcCitatn">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sourceCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="srcExt">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sourceExtent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="srcStep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sourceStep">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_ProcessStep">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="srcRefSys/RefSystem/refSysID">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sourceReferenceSystem">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="RS_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== LI_ProcessStep ==-->
<xsl:template name="LI_ProcessStep">
<xsl:param name="subject" />
<xsl:for-each select="stepDesc">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="stepRat">
<r:assert relation="em:rationale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="stepSrc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Source">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="stepProc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:processor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="stepDateTm">
<r:assert relation="em:dateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="stepDateTm/@date">
<r:assert relation="em:dateTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_Element ==-->
<xsl:template name="DQ_Element">
<xsl:param name="subject" />
<xsl:for-each select="measName">
<r:assert relation="em:nameOfMeasure">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="measId[./*/text()]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="measDesc">
<r:assert relation="em:measureDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="evalMethType/EvalMethTypeCd">
<r:assert relation="em:evaluationMethodType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="evalMethDesc">
<r:assert relation="em:evaluationMethodDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="evalProc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:evaluationProcedure">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="measDateTm">
<r:assert relation="em:dateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="measResult/ConResult">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:conformanceResult">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_ConformanceResult">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="measResult">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:conformanceResult">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_ConformanceResult">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="measResult/QuanResult">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:quantitativeResult">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_QuantitativeResult">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="measResult">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:quantitativeResult">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_QuantitativeResult">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_ConformanceResult ==-->
<xsl:template name="DQ_ConformanceResult">
<xsl:param name="subject" />
<xsl:for-each select="conSpec">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:specification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="conExpl">
<r:assert relation="em:explanation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="conPass">
<r:assert relation="em:pass">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_QuantitativeResult ==-->
<xsl:template name="DQ_QuantitativeResult">
<xsl:param name="subject" />
<xsl:for-each select="quanValType">
<r:assert relation="em:valueType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="quanValUnit/UOM">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:valueUnit">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="gml_UnitDefinition">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="errStat">
<r:assert relation="em:errorStatistic">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="quanVal">
<r:assert relation="em:value">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== Record ==-->
<xsl:template name="Record">
<xsl:param name="subject" />
<xsl:apply-templates />
</xsl:template>
<!--== DQ_Scope ==-->
<xsl:template name="DQ_Scope">
<xsl:param name="subject" />
<xsl:for-each select="scpLvl/ScopeCd">
<r:assert relation="em:level">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="scpExt">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="scpLvlDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:levelDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ScopeDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_PortrayalCatalogueReference ==-->
<xsl:template name="MD_PortrayalCatalogueReference">
<xsl:param name="subject" />
<xsl:for-each select="portCatCit">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:portrayalCatalogueCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_FeatureCatalogueDescription ==-->
<xsl:template name="MD_FeatureCatalogueDescription">
<xsl:param name="subject" />
<xsl:for-each select="compCode">
<r:assert relation="em:complianceCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="catLang/languageCode/@value">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="incWithDS">
<r:assert relation="em:includedWithDataset">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="catFetTyps/genericName | catFetTyps[not(genericName)]/LocalName | catFetTyps[not(genericName)]/ScopedName | catFetTyps[not(genericName)]/TypeName | catFetTyps[not(genericName)]/MemberName">
<r:assert relation="em:featureTypes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="catCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:featureCatalogueCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_CoverageDescription ==-->
<xsl:template name="MD_CoverageDescription">
<xsl:param name="subject" />
<xsl:for-each select="attDesc">
<r:assert relation="em:attributeDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="contentTyp/ContentTypCd">
<r:assert relation="em:contentType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="covDim/RangeDim">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:rangeDimension">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_RangeDimension">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="covDim">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:rangeDimension">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_RangeDimension">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="covDim/Band">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:bandDimension">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Band">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="covDim">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:bandDimension">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Band">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_RangeDimension ==-->
<xsl:template name="MD_RangeDimension">
<xsl:param name="subject" />
<xsl:for-each select="seqID">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sequenceIdentifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MemberName">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="seqId">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sequenceIdentifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MemberName">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dimDescrp">
<r:assert relation="em:descriptor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Band ==-->
<xsl:template name="MD_Band">
<xsl:param name="subject" />
<xsl:call-template name="MD_RangeDimension">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="maxVal">
<r:assert relation="em:maxValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="minVal">
<r:assert relation="em:minValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="valUnit/UOM">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:units">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="gml_UnitDefinition">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="pkResp">
<r:assert relation="em:peakResponse">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="bitsPerVal">
<r:assert relation="em:bitsPerValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="toneGrad">
<r:assert relation="em:toneGradation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="sclFac">
<r:assert relation="em:scaleFactor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="offset">
<r:assert relation="em:offset">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== gml_StandardProperties ==-->
<xsl:template name="gml_StandardProperties">
<xsl:param name="subject" />
<xsl:for-each select="@gmlID[(. != '')]">
<r:assert relation="em:id">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmlDesc">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmlDescRef/@href | gmlDescRef[starts-with(text(),'http://')]">
<r:assert relation="em:gmlDescHref">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmlIdent">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmlName">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== gml_UnitDefinition ==-->
<xsl:template name="gml_UnitDefinition">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="gmlRemarks">
<r:assert relation="em:remarks">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="unitQuanType">
<r:assert relation="em:quantityType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="unitQuanRef/@href | unitQuanRef[starts-with(text(),'http://')]">
<r:assert relation="em:unitQuanHref">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="unitSymbol">
<r:assert relation="em:catalogSymbol">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== gml_ReferenceType ==-->
<xsl:template name="gml_ReferenceType">
<xsl:param name="subject" />
<xsl:for-each select="@href">
<r:assert relation="em:href">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<r:uri><xsl:value-of select="." /></r:uri>
</r:assert>
</xsl:for-each>
<xsl:for-each select="text()">
<r:assert relation="em:title">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MemberName ==-->
<xsl:template name="MemberName">
<xsl:param name="subject" />
<xsl:for-each select="aName">
<r:assert relation="em:aName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attributeType/aName">
<r:assert relation="em:attributeTypeName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_ImageDescription ==-->
<xsl:template name="MD_ImageDescription">
<xsl:param name="subject" />
<xsl:call-template name="MD_CoverageDescription">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="illElevAng">
<r:assert relation="em:illuminationElevationAngle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="illAziAng">
<r:assert relation="em:illuminationAzimuthAngle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="imagCond/ImgCondCd">
<r:assert relation="em:imagingCondition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="imagQuCode">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:imageQualityCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cloudCovPer">
<r:assert relation="em:cloudCoverPercentage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="prcTypCde">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:processingLevelCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cmpGenQuan">
<r:assert relation="em:compressionGenerationQuantity">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="trianInd">
<r:assert relation="em:triangulationIndicator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="radCalDatAv">
<r:assert relation="em:radiometricCalibrationDataAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="camCalInAv">
<r:assert relation="em:cameraCalibrationInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="camCalInAv">
<r:assert relation="em:filmDistortionInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="lensDistInAv">
<r:assert relation="em:lensDistortionInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== PT_FreeText_Abstract ==-->
<xsl:template name="PT_FreeText_Abstract">
<xsl:param name="subject" />
<xsl:for-each select="idAbs">
<r:assert relation="em:baseAbstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="/metadata/Esri/locales/locale[idAbs]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:localeAbstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_Free_Abstract_locale">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== PT_Free_Abstract_locale ==-->
<xsl:template name="PT_Free_Abstract_locale">
<xsl:param name="subject" />
<xsl:for-each select="@language">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="@country">
<r:assert relation="em:country">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idAbs">
<r:assert relation="em:abs">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Identification ==-->
<xsl:template name="MD_Identification">
<xsl:param name="subject" />
<xsl:for-each select="idCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:citation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="idAbs[not(/metadata/Esri/locales/locale/idAbs)]">
<r:assert relation="em:abstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="self::node()[(idAbs) and (/metadata/Esri/locales/locale/idAbs)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:mdIdentAbstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_FreeText_Abstract">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="idPurp">
<r:assert relation="em:purpose">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idCredit">
<r:assert relation="em:credit">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idStatus/ProgCd">
<r:assert relation="em:status">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idPoC">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:pointOfContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="resMaint">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:resourceMaintenance">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MaintenanceInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="graphOver[((bgFileName != 'withheld') and not(contains(bgFileName, '\\')) and not(contains(bgFileName, ':\')) and not(contains(bgFileName, 'Server=')))]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:graphicOverview">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_BrowseGraphic">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="/metadata/Binary/Thumbnail">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:thumbnail">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="ESRI_Thumbnail">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dsFormat">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:resourceFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="discKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:disciplineKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="descKeys[ ( @KeyTypCd = '001') or (keyTyp/KeyTypCd/@value = '001') and not(../discKeys)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:disciplineKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="placeKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:placeKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="descKeys[ ( @KeyTypCd = '002') or (keyTyp/KeyTypCd/@value = '002') and not(../placeKeys)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:placeKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="stratKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:stratumKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="descKeys[ ( @KeyTypCd = '003') or (keyTyp/KeyTypCd/@value = '003') and not(../stratKeys)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:stratumKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="tempKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="descKeys[ ( @KeyTypCd = '004') or (keyTyp/KeyTypCd/@value = '004') and not(../tempKeys)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="themeKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:themeKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="descKeys[ ( @KeyTypCd = '005') or (keyTyp/KeyTypCd/@value = '005') and not(../themeKeys)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:themeKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="otherKeys">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:otherKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="searchKeys[not(../discKeys/keyword/text() | ../placeKeys/keyword/text() | ../stratKeys/keyword/text() | ../tempKeys/keyword/text() | ../themeKeys/keyword/text() | ../descKeys[(@KeyTypCd != '') or (keyTyp/KeyTypCd/@value != '')]/keyword/text())]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:searchTags">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="idSpecUse">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:resourceSpecificUsage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Usage">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="resConst/LegConsts">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:legalConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_LegalConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="resConst">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:legalConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_LegalConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="resConst/SecConsts">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:securityConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_SecurityConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="resConst">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:securityConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_SecurityConstraints">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="resConst/Consts/useLimit">
<r:assert relation="em:useLimitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="aggrInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:aggregationInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_AggregateInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="spatRpType/SpatRepTypCd">
<r:assert relation="em:spatialRepresentationType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataScale/equScale/rfDenom">
<r:assert relation="em:equivalentScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataScale/scaleDist">
<r:assert relation="em:distance">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-measure" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataLang/languageCode/@value">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataChar/CharSetCd">
<r:assert relation="em:characterSet">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="tpCat/TopicCatCd">
<r:assert relation="em:topicCategory">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="envirDesc">
<r:assert relation="em:environmentDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="geoBox">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:geoBox">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicBoundingBox">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="dataExt[(count(*) - count(geoEle/GeoBndBox/@esriExtentType[. = 'native'])) &gt; 0]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="geoBox[((count(../dataExt/geoEle/GeoBndBox) - count(../dataExt/geoEle/GeoBndBox/@esriExtentType[. = 'native'])) = 0)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extentSearchBox">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicBoundingBox">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="suppInfo">
<r:assert relation="em:supplementalInformation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svType/genericName">
<r:assert relation="em:serviceType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svTypeVer">
<r:assert relation="em:serviceTypeVersion">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svAccProps">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:accessProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_StandardOrderProcess">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svExt">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svCouplRes">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:coupledResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_CoupledResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svCouplType/CouplTypCd">
<r:assert relation="em:couplingType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svOper">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:containsOperations">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_OperationMetadata">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svOperOn">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:operatesOn">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DataIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_DataIdentification ==-->
<xsl:template name="MD_DataIdentification">
<xsl:param name="subject" />
<xsl:call-template name="MD_Identification">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:apply-templates />
</xsl:template>
<!--== MD_AggregateInformation ==-->
<xsl:template name="MD_AggregateInformation">
<xsl:param name="subject" />
<xsl:for-each select="aggrDSName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:aggregateDataSetName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="aggrDSIdent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:aggregateDataSetIdentifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="assocType/AscTypeCd">
<r:assert relation="em:associationType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="initType/InitTypCd">
<r:assert relation="em:initiativeType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_Extent ==-->
<xsl:template name="EX_Extent">
<xsl:param name="subject" />
<xsl:for-each select="exDesc">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="geoEle/BoundPoly">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:boundingPolygon">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_BoundingPolygon">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="geoEle/GeoBndBox[not (@esriExtentType = 'native')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:boundingBox">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicBoundingBox">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="geoEle/GeoDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:geographicDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="tempEle[(count(.//TM_Instant) + count(.//TM_Period) + count(.//TM_CalDate) + count(.//TM_DateAndTime) - count(.//TM_ClockTime)) &gt; 0]/TempExtent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:temporalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_TemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="tempEle[(count(.//TM_Instant) + count(.//TM_Period) + count(.//TM_CalDate) + count(.//TM_DateAndTime) - count(.//TM_ClockTime)) &gt; 0]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:temporalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_TemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="tempEle[(count(.//TM_Instant) + count(.//TM_Period) + count(.//TM_CalDate) + count(.//TM_DateAndTime) - count(.//TM_ClockTime)) &gt; 0]/SpatTempEx">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:spatialTemporalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_SpatialTemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="tempEle[(count(.//TM_Instant) + count(.//TM_Period) + count(.//TM_CalDate) + count(.//TM_DateAndTime) - count(.//TM_ClockTime)) &gt; 0]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:spatialTemporalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_SpatialTemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="vertEle">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:verticalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_VerticalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_SpatialTemporalExtent ==-->
<xsl:template name="EX_SpatialTemporalExtent">
<xsl:param name="subject" />
<xsl:call-template name="EX_TemporalExtent">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="exSpat/BoundPoly">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:boundingPolygon">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_BoundingPolygon">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="exSpat/GeoBndBox[not (@esriExtentType = 'native')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:boundingBox">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicBoundingBox">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="exSpat/GeoDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:geographicDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_GeographicDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_TemporalExtent ==-->
<xsl:template name="EX_TemporalExtent">
<xsl:param name="subject" />
<xsl:for-each select="exTemp/TM_Instant">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:timeInstant">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="TimeInstant">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="exTemp[not(TM_Instant)]/TM_GeometricPrimitive/TM_Instant/tmPosition/TM_DateAndTime">
<r:assert relation="em:timePosition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="exTemp[not(TM_Instant)]/TM_GeometricPrimitive/TM_Instant/tmPosition/TM_CalDate">
<r:assert relation="em:timePosition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="exTemp/TM_Period">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:timePeriod">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="TimePeriod">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="exTemp[not(TM_Period)]/TM_GeometricPrimitive/TM_Period">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:timePeriod">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="TimePeriod">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== TimeInstant ==-->
<xsl:template name="TimeInstant">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="tmPosition">
<r:assert relation="em:timePosition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== TimePeriod ==-->
<xsl:template name="TimePeriod">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="tmBegin | begin">
<r:assert relation="em:beginTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="tmBegin/@date">
<r:assert relation="em:beginTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="tmEnd | end">
<r:assert relation="em:endTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="tmEnd/@date">
<r:assert relation="em:endTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_VerticalExtent ==-->
<xsl:template name="EX_VerticalExtent">
<xsl:param name="subject" />
<xsl:for-each select="vertMinVal">
<r:assert relation="em:minimumValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="vertMaxVal">
<r:assert relation="em:maximumValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_GeographicExtent ==-->
<xsl:template name="EX_GeographicExtent">
<xsl:param name="subject" />
<xsl:for-each select="exTypeCode">
<r:assert relation="em:extentTypeCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_BoundingPolygon ==-->
<xsl:template name="EX_BoundingPolygon">
<xsl:param name="subject" />
<xsl:call-template name="EX_GeographicExtent">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="polygon">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:polygon">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_Polygon">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== GML_Polygon ==-->
<xsl:template name="GML_Polygon">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="exterior">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:exterior">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_LinearRing">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="GM_Polygon[not(../exterior)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:exterior">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_LinearRing">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="interior">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:interior">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_LinearRing">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== GML_LinearRing ==-->
<xsl:template name="GML_LinearRing">
<xsl:param name="subject" />
<xsl:for-each select="pos">
<r:assert relation="em:pos">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="posList">
<r:assert relation="em:posList">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="coordinates">
<r:assert relation="em:posList">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_GeographicBoundingBox ==-->
<xsl:template name="EX_GeographicBoundingBox">
<xsl:param name="subject" />
<xsl:call-template name="EX_GeographicExtent">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="westBL">
<r:assert relation="em:westBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eastBL">
<r:assert relation="em:eastBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="southBL">
<r:assert relation="em:southBoundLatitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="northBL">
<r:assert relation="em:northBoundLatitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_GeographicDescription ==-->
<xsl:template name="EX_GeographicDescription">
<xsl:param name="subject" />
<xsl:call-template name="EX_GeographicExtent">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="geoId">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Resolution ==-->
<xsl:template name="MD_Resolution">
<xsl:param name="subject" />
<xsl:for-each select="equScale/rfDenom">
<r:assert relation="em:equivalentScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="scaleDist">
<r:assert relation="em:distance">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-measure" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Constraints ==-->
<xsl:template name="MD_Constraints">
<xsl:param name="subject" />
<xsl:for-each select="useLimit">
<r:assert relation="em:useLimitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_LegalConstraints ==-->
<xsl:template name="MD_LegalConstraints">
<xsl:param name="subject" />
<xsl:call-template name="MD_Constraints">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="accessConsts/RestrictCd">
<r:assert relation="em:accessConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="useConsts/RestrictCd">
<r:assert relation="em:useConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="othConsts">
<r:assert relation="em:otherConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_SecurityConstraints ==-->
<xsl:template name="MD_SecurityConstraints">
<xsl:param name="subject" />
<xsl:call-template name="MD_Constraints">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="class/ClasscationCd">
<r:assert relation="em:classification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="userNote">
<r:assert relation="em:note">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="classSys">
<r:assert relation="em:classificationSystem">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="handDesc">
<r:assert relation="em:handlingDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Usage ==-->
<xsl:template name="MD_Usage">
<xsl:param name="subject" />
<xsl:for-each select="specUsage">
<r:assert relation="em:specificUsage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="usageDate">
<r:assert relation="em:usageDateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="usrDetLim">
<r:assert relation="em:userDeterminedLimitations">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="usrCntInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:userContactInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_ScopeDescription ==-->
<xsl:template name="MD_ScopeDescription">
<xsl:param name="subject" />
<xsl:for-each select="attribSet">
<r:assert relation="em:attributes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="featSet">
<r:assert relation="em:features">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="featIntSet">
<r:assert relation="em:featureInstances">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attribIntSet">
<r:assert relation="em:attributeInstances">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="datasetSet">
<r:assert relation="em:dataset">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="other">
<r:assert relation="em:other">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_MaintenanceInformation ==-->
<xsl:template name="MD_MaintenanceInformation">
<xsl:param name="subject" />
<xsl:for-each select="maintFreq/MaintFreqCd">
<r:assert relation="em:maintenanceAndUpdateFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dateNext">
<r:assert relation="em:dateOfNextUpdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="maintScp/ScopeCd">
<r:assert relation="em:updateScope">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="upScpDesc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:updateScopeDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ScopeDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="maintNote">
<r:assert relation="em:maintenanceNote">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="maintCont">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:maintenanceContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="usrDefFreq/duration">
<r:assert relation="em:userDefinedMaintenanceFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="usrDefFreq[not(./duration)]">
<r:assert relation="em:userDefinedMaintenanceFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_BrowseGraphic ==-->
<xsl:template name="MD_BrowseGraphic">
<xsl:param name="subject" />
<xsl:for-each select="bgFileName">
<r:assert relation="em:fileName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="bgFileDesc">
<r:assert relation="em:fileDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="bgFileType">
<r:assert relation="em:fileType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Format ==-->
<xsl:template name="MD_Format">
<xsl:param name="subject" />
<xsl:for-each select="formatName">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formatVer">
<r:assert relation="em:version">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formatAmdNum">
<r:assert relation="em:amendmentNumber">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formatSpec">
<r:assert relation="em:specification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="fileDecmTech">
<r:assert relation="em:fileDecompressionTechnique">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formatDist">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:formatDistributor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distributor">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Distributor ==-->
<xsl:template name="MD_Distributor">
<xsl:param name="subject" />
<xsl:for-each select="distorCont">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributorContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distorOrdPrc[resFees | planAvDtTm | ordInstr | ordTurn]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributionOrderProcess">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_StandardOrderProcess">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distorFormat[formatName | formatVer | formatAmdNum | formatSpec | fileDecmTech | formatDist]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributorFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="distorTran[unitsODist | transSize | onLineSrc | offLineMed][((count(.//*[text()]) - count(./onLineSrc/orDesc[starts-with(.,'0')])) &gt; 0)][((count(unitsODist[text()]) + count(transSize[text()]) + count(offLineMed/*[text()]) + count(onLineSrc[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://'))]/*[text()])) &gt; 0)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:distributorTransferOptions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DigitalTransferOptions">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_DigitalTransferOptions ==-->
<xsl:template name="MD_DigitalTransferOptions">
<xsl:param name="subject" />
<xsl:for-each select="unitsODist">
<r:assert relation="em:unitsOfDistribution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="transSize">
<r:assert relation="em:transferSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="onLineSrc[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://')) and ((count(.//*[text()]) - count(./orDesc[starts-with(.,'0')])) &gt; 0)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:onLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="offLineMed">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:offLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Medium">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Medium ==-->
<xsl:template name="MD_Medium">
<xsl:param name="subject" />
<xsl:for-each select="medName/MedNameCd">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="medDensity">
<r:assert relation="em:density">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="medDenUnits">
<r:assert relation="em:densityUnits">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="medVol">
<r:assert relation="em:volumes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="medFormat/MedFormCd">
<r:assert relation="em:mediumFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="medNote">
<r:assert relation="em:mediumNote">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_StandardOrderProcess ==-->
<xsl:template name="MD_StandardOrderProcess">
<xsl:param name="subject" />
<xsl:for-each select="resFees">
<r:assert relation="em:fees">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="ordInstr">
<r:assert relation="em:orderingInstructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="ordTurn">
<r:assert relation="em:turnaround">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="planAvDtTm">
<r:assert relation="em:plannedAvailableDateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Keywords ==-->
<xsl:template name="MD_Keywords">
<xsl:param name="subject" />
<xsl:for-each select="keyword">
<r:assert relation="em:keyword">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="thesaName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:thesaurusName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== PT_FreeText_Title ==-->
<xsl:template name="PT_FreeText_Title">
<xsl:param name="subject" />
<xsl:for-each select="resTitle">
<r:assert relation="em:baseTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="/metadata/Esri/locales/locale[resTitle]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:localeTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_Free_Title_locale">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== PT_Free_Title_locale ==-->
<xsl:template name="PT_Free_Title_locale">
<xsl:param name="subject" />
<xsl:for-each select="@language">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="@country">
<r:assert relation="em:country">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resTitle">
<r:assert relation="em:ttl">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Citation ==-->
<xsl:template name="CI_Citation">
<xsl:param name="subject" />
<xsl:for-each select="resTitle">
<r:assert relation="em:title">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="../idCitation[(resTitle) and (local-name(./..) = 'dataIdInfo') and (/metadata/Esri/locales/locale/resTitle)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:mdIdentTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="PT_FreeText_Title">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="resAltTitle">
<r:assert relation="em:alternateTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="date/createDate">
<r:assert relation="em:creationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resRefDate[(refDateType/DateTypCd/@value = 1) and not(../date/createDate)]/refDate">
<r:assert relation="em:creationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="date/pubDate">
<r:assert relation="em:publicationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="date/pubDate/@date">
<r:assert relation="em:publicationDateNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resRefDate[(refDateType/DateTypCd/@value = 2) and not(../date/pubDate)]/refDate">
<r:assert relation="em:publicationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="date/reviseDate">
<r:assert relation="em:revisionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resRefDate[(refDateType/DateTypCd/@value = 3) and not(../date/reviseDate)]/refDate">
<r:assert relation="em:revisionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resEd">
<r:assert relation="em:edition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="resEdDate">
<r:assert relation="em:editionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="citId[(count (*) = 0) and (text() != '')]">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="citId[count(*) &gt; 0]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="citRespParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:citedResponsibleParty">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="presForm/PresFormCd">
<r:assert relation="em:presentationForm">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="datasetSeries">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:series">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Series">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="otherCitDet">
<r:assert relation="em:otherCitationDetails">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="collTitle">
<r:assert relation="em:collectiveTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="isbn">
<r:assert relation="em:ISBN">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="issn">
<r:assert relation="em:ISSN">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Series ==-->
<xsl:template name="CI_Series">
<xsl:param name="subject" />
<xsl:for-each select="seriesName">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="issId">
<r:assert relation="em:issueIdentification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="artPage">
<r:assert relation="em:page">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Identifier ==-->
<xsl:template name="MD_Identifier">
<xsl:param name="subject" />
<xsl:for-each select="identAuth">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:authority">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="identCode/@code">
<r:assert relation="em:code">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="identCode[not(./@code)]">
<r:assert relation="em:code">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== RS_Identifier ==-->
<xsl:template name="RS_Identifier">
<xsl:param name="subject" />
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="idCodeSpace">
<r:assert relation="em:codeSpace">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idVersion">
<r:assert relation="em:version">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_GridSpatialRepresentation ==-->
<xsl:template name="MD_GridSpatialRepresentation">
<xsl:param name="subject" />
<xsl:for-each select="numDims">
<r:assert relation="em:numberOfDimensions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="axisDimension">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:axisDimensionProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Dimension">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="axDimProps[not(../axisDimension)]/Dimen">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:axisDimensionProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Dimension_esriiso">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="axDimProps[not(../axisDimension)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:axisDimensionProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Dimension_esriiso">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cellGeo/CellGeoCd">
<r:assert relation="em:cellGeometry">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="tranParaAv">
<r:assert relation="em:transformationParameterAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Georectified ==-->
<xsl:template name="MD_Georectified">
<xsl:param name="subject" />
<xsl:call-template name="MD_GridSpatialRepresentation">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="chkPtAv">
<r:assert relation="em:checkPointAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="chkPtDesc">
<r:assert relation="em:checkPointDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cornerPts[pos]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:cornerPoints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_Point">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cornerPts[(text() != '') and not(pos)]">
<r:assert relation="em:cornerPoints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="centerPt[pos]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:centerPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_Point">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="centerPt[(text() != '') and not(pos)]">
<r:assert relation="em:centerPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="ptInPixel/PixOrientCd">
<r:assert relation="em:pointInPixel">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="transDimDesc">
<r:assert relation="em:transformationDimensionDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="transDimMap">
<r:assert relation="em:transformationDimensionMapping">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== GML_Point ==-->
<xsl:template name="GML_Point">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="pos">
<r:assert relation="em:pos">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Georeferenceable ==-->
<xsl:template name="MD_Georeferenceable">
<xsl:param name="subject" />
<xsl:call-template name="MD_GridSpatialRepresentation">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="ctrlPtAv">
<r:assert relation="em:controlPointAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="orieParaAv">
<r:assert relation="em:orientationParameterAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="orieParaDs">
<r:assert relation="em:orientationParameterDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="georefPars">
<r:assert relation="em:georeferencedParameters">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="paraCit">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:parameterCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_VectorSpatialRepresentation ==-->
<xsl:template name="MD_VectorSpatialRepresentation">
<xsl:param name="subject" />
<xsl:for-each select="topLvl/TopoLevCd">
<r:assert relation="em:topologyLevel">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="geometObjs">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:geometricObjects">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_GeometricObjects">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_GeometricObjects ==-->
<xsl:template name="MD_GeometricObjects">
<xsl:param name="subject" />
<xsl:for-each select="geoObjTyp/GeoObjTypCd">
<r:assert relation="em:geometricObjectType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="geoObjCnt">
<r:assert relation="em:geometricObjectCount">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Dimension ==-->
<xsl:template name="MD_Dimension">
<xsl:param name="subject" />
<xsl:for-each select="@type">
<r:assert relation="em:dimensionName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dimSize">
<r:assert relation="em:dimensionSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dimResol">
<r:assert relation="em:resolution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-measure" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Dimension_esriiso ==-->
<xsl:template name="MD_Dimension_esriiso">
<xsl:param name="subject" />
<xsl:for-each select="dimName/DimNameTypCd">
<r:assert relation="em:dimensionName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dimSize">
<r:assert relation="em:dimensionSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dimResol">
<r:assert relation="em:resolution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-measure" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== Standalone_CI_ResponsibleParty ==-->
<xsl:template match="/gmd:CI_ResponsibleParty">
<xsl:param name="subject" />
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:apply-templates />
</xsl:template>
<!--== CI_ResponsibleParty ==-->
<xsl:template name="CI_ResponsibleParty">
<xsl:param name="subject" />
<xsl:for-each select="rpIndName">
<r:assert relation="em:individualName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rpOrgName">
<r:assert relation="em:organisationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rpPosName">
<r:assert relation="em:position">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rpCntInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:contactInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Contact">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="role/RoleCd">
<r:assert relation="em:role">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Contact ==-->
<xsl:template name="CI_Contact">
<xsl:param name="subject" />
<xsl:for-each select="cntAddress">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:address">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Address">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cntOnlineRes[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://'))]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:onlineResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="cntPhone/voiceNum[not(@phoneType='tddtty')]">
<r:assert relation="em:voiceNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntPhone/voiceNum[(@phoneType='tddtty')]">
<r:assert relation="em:tddtty">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntPhone/faxNum">
<r:assert relation="em:faxNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntHours">
<r:assert relation="em:hours">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntInstr">
<r:assert relation="em:instructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Address ==-->
<xsl:template name="CI_Address">
<xsl:param name="subject" />
<xsl:for-each select="../@addressType">
<r:assert relation="em:addressType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="delPoint">
<r:assert relation="em:deliveryPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="city">
<r:assert relation="em:city">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="adminArea">
<r:assert relation="em:administrativeArea">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="postCode">
<r:assert relation="em:postalCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="country">
<r:assert relation="em:country">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eMailAdd">
<r:assert relation="em:electronicMailAddress">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_OnlineResource ==-->
<xsl:template name="CI_OnlineResource">
<xsl:param name="subject" />
<xsl:for-each select="linkage[(starts-with(.,'http://') or starts-with(.,'ftp://'))]">
<r:assert relation="em:linkage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="protocol">
<r:assert relation="em:protocol">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="appProfile">
<r:assert relation="em:applicationProfile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="orName">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="orDesc[not((text() = '001') or (text() = '002') or (text() = '003') or (text() = '004') or (text() = '005') or (text() = '006') or (text() = '007') or (text() = '008') or (text() = '009') or (text() = '010'))]">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="orFunct/OnFunctCd">
<r:assert relation="em:function">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== SV_ServiceIdentification ==-->
<xsl:template name="SV_ServiceIdentification">
<xsl:param name="subject" />
<xsl:call-template name="MD_Identification">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:apply-templates />
</xsl:template>
<!--== SV_OperationMetadata ==-->
<xsl:template name="SV_OperationMetadata">
<xsl:param name="subject" />
<xsl:for-each select="svOpName">
<r:assert relation="em:operationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svDCP/DCPListCd">
<r:assert relation="em:DCP">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svDesc">
<r:assert relation="em:operationDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svInvocName">
<r:assert relation="em:invocationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svParams">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:parameters">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_Parameter">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svConPt[(starts-with(linkage,'http://') or starts-with(linkage,'ftp://'))]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:connectPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svOper">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:dependsOn">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_OperationMetadata">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== SV_Parameter ==-->
<xsl:template name="SV_Parameter">
<xsl:param name="subject" />
<xsl:for-each select="svParName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:paramName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MemberName">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="svParDir/ParamDirCd">
<r:assert relation="em:direction">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svDesc">
<r:assert relation="em:paramDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svParOpt">
<r:assert relation="em:optionality">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svRepeat">
<r:assert relation="em:repeatability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svValType/aName">
<r:assert relation="em:paramValueType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== SV_CoupledResource ==-->
<xsl:template name="SV_CoupledResource">
<xsl:param name="subject" />
<xsl:for-each select="svOpName">
<r:assert relation="em:operationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="svResCitId/identCode">
<r:assert relation="em:resourceIdentifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== ESRI_Thumbnail ==-->
<xsl:template name="ESRI_Thumbnail">
<xsl:param name="subject" />
<xsl:for-each select="Data">
<r:assert relation="em:thumbnailData">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="Data/@EsriPropertyType">
<r:assert relation="em:thumbnailType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== remove extraneous text ==-->
<xsl:template match="text()" />
<!--== static templates ==-->
<!--== GENERIC TEMPLATE FOR DATE PROPERTIES ==-->
<xsl:template name="sys-date">
<xsl:choose>
<xsl:when test="count (calDate | clkTime) = 2">
<r:literal><xsl:value-of select="concat (calDate, 'T', clkTime)" /></r:literal>
</xsl:when>
<xsl:when test="calDate">
<r:literal><xsl:value-of select="calDate" /></r:literal>
</xsl:when>
<xsl:when test="gco:Date | gco:DateTime">
<r:literal><xsl:value-of select="*/." /></r:literal>
</xsl:when>
<xsl:when test="gmd:CI_Date">
<xsl:for-each select="(gmd:CI_Date/gco:Date | gmd:CI_Date/gco:DateTime)[1]">
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:for-each>
</xsl:when>
<xsl:when test="@gco:nilReason">
<xsl:choose>
<xsl:when test="@gco:nilReason = ''">
<r:qname>em:null</r:qname>
</xsl:when>
<xsl:otherwise>
<r:qname>em:null</r:qname>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR OBJECT REFERENCE PROPERTIES ==-->
<xsl:template name="sys-objref">
<xsl:choose>
<xsl:when test="@xlink:href">
<r:uri><xsl:value-of select="@xlink:href" /></r:uri>
</xsl:when>
<xsl:when test="@uuidref">
<r:literal><xsl:value-of select="@uuidref" /></r:literal>
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="yes">ERROR: expecting object reference @xlink:href or @uuidref. Found none.</xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR MEASURE PROPERTIES ==-->
<xsl:template name="sys-measure">
<xsl:choose>
<xsl:when test="gco:Measure | gco:Length | gco:Angle | gco:Scale | gco:Distance">
<xsl:for-each select="*[1]">
<xsl:choose>
<xsl:when test="@uom">
<r:tuple>
<r:literal><xsl:value-of select="." /></r:literal>
<r:literal><xsl:value-of select="@uom" /></r:literal>
</r:tuple>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:when>
<xsl:when test="value">
<xsl:choose>
<xsl:when test="value/@uom">
<r:tuple>
<r:literal><xsl:value-of select="value" /></r:literal>
<r:literal><xsl:value-of select="value/@uom" /></r:literal>
</r:tuple>
</xsl:when>
<xsl:when test="uom/*/uomName">
<r:tuple>
<r:literal><xsl:value-of select="value" /></r:literal>
<r:literal><xsl:value-of select="uom/*/uomName" /></r:literal>
</r:tuple>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR NUMBER PROPERTIES ==-->
<xsl:template name="sys-number">
<xsl:choose>
<xsl:when test="gco:Real | gco:Decimal | gco:Integer">
<r:number><xsl:value-of select="*[1]" /></r:number>
</xsl:when>
<xsl:when test="@gco:nilReason">
<xsl:choose>
<xsl:when test="@gco:nilReason = ''">
<r:qname>em:null</r:qname>
</xsl:when>
<xsl:otherwise>
<r:qname>em:null</r:qname>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="*/@gco:nilReason">
<xsl:choose>
<xsl:when test="*/@gco:nilReason = ''">
<r:qname>em:null</r:qname>
</xsl:when>
<xsl:otherwise>
<r:qname>em:null</r:qname>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<r:number><xsl:value-of select="." /></r:number>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR BOOLEAN PROPERTIES ==-->
<xsl:template name="sys-boolean">
<xsl:choose>
<xsl:when test="gco:Boolean = 'true' or gco:Boolean = '1'">
<r:qname>es:true</r:qname>
</xsl:when>
<xsl:when test=".='true' or .='1'">
<r:qname>es:true</r:qname>
</xsl:when>
<xsl:otherwise>
<r:qname>es:false</r:qname>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR POSITION PROPERTIES ==-->
<xsl:template name="sys-position">
<xsl:choose>
<xsl:when test="*">
<r:number><xsl:number /></r:number>
</xsl:when>
<xsl:otherwise>
<r:number>0</r:number>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR LOCALIZABLE LITERAL PROPERTIES ==-->
<xsl:template name="sys-literal">
<xsl:choose>
<xsl:when test="gco:CharacterString">
<r:literal><xsl:value-of select="normalize-space(gco:CharacterString)" /></r:literal>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
</xsl:otherwise>
</xsl:choose>
<xsl:choose>
<xsl:when test="count (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString) = 1">
<r:tuple>
<r:literal><xsl:value-of select="normalize-space(gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString)" /></r:literal>
<r:literal><xsl:value-of select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString/@locale" /></r:literal>
</r:tuple>
</xsl:when>
<xsl:when test="count (gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString) &gt; 1">
<r:list>
<xsl:for-each select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
<r:tuple>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
<r:literal><xsl:value-of select="@locale" /></r:literal>
</r:tuple>
</xsl:for-each>
</r:list>
</xsl:when>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR OBJECT PROPERTY OBJECT VALUES ==-->
<xsl:template name="sys-objprop-obj">
<xsl:choose>
<xsl:when test="@xlink:href">
<r:uri><xsl:value-of select="@xlink:href" /></r:uri>
</xsl:when>
<xsl:when test="@id | @uuid">
<xsl:choose>
<xsl:when test="@id">
<r:uri>#<xsl:value-of select="@id" /></r:uri>
</xsl:when>
<xsl:otherwise>
<r:uri>urn:uuid:<xsl:value-of select="@uuid" /></r:uri>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="*">
<r:qname><xsl:value-of select="concat ('gen:',generate-id(.))" /></r:qname>
</xsl:when>
<xsl:when test="@*">
<r:qname><xsl:value-of select="concat ('gen:',generate-id(.))" /></r:qname>
</xsl:when>
<xsl:otherwise>
<xsl:message terminate="no">WARNING: object for an object property expects child nodes; found none; location: <xsl:value-of select="local-name()" /></xsl:message>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="sys-objprop-obj2">
<xsl:choose>
<xsl:when test="@xlink:href">
<r:uri><xsl:value-of select="@xlink:href" /></r:uri>
</xsl:when>
<xsl:otherwise>
<xsl:text>__NONE__</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR GENERIC NAME PROPERTIES ==-->
<xsl:template name="sys-generic-name">
<xsl:choose>
<xsl:when test="(name() = 'LocalName') or (name() = 'ScopedName')">
<r:literal><xsl:value-of select="(scope)[1]" /></r:literal>
</xsl:when>
<xsl:when test="(name() = 'TypeName')">
<r:tuple>
<r:literal><xsl:value-of select="aName[1]" /></r:literal>
<r:uri><xsl:value-of select="scope[1]" /></r:uri>
</r:tuple>
</xsl:when>
<xsl:when test="(name() = 'MemberName')">
<r:tuple>
<r:literal><xsl:value-of select="aName[1]" /></r:literal>
<r:uri><xsl:value-of select="attributeType/aName[1]" /></r:uri>
</r:tuple>
</xsl:when>
<xsl:when test="gco:LocalName/@codeSpace | gco:ScopedName/@codeSpace">
<r:tuple>
<r:literal><xsl:value-of select="*[1]" /></r:literal>
<r:uri><xsl:value-of select="*[1]/@codeSpace" /></r:uri>
</r:tuple>
</xsl:when>
<xsl:when test="@codeSpace">
<r:tuple>
<r:literal><xsl:value-of select="." /></r:literal>
<r:uri><xsl:value-of select="@codeSpace" /></r:uri>
</r:tuple>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR GRING PROPERTIES ==-->
<xsl:template name="sys-gring">
<xsl:choose>
<xsl:when test="contains(., ',')">
<r:literal><xsl:value-of select="normalize-space(translate(., ',', ' '))" /></r:literal>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR GENERIC BINARY PROPERTIES ==-->
<xsl:template name="sys-generic-binary">
<xsl:choose>
<xsl:when test="./@src">
<r:tuple>
<r:literal><xsl:value-of select="." /></r:literal>
<r:uri><xsl:value-of select="./@src" /></r:uri>
</r:tuple>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="." /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--== GENERIC TEMPLATE FOR CODE PROPERTIES ==-->
<xsl:template name="sys-code">
<xsl:choose>
<xsl:when test="count (@codeList | @codeListValue | @codeSpace) &gt; 1">
<r:tuple>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
<r:uri><xsl:value-of select="@codeList" /></r:uri>
<r:literal><xsl:value-of select="@codeListValue" /></r:literal>
<xsl:if test="@codeSpace">
<r:literal><xsl:value-of select="@codeSpace" /></r:literal>
</xsl:if>
</r:tuple>
</xsl:when>
<xsl:when test="@value">
<r:literal><xsl:value-of select="@value" /></r:literal>
</xsl:when>
<xsl:otherwise>
<r:literal><xsl:value-of select="normalize-space(.)" /></r:literal>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>

