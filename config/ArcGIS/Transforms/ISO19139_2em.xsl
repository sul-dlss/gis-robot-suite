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
<xsl:template match="gmd:MD_Metadata">
<xsl:param name="subject" />
<r:assert relation="em:sourceMetadataSchema">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<r:literal><![CDATA[iso19139]]></r:literal>
</r:assert>
<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[(gmd:thesaurusName/@uuidref='723f6998-058e-11dc-8314-0800200c9a66')]/gmd:keyword/gco:CharacterString[. != ''] | gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/@uuidref='723f6998-058e-11dc-8314-0800200c9a66')]/gmd:keyword/gco:CharacterString[(text() = 'Live Data and Maps') or (text() = 'Downloadable Data') or (text() = 'Offline Data') or (text() = 'Static Map Images') or (text() = 'Other Documents') or (text() = 'Clearinghouses') or (text() = 'Applications') or (text() = 'Geographic Services') or (text() = 'Map Files') or (text() = 'Geographic Activities')]">
<r:assert relation="em:onLineDescription">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification[(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; 0) and (count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[. &gt; 0]) &gt; 1)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:scaleRange">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="esriScaleRange1">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification[(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; 0) and (count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[. &gt; 0]) = 1)]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:scaleRange">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="esriScaleRange2">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:fileIdentifier">
<r:assert relation="em:fileIdentifier">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:language/gmd:LanguageCode">
<r:assert relation="em:languageCode">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:language[gco:CharacterString]">
<r:assert relation="em:language">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:characterSet/gmd:MD_CharacterSetCode">
<r:assert relation="em:characterSet">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:parentIdentifier">
<r:assert relation="em:parentFileIdentifier">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode">
<r:assert relation="em:hierarchyLevel">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:hierarchyLevelName">
<r:assert relation="em:hierarchyLevelName">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:contact">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:contact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:dateStamp">
<r:assert relation="em:dateStamp">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:metadataStandardName">
<r:assert relation="em:metadataStandardName">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:metadataStandardVersion">
<r:assert relation="em:metadataStandardVersion">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dataSetURI">
<r:assert relation="em:dataSetURI">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:locale/gmd:PT_Locale">
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
<xsl:for-each select="gmd:locale">
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
<xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation">
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
<xsl:for-each select="gmd:spatialRepresentationInfo">
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
<xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_Georectified">
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
<xsl:for-each select="gmd:spatialRepresentationInfo">
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
<xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_Georeferenceable">
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
<xsl:for-each select="gmd:spatialRepresentationInfo">
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
<xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation">
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
<xsl:for-each select="gmd:spatialRepresentationInfo">
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
<xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
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
<xsl:for-each select="gmd:metadataExtensionInfo/gmd:MD_MetadataExtensionInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:metadataExtensionInfo">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MetadataExtensionInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:metadataExtensionInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:identificationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DataIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:identificationInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:identificationInfo/srv:SV_ServiceIdentification">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:serviceIdentificationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_ServiceIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:identificationInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:contentInfo/gmd:MD_ImageDescription">
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
<xsl:for-each select="gmd:contentInfo">
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
<xsl:for-each select="gmd:contentInfo/gmd:MD_CoverageDescription">
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
<xsl:for-each select="gmd:contentInfo">
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
<xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
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
<xsl:for-each select="gmd:contentInfo">
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
<xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributionInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distribution">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributionInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:dataQualityInfo/gmd:DQ_DataQuality">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:dataQualityInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_DataQuality">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:dataQualityInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:portrayalCatalogueInfo/gmd:MD_PortrayalCatalogueReference">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:portrayalCatalogueInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_PortrayalCatalogueReference">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:portrayalCatalogueInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:metadataConstraints/gmd:MD_LegalConstraints">
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
<xsl:for-each select="gmd:metadataConstraints">
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
<xsl:for-each select="gmd:metadataConstraints/gmd:MD_SecurityConstraints">
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
<xsl:for-each select="gmd:metadataConstraints">
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
<xsl:for-each select="gmd:metadataConstraints/gmd:MD_Constraints/gmd:useLimitation">
<r:assert relation="em:useLimitation">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:applicationSchemaInfo/gmd:MD_ApplicationSchemaInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:applicationSchemaInfo">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ApplicationSchemaInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:applicationSchemaInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:metadataMaintenance/gmd:MD_MaintenanceInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:metadataMaintenance">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MaintenanceInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:metadataMaintenance">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:describes/gmd:DS_DataSet">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:describes">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DS_DataSet">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:propertyType">
<r:assert relation="em:propertyType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:featureType">
<r:assert relation="em:featureType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:featureAttribute">
<r:assert relation="em:featureAttribute">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_OtherAggregate">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:otherAggregateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:otherAggregateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_StereoMate">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:stereoMateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:stereoMateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_Series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:series">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:series">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_ProductionSeries">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:productionSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:productionSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_Sensor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:sensorSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:sensorSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_Platform">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:platformSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:platformSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:DS_Initiative">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:initiativeSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:initiativeSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:MX_Aggregate">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:mxAggregateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:mxAggregateSeries">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="AbstractDS_Aggregate">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== esriScaleRange1 ==-->
<xsl:template name="esriScaleRange1">
<xsl:param name="subject" />
<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[not(../../../../../../gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &lt; .)]">
<r:assert relation="em:maxScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[not(../../../../../../gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer &gt; .)]">
<r:assert relation="em:minScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== esriScaleRange2 ==-->
<xsl:template name="esriScaleRange2">
<xsl:param name="subject" />
<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[(. &gt; 0)]">
<r:assert relation="em:singleScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DS_DataSet ==-->
<xsl:template name="DS_DataSet">
<xsl:param name="subject" />
<xsl:apply-templates />
</xsl:template>
<!--== AbstractDS_Aggregate ==-->
<xsl:template name="AbstractDS_Aggregate">
<xsl:param name="subject" />
<xsl:apply-templates />
</xsl:template>
<!--== PT_Locale ==-->
<xsl:template name="PT_Locale">
<xsl:param name="subject" />
<xsl:for-each select="gmd:languageCode/gmd:LanguageCode">
<r:assert relation="em:languageCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:country/gmd:Country">
<r:assert relation="em:countryCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:characterEncoding/gmd:MD_CharacterSetCode">
<r:assert relation="em:characterEncoding">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_MetadataExtensionInformation ==-->
<xsl:template name="MD_MetadataExtensionInformation">
<xsl:param name="subject" />
<xsl:for-each select="gmd:extensionOnLineResource/gmd:CI_OnlineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:extensionOnLineResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:extensionOnLineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:extendedElementInformation/gmd:MD_ExtendedElementInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:extendedElementInformation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ExtendedElementInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:extendedElementInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:name">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:shortName">
<r:assert relation="em:shortName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:domainCode">
<r:assert relation="em:domainCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:definition">
<r:assert relation="em:definition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:obligation/gmd:MD_ObligationCode">
<r:assert relation="em:obligation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:condition">
<r:assert relation="em:condition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dataType/gmd:MD_DatatypeCode">
<r:assert relation="em:dataType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:maximumOccurrence">
<r:assert relation="em:maximumOccurrence">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:domainValue">
<r:assert relation="em:domainValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:parentEntity">
<r:assert relation="em:parentEntity">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:rule">
<r:assert relation="em:rule">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:rationale">
<r:assert relation="em:rationale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:source/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:source">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:name/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:name">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:schemaLanguage">
<r:assert relation="em:schemaLanguage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:constraintLanguage">
<r:assert relation="em:constraintLanguage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:schemaAscii">
<r:assert relation="em:schemaAscii">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:graphicsFile">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:graphicsFile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="Binary">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:softwareDevelopmentFile">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:softwareDevelopmentFile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="Binary">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:softwareDevelopmentFileFormat">
<r:assert relation="em:softwareDevelopmentFileFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== Binary ==-->
<xsl:template name="Binary">
<xsl:param name="subject" />
<xsl:for-each select="gco:Binary/@src">
<r:assert relation="em:binarySource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gco:Binary">
<r:assert relation="em:binaryFile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Distribution ==-->
<xsl:template name="MD_Distribution">
<xsl:param name="subject" />
<xsl:for-each select="gmd:distributionFormat/gmd:MD_Format">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributionFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributionFormat">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:distributor/gmd:MD_Distributor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distributor">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:transferOptions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DigitalTransferOptions">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:transferOptions">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:scope/gmd:DQ_Scope">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:scope">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Scope">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:scope">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:report/gmd:DQ_CompletenessOmission">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_CompletenessCommission">
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
<xsl:for-each select="gmd:report/gmd:DQ_TopologicalConsistency">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_FormatConsistency">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_DomainConsistency">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_ConceptualConsistency">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_RelativeInternalPositionalAccuracy">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_GriddedDataPositionalAccuracy">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_AbsoluteExternalPositionalAccuracy">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_QuantitativeAttributeAccuracy">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_NonQuantitativeAttributeAccuracy">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_ThematicClassificationCorrectness">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_TemporalValidity">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_TemporalConsistency">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:report/gmd:DQ_AccuracyOfATimeMeasurement">
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
<xsl:for-each select="gmd:report">
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
<xsl:for-each select="gmd:lineage/gmd:LI_Lineage">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:lineage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Lineage">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:lineage">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:statement">
<r:assert relation="em:statement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:processStep/gmd:LI_ProcessStep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:processStep">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_ProcessStep">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:processStep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:source/gmd:LI_Source">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Source">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:source">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:description">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:scaleDenominator/gmd:MD_RepresentativeFraction/gmd:denominator">
<r:assert relation="em:scaleDenominator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:sourceCitation/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:sourceCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:sourceCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:sourceExtent/gmd:EX_Extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:sourceExtent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:sourceExtent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:sourceStep/gmd:LI_ProcessStep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:sourceStep">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_ProcessStep">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:sourceStep">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:sourceReferenceSystem/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier">
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
<xsl:for-each select="gmd:description">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:rationale">
<r:assert relation="em:rationale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:source/gmd:LI_Source">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="LI_Source">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:source">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:processor/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:processor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:processor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:dateTime[. != '']">
<r:assert relation="em:dateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dateTime/@gco:nilReason">
<r:assert relation="em:dateTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_Element ==-->
<xsl:template name="DQ_Element">
<xsl:param name="subject" />
<xsl:for-each select="gmd:nameOfMeasure">
<r:assert relation="em:nameOfMeasure">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:measureIdentification/gmd:MD_Identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:measureIdentification">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:measureDescription">
<r:assert relation="em:measureDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:evaluationMethodType/gmd:DQ_EvaluationMethodTypeCode">
<r:assert relation="em:evaluationMethodType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:evaluationMethodDescription">
<r:assert relation="em:evaluationMethodDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:evaluationProcedure/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:evaluationProcedure">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:evaluationProcedure">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:result/gmd:DQ_ConformanceResult">
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
<xsl:for-each select="gmd:result">
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
<xsl:for-each select="gmd:result/gmd:DQ_QuantitativeResult">
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
<xsl:for-each select="gmd:result">
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
<xsl:for-each select="gmd:dateTime">
<r:assert relation="em:dateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_ConformanceResult ==-->
<xsl:template name="DQ_ConformanceResult">
<xsl:param name="subject" />
<xsl:for-each select="gmd:specification/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:specification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:specification">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:explanation">
<r:assert relation="em:explanation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:pass">
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
<xsl:for-each select="gmd:valueType/gco:RecordType">
<r:assert relation="em:valueType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:valueUnit/gml:UnitDefinition">
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
<xsl:for-each select="gmd:errorStatistic">
<r:assert relation="em:errorStatistic">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:value/gco:Record">
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
<xsl:for-each select="gmd:level/gmd:MD_ScopeCode">
<r:assert relation="em:level">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:extent/gmd:EX_Extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:levelDescription/gmd:MD_ScopeDescription">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:levelDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ScopeDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:levelDescription">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:portrayalCatalogueCitation/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:portrayalCatalogueCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:portrayalCatalogueCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:complianceCode">
<r:assert relation="em:complianceCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:language/gmd:LanguageCode">
<r:assert relation="em:languageCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:language[gco:CharacterString]">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:includedWithDataset">
<r:assert relation="em:includedWithDataset">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:featureTypes">
<r:assert relation="em:featureTypes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:featureCatalogueCitation/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:featureCatalogueCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:featureCatalogueCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:attributeDescription/gco:RecordType">
<r:assert relation="em:attributeDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:contentType/gmd:MD_CoverageContentTypeCode">
<r:assert relation="em:contentType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dimension/gmd:MD_RangeDimension">
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
<xsl:for-each select="gmd:dimension">
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
<xsl:for-each select="gmd:dimension/gmd:MD_Band">
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
<xsl:for-each select="gmd:dimension">
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
<xsl:for-each select="gmd:sequenceIdentifier/gco:MemberName">
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
<xsl:for-each select="gmd:descriptor">
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
<xsl:for-each select="gmd:maxValue">
<r:assert relation="em:maxValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:minValue">
<r:assert relation="em:minValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:units/gml:UnitDefinition">
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
<xsl:for-each select="gmd:peakResponse">
<r:assert relation="em:peakResponse">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:bitsPerValue">
<r:assert relation="em:bitsPerValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:toneGradation">
<r:assert relation="em:toneGradation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:scaleFactor">
<r:assert relation="em:scaleFactor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:offset">
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
<xsl:for-each select="@gml:id">
<r:assert relation="em:id">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:description">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:descriptionReference/@xlink:href">
<r:assert relation="em:descriptionReference">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:identifier">
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:name">
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
<xsl:for-each select="gml:remarks">
<r:assert relation="em:remarks">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:quantityType">
<r:assert relation="em:quantityType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:quantityTypeReference/@xlink:href">
<r:assert relation="em:quantityTypeReference">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:catalogSymbol">
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
<xsl:for-each select="@xlink:href">
<r:assert relation="em:href">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="@xlink:title">
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
<xsl:for-each select="gco:aName">
<r:assert relation="em:aName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gco:attributeType/gco:TypeName/gco:aName">
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
<xsl:for-each select="gmd:illuminationElevationAngle">
<r:assert relation="em:illuminationElevationAngle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:illuminationAzimuthAngle">
<r:assert relation="em:illuminationAzimuthAngle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:imagingCondition/gmd:MD_ImagingConditionCode">
<r:assert relation="em:imagingCondition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:imageQualityCode/gmd:MD_Identifier">
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
<xsl:for-each select="gmd:cloudCoverPercentage">
<r:assert relation="em:cloudCoverPercentage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:processingLevelCode/gmd:MD_Identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:processingLevelCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:processingLevelCode">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:compressionGenerationQuantity">
<r:assert relation="em:compressionGenerationQuantity">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:triangulationIndicator">
<r:assert relation="em:triangulationIndicator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:radiometricCalibrationDataAvailability">
<r:assert relation="em:radiometricCalibrationDataAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:cameraCalibrationInformationAvailability">
<r:assert relation="em:cameraCalibrationInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:filmDistortionInformationAvailability">
<r:assert relation="em:filmDistortionInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:lensDistortionInformationAvailability">
<r:assert relation="em:lensDistortionInformationAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Identification ==-->
<xsl:template name="MD_Identification">
<xsl:param name="subject" />
<xsl:for-each select="gmd:citation/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:citation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:abstract">
<r:assert relation="em:abstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:purpose">
<r:assert relation="em:purpose">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:credit">
<r:assert relation="em:credit">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:status/gmd:MD_ProgressCode">
<r:assert relation="em:status">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:pointOfContact/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:pointOfContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:pointOfContact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:resourceMaintenance/gmd:MD_MaintenanceInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:resourceMaintenance">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_MaintenanceInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:resourceMaintenance">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:graphicOverview/gmd:MD_BrowseGraphic[not(starts-with(gmd:fileName/gco:CharacterString, 'base64data: '))]">
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
<xsl:for-each select="gmd:resourceFormat/gmd:MD_Format">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:resourceFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:resourceFormat">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='discipline']">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='place']">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='stratum']">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='temporal']">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue='theme']">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:type) and not(gmd:thesaurusName/@uuidref='723f6998-058e-11dc-8314-0800200c9a66')]">
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
<xsl:for-each select="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName/@uuidref='723f6998-058e-11dc-8314-0800200c9a66')]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:searchKeywords">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Keywords">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:resourceSpecificUsage/gmd:MD_Usage">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:resourceSpecificUsage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Usage">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:resourceSpecificUsage">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints">
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
<xsl:for-each select="gmd:resourceConstraints">
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
<xsl:for-each select="gmd:resourceConstraints/gmd:MD_SecurityConstraints">
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
<xsl:for-each select="gmd:resourceConstraints">
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
<xsl:for-each select="gmd:resourceConstraints/gmd:MD_Constraints/gmd:useLimitation">
<r:assert relation="em:useLimitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:aggregationInfo/gmd:MD_AggregateInformation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:aggregationInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_AggregateInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:aggregationInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:apply-templates />
</xsl:template>
<!--== MD_DataIdentification ==-->
<xsl:template name="MD_DataIdentification">
<xsl:param name="subject" />
<xsl:call-template name="MD_Identification">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
<r:assert relation="em:spatialRepresentationType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:spatialResolution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Resolution">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:spatialResolution">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:spatialResolution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Resolution">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:language/gmd:LanguageCode">
<r:assert relation="em:languageCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:language[gco:CharacterString]">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:characterSet/gmd:MD_CharacterSetCode">
<r:assert relation="em:characterSet">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
<r:assert relation="em:topicCategory">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:environmentDescription">
<r:assert relation="em:environmentDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:extent[.//gmd:EX_GeographicBoundingBox[(./gmd:extentTypeCode/gco:Boolean = 'true') or (./gmd:extentTypeCode/gco:Boolean = '1') or not(./gmd:extentTypeCode)]][1]/gmd:EX_Extent/gmd:geographicElement[.//gmd:EX_GeographicBoundingBox[(./gmd:extentTypeCode/gco:Boolean = 'true') or (./gmd:extentTypeCode/gco:Boolean = '1') or not(./gmd:extentTypeCode)]][1]/gmd:EX_GeographicBoundingBox[(./gmd:extentTypeCode/gco:Boolean = 'true') or (./gmd:extentTypeCode/gco:Boolean = '1') or not(./gmd:extentTypeCode)][1]">
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
<xsl:for-each select="gmd:extent/gmd:EX_Extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:supplementalInformation">
<r:assert relation="em:supplementalInformation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_AggregateInformation ==-->
<xsl:template name="MD_AggregateInformation">
<xsl:param name="subject" />
<xsl:for-each select="gmd:aggregateDataSetName/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:aggregateDataSetName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:aggregateDataSetName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:aggregateDataSetIdentifier/gmd:MD_Identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:aggregateDataSetIdentifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:aggregateDataSetIdentifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:associationType/gmd:DS_AssociationTypeCode">
<r:assert relation="em:associationType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:initiativeType/gmd:DS_InitiativeTypeCode">
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
<xsl:for-each select="gmd:description">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:geographicElement/gmd:EX_BoundingPolygon">
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
<xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicBoundingBox">
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
<xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription">
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
<xsl:for-each select="gmd:temporalElement/gmd:EX_TemporalExtent">
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
<xsl:for-each select="gmd:temporalElement">
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
<xsl:for-each select="gmd:temporalElement/gmd:EX_SpatialTemporalExtent">
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
<xsl:for-each select="gmd:temporalElement">
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
<xsl:for-each select="gmd:verticalElement/gmd:EX_VerticalExtent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:verticalElement">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_VerticalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:verticalElement">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:spatialExtent/gmd:EX_BoundingPolygon">
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
<xsl:for-each select="gmd:spatialExtent/gmd:EX_GeographicBoundingBox">
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
<xsl:for-each select="gmd:spatialExtent/gmd:EX_GeographicDescription">
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
<xsl:for-each select="gmd:extent/gml:TimeInstant">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:timeInstant">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="TimeInstantObj">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="gmd:extent/gml:TimePeriod">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:timePeriod">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="TimePeriod">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<!--== TimePeriod ==-->
<xsl:template name="TimePeriod">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="gml:beginPosition | gml:begin/gml:TimeInstant/gml:timePosition">
<r:assert relation="em:beginTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:beginPosition/@indeterminatePosition | gml:begin/gml:TimeInstant/gml:timePosition/@indeterminatePosition">
<r:assert relation="em:beginTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:endPosition | gml:end/gml:TimeInstant/gml:timePosition">
<r:assert relation="em:endTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:endPosition/@indeterminatePosition | gml:end/gml:TimeInstant/gml:timePosition/@indeterminatePosition">
<r:assert relation="em:endTimeNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== TimeInstantObj ==-->
<xsl:template name="TimeInstantObj">
<xsl:param name="subject" />
<xsl:call-template name="gml_StandardProperties">
<xsl:with-param name="subject"><xsl:copy-of select="$subject" /></xsl:with-param>
</xsl:call-template>
<xsl:for-each select="gml:timePosition">
<r:assert relation="em:timePosition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:timePosition/@indeterminatePosition">
<r:assert relation="em:timePositionNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_VerticalExtent ==-->
<xsl:template name="EX_VerticalExtent">
<xsl:param name="subject" />
<xsl:for-each select="gmd:minimumValue">
<r:assert relation="em:minimumValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:maximumValue">
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
<xsl:for-each select="gmd:extentTypeCode">
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
<xsl:for-each select="gmd:polygon/gml:Polygon">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:polygon">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_Polygon">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:polygon">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gml:exterior/gml:LinearRing">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:exterior">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_LinearRing">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gml:exterior">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gml:interior/gml:LinearRing">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:interior">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_LinearRing">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gml:interior">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gml:pos">
<r:assert relation="em:pos">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gml:posList">
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
<xsl:for-each select="gmd:westBoundLongitude">
<r:assert relation="em:westBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:eastBoundLongitude">
<r:assert relation="em:eastBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:southBoundLatitude">
<r:assert relation="em:southBoundLatitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:northBoundLatitude">
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
<xsl:for-each select="gmd:geographicIdentifier/gmd:MD_Identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:geographicIdentifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator">
<r:assert relation="em:equivalentScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:distance">
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
<xsl:for-each select="gmd:useLimitation">
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
<xsl:for-each select="gmd:accessConstraints/gmd:MD_RestrictionCode">
<r:assert relation="em:accessConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:useConstraints/gmd:MD_RestrictionCode">
<r:assert relation="em:useConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:otherConstraints">
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
<xsl:for-each select="gmd:classification/gmd:MD_ClassificationCode">
<r:assert relation="em:classification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:userNote">
<r:assert relation="em:note">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:classificationSystem">
<r:assert relation="em:classificationSystem">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:handlingDescription">
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
<xsl:for-each select="gmd:specificUsage">
<r:assert relation="em:specificUsage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:usageDateTime">
<r:assert relation="em:usageDateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:userDeterminedLimitations">
<r:assert relation="em:userDeterminedLimitations">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:userContactInfo/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:userContactInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:userContactInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:attributes">
<r:assert relation="em:attributes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:features">
<r:assert relation="em:features">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:featureInstances">
<r:assert relation="em:featureInstances">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:attributeInstances">
<r:assert relation="em:attributeInstances">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-objref" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dataset">
<r:assert relation="em:dataset">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:other">
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
<xsl:for-each select="gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode">
<r:assert relation="em:maintenanceAndUpdateFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dateOfNextUpdate">
<r:assert relation="em:dateOfNextUpdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:userDefinedMaintenanceFrequency">
<r:assert relation="em:userDefinedMaintenanceFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:updateScope/gmd:MD_ScopeCode">
<r:assert relation="em:updateScope">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:updateScopeDescription/gmd:MD_ScopeDescription">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:updateScopeDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_ScopeDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:updateScopeDescription">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:maintenanceNote">
<r:assert relation="em:maintenanceNote">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:contact/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:maintenanceContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:contact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:apply-templates />
</xsl:template>
<!--== MD_BrowseGraphic ==-->
<xsl:template name="MD_BrowseGraphic">
<xsl:param name="subject" />
<xsl:for-each select="gmd:fileName">
<r:assert relation="em:fileName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:fileDescription">
<r:assert relation="em:fileDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:fileType">
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
<xsl:for-each select="gmd:name">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:version">
<r:assert relation="em:version">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:amendmentNumber">
<r:assert relation="em:amendmentNumber">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:specification">
<r:assert relation="em:specification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:fileDecompressionTechnique">
<r:assert relation="em:fileDecompressionTechnique">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:formatDistributor/gmd:MD_Distributor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:formatDistributor">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Distributor">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:formatDistributor">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:distributorContact/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributorContact">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributorContact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributionOrderProcess">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_StandardOrderProcess">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributionOrderProcess">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:distributorFormat/gmd:MD_Format">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributorFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Format">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributorFormat">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:distributorTransferOptions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DigitalTransferOptions">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:distributorTransferOptions">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:unitsOfDistribution">
<r:assert relation="em:unitsOfDistribution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:transferSize">
<r:assert relation="em:transferSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:onLine/gmd:CI_OnlineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:onLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:onLine">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:offLine/gmd:MD_Medium">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:offLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Medium">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:offLine">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:name/gmd:MD_MediumNameCode">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:density">
<r:assert relation="em:density">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:densityUnits">
<r:assert relation="em:densityUnits">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:volumes">
<r:assert relation="em:volumes">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:mediumFormat/gmd:MD_MediumFormatCode">
<r:assert relation="em:mediumFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:mediumNote">
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
<xsl:for-each select="gmd:fees">
<r:assert relation="em:fees">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:orderingInstructions">
<r:assert relation="em:orderingInstructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:turnaround">
<r:assert relation="em:turnaround">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:plannedAvailableDateTime">
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
<xsl:for-each select="gmd:keyword">
<r:assert relation="em:keyword">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:thesaurusName/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:thesaurusName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:thesaurusName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:type/gmd:MD_KeywordTypeCode">
<r:assert relation="em:type">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Citation ==-->
<xsl:template name="CI_Citation">
<xsl:param name="subject" />
<xsl:for-each select="gmd:title">
<r:assert relation="em:title">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:alternateTitle">
<r:assert relation="em:alternateTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date[. != '']">
<r:assert relation="em:creationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date/@gco:nilReason">
<r:assert relation="em:creationDateNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']/gmd:date[. != '']">
<r:assert relation="em:publicationDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']/gmd:date/@gco:nilReason">
<r:assert relation="em:publicationDateNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date[. != '']">
<r:assert relation="em:revisionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/@gco:nilReason">
<r:assert relation="em:revisionDateNil">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:edition">
<r:assert relation="em:edition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:editionDate">
<r:assert relation="em:editionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:identifier/gmd:MD_Identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:identifier">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Identifier">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:identifier">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:citedResponsibleParty">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:citedResponsibleParty">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:presentationForm/gmd:CI_PresentationFormCode">
<r:assert relation="em:presentationForm">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:series/gmd:CI_Series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:series">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Series">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:series">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:otherCitationDetails">
<r:assert relation="em:otherCitationDetails">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:collectiveTitle">
<r:assert relation="em:collectiveTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:ISBN">
<r:assert relation="em:ISBN">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:ISSN">
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
<xsl:for-each select="gmd:name">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:issueIdentification">
<r:assert relation="em:issueIdentification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:page">
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
<xsl:for-each select="gmd:authority/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:authority">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:authority">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:code">
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
<xsl:for-each select="gmd:codeSpace">
<r:assert relation="em:codeSpace">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:version">
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
<xsl:for-each select="gmd:numberOfDimensions">
<r:assert relation="em:numberOfDimensions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:axisDimensionProperties/gmd:MD_Dimension">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:axisDimensionProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_Dimension">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:axisDimensionProperties">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:cellGeometry/gmd:MD_CellGeometryCode">
<r:assert relation="em:cellGeometry">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:transformationParameterAvailability">
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
<xsl:for-each select="gmd:checkPointAvailability">
<r:assert relation="em:checkPointAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:checkPointDescription">
<r:assert relation="em:checkPointDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:cornerPoints/gml:Point">
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
<xsl:for-each select="gmd:centerPoint/gml:Point">
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
<xsl:for-each select="gmd:pointInPixel/gmd:MD_PixelOrientationCode">
<r:assert relation="em:pointInPixel">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:transformationDimensionDescription">
<r:assert relation="em:transformationDimensionDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:transformationDimensionMapping">
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
<xsl:for-each select="gml:pos">
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
<xsl:for-each select="gmd:controlPointAvailability">
<r:assert relation="em:controlPointAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:orientationParameterAvailability">
<r:assert relation="em:orientationParameterAvailability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:orientationParameterDescription">
<r:assert relation="em:orientationParameterDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:georeferencedParameters/gco:Record">
<r:assert relation="em:georeferencedParameters">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:parameterCitation/gmd:CI_Citation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:parameterCitation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Citation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:parameterCitation">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:topologyLevel/gmd:MD_TopologyLevelCode">
<r:assert relation="em:topologyLevel">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:geometricObjects/gmd:MD_GeometricObjects">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:geometricObjects">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_GeometricObjects">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:geometricObjects">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode">
<r:assert relation="em:geometricObjectType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:geometricObjectCount">
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
<xsl:for-each select="gmd:dimensionName/gmd:MD_DimensionNameTypeCode">
<r:assert relation="em:dimensionName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:dimensionSize">
<r:assert relation="em:dimensionSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:resolution">
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
<xsl:for-each select="gmd:individualName">
<r:assert relation="em:individualName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:organisationName">
<r:assert relation="em:organisationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:positionName">
<r:assert relation="em:position">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:contactInfo/gmd:CI_Contact">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:contactInfo">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Contact">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:contactInfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:role/gmd:CI_RoleCode">
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
<xsl:for-each select="gmd:address/gmd:CI_Address">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:address">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_Address">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:address">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:onlineResource/gmd:CI_OnlineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:onlineResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="gmd:onlineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="gmd:phone/gmd:CI_Telephone/gmd:voice">
<r:assert relation="em:voiceNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:phone/gmd:CI_Telephone/gmd:facsimile">
<r:assert relation="em:faxNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:hoursOfService">
<r:assert relation="em:hours">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:contactInstructions">
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
<xsl:for-each select="gmd:deliveryPoint">
<r:assert relation="em:deliveryPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:city">
<r:assert relation="em:city">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:administrativeArea">
<r:assert relation="em:administrativeArea">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:postalCode">
<r:assert relation="em:postalCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:country/gmd:Country">
<r:assert relation="em:countryCode">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:country[gco:CharacterString]">
<r:assert relation="em:country">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:electronicMailAddress">
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
<xsl:for-each select="gmd:linkage/gmd:URL">
<r:assert relation="em:linkage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:protocol">
<r:assert relation="em:protocol">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:applicationProfile">
<r:assert relation="em:applicationProfile">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:name">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:description">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="gmd:function/gmd:CI_OnLineFunctionCode">
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
<xsl:for-each select="srv:serviceType">
<r:assert relation="em:serviceType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-generic-name" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:serviceTypeVersion">
<r:assert relation="em:serviceTypeVersion">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:accessProperties/gmd:MD_StandardOrderProcess">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:accessProperties">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_StandardOrderProcess">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:accessProperties">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:extent/gmd:EX_Extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:extent">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_Extent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:extent">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:coupledResource/srv:SV_CoupledResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:coupledResource">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_CoupledResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:coupledResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:couplingType/srv:SV_CouplingType">
<r:assert relation="em:couplingType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:containsOperations/srv:SV_OperationMetadata">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:containsOperations">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_OperationMetadata">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:containsOperations">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:operatesOn/gmd:MD_DataIdentification">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:operatesOn">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DataIdentification">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:operatesOn">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<!--== SV_OperationMetadata ==-->
<xsl:template name="SV_OperationMetadata">
<xsl:param name="subject" />
<xsl:for-each select="srv:operationName">
<r:assert relation="em:operationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:DCP/srv:DCPList">
<r:assert relation="em:DCP">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:operationDescription">
<r:assert relation="em:operationDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:invocationName">
<r:assert relation="em:invocationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:parameters/srv:SV_Parameter">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:parameters">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_Parameter">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:parameters">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:connectPoint/gmd:CI_OnlineResource">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:connectPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_OnlineResource">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:connectPoint">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:dependsOn/srv:SV_OperationMetadata">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:dependsOn">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="SV_OperationMetadata">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:dependsOn">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:name/gco:MemberName">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<r:assert relation="em:paramName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MemberName">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:for-each>
<xsl:for-each select="srv:name">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj2" />
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
<xsl:for-each select="srv:direction/srv:SV_ParameterDirection">
<r:assert relation="em:direction">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:description">
<r:assert relation="em:paramDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:optionality">
<r:assert relation="em:optionality">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:repeatability">
<r:assert relation="em:repeatability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-boolean" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:valueType/gco:TypeName/gco:aName">
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
<xsl:for-each select="srv:operationName">
<r:assert relation="em:operationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srv:identifier">
<r:assert relation="em:resourceIdentifier">
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

