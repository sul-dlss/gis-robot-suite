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
<r:assert relation="em:sourceMetadataSchema">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<r:literal><![CDATA[fgdc]]></r:literal>
</r:assert>
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
<xsl:for-each select="distinfo/resdesc[(text() = 'Live Data and Maps') or (text() = 'Downloadable Data') or (text() = 'Offline Data') or (text() = 'Static Map Images') or (text() = 'Other Documents') or (text() = 'Clearinghouses') or (text() = 'Applications') or (text() = 'Geographic Services') or (text() = 'Map Files') or (text() = 'Geographic Activities')]">
<r:assert relation="em:onLineDescription">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="dataqual/lineage[(srcinfo/srcscale &gt; 0) and (count(srcinfo/srcscale[. &gt; 0]) &gt; 1)]">
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
<xsl:for-each select="dataqual/lineage[(srcinfo/srcscale &gt; 0) and (count(srcinfo/srcscale[. &gt; 0]) = 1)]">
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
<xsl:for-each select="metainfo/metd">
<r:assert relation="em:dateStamp">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo[metrd | metfrd]">
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
<xsl:for-each select="metainfo/metstdn">
<r:assert relation="em:metadataStandardName">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo/metstdv">
<r:assert relation="em:metadataStandardVersion">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo/metextns/metprof">
<r:assert relation="em:metadataProfileName">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo/metc/cntinfo">
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
<xsl:for-each select="metainfo/metac[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')]">
<r:assert relation="em:accessConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo/metuc[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')]">
<r:assert relation="em:useConstraints">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metainfo/metsi">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="metainfo/langmeta">
<r:assert relation="em:language">
<r:qname><xsl:value-of select="$RESOURCE_META" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="idinfo">
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
<xsl:for-each select="dataqual">
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
<xsl:for-each select="dataqual/cloud[not(. = 'unknown') and number(.)]">
<r:assert relation="em:fcloudCoverPercentage">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="/metadata[distinfo | idinfo/citation/citeinfo/onlink != 'withheld']">
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
<xsl:for-each select="spdoinfo/rastinfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="spdoinfo/ptvctinf">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="spdoinfo/indspref">
<r:assert relation="em:indirectSpatialRepresentationInfo">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eainfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:fields">
<r:qname><xsl:value-of select="$RESOURCE" /></r:qname>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="Fields">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== esriScaleRange1 ==-->
<xsl:template name="esriScaleRange1">
<xsl:param name="subject" />
<xsl:for-each select="srcinfo/srcscale[not(../../srcinfo/srcscale &lt; .)]">
<r:assert relation="em:maxScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srcinfo/srcscale[not(../../srcinfo/srcscale &gt; .)]">
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
<xsl:for-each select="srcinfo/srcscale[(. &gt; 0)]">
<r:assert relation="em:singleScale">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_MetadataExtensionInformation ==-->
<xsl:template name="MD_MetadataExtensionInformation">
<xsl:param name="subject" />
<xsl:apply-templates />
</xsl:template>
<!--== DQ_DataQuality ==-->
<xsl:template name="DQ_DataQuality">
<xsl:param name="subject" />
<xsl:for-each select="attracc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:attributeAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="logic">
<r:assert relation="em:logicalConsistencyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="complete">
<r:assert relation="em:completenessReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="posacc/horizpa">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:horizPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="posacc/vertacc">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:vertPositionalAccuracyReport">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="DQ_Element">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="lineage">
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
<r:assert relation="em:scope">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<r:literal><xsl:value-of select="string('dataset')" /></r:literal>
</r:assert>
<xsl:apply-templates />
</xsl:template>
<!--== LI_Lineage ==-->
<xsl:template name="LI_Lineage">
<xsl:param name="subject" />
<xsl:for-each select="srcinfo">
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
<xsl:for-each select="procstep[(procdesc != 'Dataset copied.') and (procdesc != 'Metadata imported.')]">
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
<xsl:apply-templates />
</xsl:template>
<!--== LI_Source ==-->
<xsl:template name="LI_Source">
<xsl:param name="subject" />
<xsl:for-each select="srccite/citeinfo">
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
<xsl:for-each select="srcscale">
<r:assert relation="em:scaleDenominator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="typesrc">
<r:assert relation="em:fmedia">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srccontr">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srctime">
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
<xsl:apply-templates />
</xsl:template>
<!--== LI_ProcessStep ==-->
<xsl:template name="LI_ProcessStep">
<xsl:param name="subject" />
<xsl:for-each select="procdesc">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="procdate | date">
<r:assert relation="em:fdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="proctime | time">
<r:assert relation="em:ftime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="proccont/cntinfo">
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
<xsl:for-each select="srcused[(. != 'withheld')]">
<r:assert relation="em:srcUsedAbbreviation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srcprod[(. != 'withheld')]">
<r:assert relation="em:srcProducedAbbreviation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== DQ_Element ==-->
<xsl:template name="DQ_Element">
<xsl:param name="subject" />
<xsl:for-each select="attraccr | horizpar | vertaccr">
<r:assert relation="em:measureDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="qattracc[1]/attracce | qhorizpa[1]/horizpae | qvertpa[1]/vertacce">
<r:assert relation="em:evaluationMethodDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="qattracc[1] | qhorizpa[1] | qvertpa[1]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<!--== DQ_QuantitativeResult ==-->
<xsl:template name="DQ_QuantitativeResult">
<xsl:param name="subject" />
<xsl:for-each select="attraccv | horizpav | vertaccv">
<r:assert relation="em:value">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_DataIdentification ==-->
<xsl:template name="MD_DataIdentification">
<xsl:param name="subject" />
<xsl:for-each select="descript/langdata">
<r:assert relation="em:language">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="citation/citeinfo">
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
<xsl:for-each select="descript/abstract">
<r:assert relation="em:abstract">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="descript/purpose">
<r:assert relation="em:purpose">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="descript/supplinf">
<r:assert relation="em:supplementalInformation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="spdom | timeperd">
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
<xsl:for-each select="status[update]">
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
<xsl:for-each select="status/progress">
<r:assert relation="em:fstatus">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="keywords/place">
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
<xsl:for-each select="keywords/stratum">
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
<xsl:for-each select="keywords/temporal">
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
<xsl:for-each select="keywords/theme">
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
<xsl:for-each select="keywords">
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
<xsl:for-each select="browse[(browsen != 'withheld')]">
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
<xsl:for-each select="natvform">
<r:assert relation="em:nativeDatasetFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="datacred">
<r:assert relation="em:credit">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="secinfo">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="native">
<r:assert relation="em:environmentDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="crossref">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:crossReference">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_AggregateInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="citation/citeinfo/lworkcit">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:largerWork">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_AggregateInformation">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="accconst[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')]">
<r:assert relation="em:accessConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="useconst[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')]">
<r:assert relation="em:useConstraints">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="../distinfo/distliab">
<r:assert relation="em:distributionLiability">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="ptcontac/cntinfo">
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
<xsl:for-each select="/metadata/spdoinfo/direct">
<r:assert relation="em:fspatialRepresentationType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="/idinfo/natvform">
<r:assert relation="em:fnativeType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_AggregateInformation ==-->
<xsl:template name="MD_AggregateInformation">
<xsl:param name="subject" />
<xsl:for-each select="citeinfo">
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
<xsl:apply-templates />
</xsl:template>
<!--== EX_Extent ==-->
<xsl:template name="EX_Extent">
<xsl:param name="subject" />
<xsl:for-each select="current">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="srccurr">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="bounding">
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
<xsl:for-each select="dsgpoly">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:boundingPolygon">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="GML_Polygon">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="timeinfo[sngdate | rngdates]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="timeinfo/mdattim/sngdate">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
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
<xsl:for-each select="minalti">
<r:assert relation="em:minVertical">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="maxalti">
<r:assert relation="em:maxVertical">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_TemporalExtent ==-->
<xsl:template name="EX_TemporalExtent">
<xsl:param name="subject" />
<xsl:for-each select="sngdate/caldate | caldate">
<r:assert relation="em:fdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="sngdate/time | time">
<r:assert relation="em:ftime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rngdates">
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
<!--== TimePeriod ==-->
<xsl:template name="TimePeriod">
<xsl:param name="subject" />
<xsl:for-each select="begdate">
<r:assert relation="em:fbeginDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="begtime">
<r:assert relation="em:fbeginTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enddate">
<r:assert relation="em:fendDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="endtime">
<r:assert relation="em:fendTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== GML_Polygon ==-->
<xsl:template name="GML_Polygon">
<xsl:param name="subject" />
<xsl:for-each select="dsgpolyo">
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
<xsl:for-each select="dsgpolyx">
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
<xsl:for-each select="grngpoin">
<r:assert relation="em:pos">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<r:literal><xsl:value-of select="concat (gringlon, ' ', gringlat)" /></r:literal>
</r:assert>
</xsl:for-each>
<xsl:for-each select="gring">
<r:assert relation="em:posList">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-gring" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EX_GeographicBoundingBox ==-->
<xsl:template name="EX_GeographicBoundingBox">
<xsl:param name="subject" />
<xsl:for-each select="westbc">
<r:assert relation="em:westBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eastbc">
<r:assert relation="em:eastBoundLongitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="southbc">
<r:assert relation="em:southBoundLatitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="northbc">
<r:assert relation="em:northBoundLatitude">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_SecurityConstraints ==-->
<xsl:template name="MD_SecurityConstraints">
<xsl:param name="subject" />
<xsl:for-each select="secsys | metscs">
<r:assert relation="em:classificationSystem">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="secclass | metsc">
<r:assert relation="em:fclassification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="sechandl | metshd">
<r:assert relation="em:handlingDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_MaintenanceInformation ==-->
<xsl:template name="MD_MaintenanceInformation">
<xsl:param name="subject" />
<xsl:for-each select="update">
<r:assert relation="em:fmaintenanceAndUpdateFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metrd">
<r:assert relation="em:metadataReviewDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="metfrd">
<r:assert relation="em:dateOfNextUpdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_BrowseGraphic ==-->
<xsl:template name="MD_BrowseGraphic">
<xsl:param name="subject" />
<xsl:for-each select="browsen[(. != 'withheld')]">
<r:assert relation="em:fileName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="browsed">
<r:assert relation="em:fileDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="browset">
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
<xsl:for-each select="formname">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formvern">
<r:assert relation="em:version">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formverd">
<r:assert relation="em:versionDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formspec">
<r:assert relation="em:specification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="filedec">
<r:assert relation="em:fileDecompressionTechnique">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="formcont">
<r:assert relation="em:contentDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="../../../techpreq">
<r:assert relation="em:technicalPrerequisite">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Distribution ==-->
<xsl:template name="MD_Distribution">
<xsl:param name="subject" />
<xsl:for-each select="idinfo/citation[(citeinfo/onlink != 'withheld')]">
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
<xsl:for-each select="distinfo/stdorder">
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
<xsl:for-each select="distinfo[not(stdorder) and (distrib or resdesc or custom or availabl)]">
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
<xsl:apply-templates />
</xsl:template>
<!--== MD_Distributor ==-->
<xsl:template name="MD_Distributor">
<xsl:param name="subject" />
<xsl:for-each select="distrib/cntinfo | ../distrib/cntinfo">
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
<xsl:for-each select="stdorder/digform/digtinfo[formname | formvern | formverd | formspec | formcont | filedec] | digform/digtinfo[formname | formvern | formverd | formspec | formcont | filedec]">
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
<xsl:for-each select="stdorder/digform/digtopt/onlinopt[(computer/networka/networkr != 'withheld')] | digform/digtopt/onlinopt[(computer/networka/networkr != 'withheld')]">
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
<xsl:for-each select="stdorder/digform/digtopt/offoptn | digform/digtopt/offoptn">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:offLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="MD_DigitalTransferOptions">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="stdorder/nondig | nondig">
<r:assert relation="em:fnonDigitalFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="stdorder | self::node()[(name() = 'stdorder') or custom or ../custom]">
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
<xsl:for-each select="resdesc[not((text() = 'Live Data and Maps') or (text() = 'Downloadable Data') or (text() = 'Offline Data') or (text() = 'Static Map Images') or (text() = 'Other Documents') or (text() = 'Clearinghouses') or (text() = 'Applications') or (text() = 'Geographic Services') or (text() = 'Map Files') or (text() = 'Geographic Activities'))]">
<r:assert relation="em:resourceDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="../resdesc[not((text() = 'Live Data and Maps') or (text() = 'Downloadable Data') or (text() = 'Offline Data') or (text() = 'Static Map Images') or (text() = 'Other Documents') or (text() = 'Clearinghouses') or (text() = 'Applications') or (text() = 'Geographic Services') or (text() = 'Map Files') or (text() = 'Geographic Activities'))]">
<r:assert relation="em:resourceDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="availabl[not(stdorder or ../stdorder or custom or ../custom)]">
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
<xsl:apply-templates />
</xsl:template>
<!--== MD_DigitalTransferOptions ==-->
<xsl:template name="MD_DigitalTransferOptions">
<xsl:param name="subject" />
<xsl:for-each select="../../digtinfo/transize | self::node()[(name() = 'transize')]">
<r:assert relation="em:transferSize">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="citeinfo/onlink[(. != 'withheld')] | computer/networka/networkr[(. != 'withheld')]">
<r:assert relation="em:fonLine">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="accinstr">
<r:assert relation="em:faccessInstructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="self::node()[(name() = 'offoptn')]">
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
<xsl:for-each select="offmedia">
<r:assert relation="em:fmedia">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="reccap/recden">
<r:assert relation="em:density">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="reccap/recdenu">
<r:assert relation="em:densityUnits">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="recfmt">
<r:assert relation="em:fmediumFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="compat">
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
<xsl:for-each select="fees">
<r:assert relation="em:fees">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="ordering | custom">
<r:assert relation="em:orderingInstructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="turnarnd">
<r:assert relation="em:turnaround">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="availabl/timeinfo//sngdate[1] | ../availabl/timeinfo//sngdate[1] | timeinfo//sngdate[1]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:plannedAvailableDateTime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_TemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="availabl/timeinfo[rngdates] | ../availabl/timeinfo[rngdates] | timeinfo[rngdates]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:plannedAvailableTimePeriod">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EX_TemporalExtent">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="nondig">
<r:assert relation="em:nonDigitalFormat">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_Keywords ==-->
<xsl:template name="MD_Keywords">
<xsl:param name="subject" />
<xsl:for-each select="themekey | placekey | stratkey | tempkey">
<r:assert relation="em:keyword">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="themekt[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')] | placekt[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')] | stratkt[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')] | tempkt[(. != 'None') and (. != 'none') and (. != 'NONE') and (. != 'None.')]">
<r:assert relation="em:thesaurusName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Citation ==-->
<xsl:template name="CI_Citation">
<xsl:param name="subject" />
<xsl:for-each select="title">
<r:assert relation="em:title">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="../../srccitea">
<r:assert relation="em:alternateTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="edition">
<r:assert relation="em:edition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="othercit">
<r:assert relation="em:otherCitationDetails">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="pubdate">
<r:assert relation="em:fdate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="pubtime">
<r:assert relation="em:ftime">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="geoform">
<r:assert relation="em:fpresentationForm">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="lworkcit/citeinfo/title">
<r:assert relation="em:collectiveTitle">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="serinfo">
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
<xsl:for-each select="origin">
<r:assert relation="em:originator">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="pubinfo[pubplace | publish]">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:publisher">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CI_ResponsibleParty_NameAndPlace">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="onlink[(. != '') and (. != 'withheld') and not(name(../..) = 'citation')]">
<r:assert relation="em:onlineLinkage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Series ==-->
<xsl:template name="CI_Series">
<xsl:param name="subject" />
<xsl:for-each select="sername">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="issue">
<r:assert relation="em:issueIdentification">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== MD_GridSpatialRepresentation ==-->
<xsl:template name="MD_GridSpatialRepresentation">
<xsl:param name="subject" />
<xsl:for-each select="rasttype">
<r:assert relation="em:rasterObjectType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rowcount">
<r:assert relation="em:rowCount">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="colcount">
<r:assert relation="em:colCount">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="vrtcount">
<r:assert relation="em:vrtCount">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
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
<xsl:apply-templates />
</xsl:template>
<!--== MD_VectorSpatialRepresentation ==-->
<xsl:template name="MD_VectorSpatialRepresentation">
<xsl:param name="subject" />
<xsl:for-each select="vpfterm/vpflevel">
<r:assert relation="em:ftopologyLevel">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="esriterm">
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
<xsl:for-each select="sdtsterm[not(esriterm)]">
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
<xsl:for-each select="vpfterm/vpfinfo[not(../../esriterm) and not(../../sdtsterm)]">
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
<xsl:for-each select="em:objectName">
<r:assert relation="@Name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="sdtstype | efeageom | vpftype">
<r:assert relation="em:fgeometricObjectType">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-code" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="efeacnt | ptvctcnt">
<r:assert relation="em:geometricObjectCount">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_ResponsibleParty_NameAndPlace ==-->
<xsl:template name="CI_ResponsibleParty_NameAndPlace">
<xsl:param name="subject" />
<xsl:for-each select="publish">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="pubplace">
<r:assert relation="em:place">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_ResponsibleParty ==-->
<xsl:template name="CI_ResponsibleParty">
<xsl:param name="subject" />
<xsl:for-each select="cntperp/cntper | cntorgp/cntper">
<r:assert relation="em:individualName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntperp/cntorg | cntorgp/cntorg">
<r:assert relation="em:organisationName">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntpos">
<r:assert relation="em:position">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntaddr">
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
<xsl:for-each select="cntvoice">
<r:assert relation="em:voiceNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cnttdd">
<r:assert relation="em:tddtty">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntfax">
<r:assert relation="em:faxNum">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="hours">
<r:assert relation="em:hours">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntinst">
<r:assert relation="em:instructions">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="cntemail">
<r:assert relation="em:electronicMailAddress">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CI_Address ==-->
<xsl:template name="CI_Address">
<xsl:param name="subject" />
<xsl:for-each select="address">
<r:assert relation="em:deliveryPoint">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="addrtype">
<r:assert relation="em:faddressType">
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
<xsl:for-each select="state">
<r:assert relation="em:administrativeArea">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="postal">
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
<xsl:apply-templates />
</xsl:template>
<!--== CI_OnlineResource ==-->
<xsl:template name="CI_OnlineResource">
<xsl:param name="subject" />
<xsl:for-each select="onlink[(. != 'withheld')] | computer/networka/networkr[(. != 'withheld')]">
<r:assert relation="em:linkage">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== Fields ==-->
<xsl:template name="Fields">
<xsl:param name="subject" />
<xsl:for-each select="detailed">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:fieldDetails">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="FieldDetails">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="overview">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:fieldsOverview">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="FieldsOverview">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== FieldDetails ==-->
<xsl:template name="FieldDetails">
<xsl:param name="subject" />
<xsl:for-each select="@Name">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enttyp">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:objectDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="ObjectDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="attr">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:fieldDescription">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="FieldDescription">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== ObjectDescription ==-->
<xsl:template name="ObjectDescription">
<xsl:param name="subject" />
<xsl:for-each select="enttypl">
<r:assert relation="em:label">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enttypt">
<r:assert relation="em:type">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enttypc">
<r:assert relation="em:count">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enttypd">
<r:assert relation="em:description">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enttypds">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== FieldDescription ==-->
<xsl:template name="FieldDescription">
<xsl:param name="subject" />
<xsl:for-each select="attrlabl">
<r:assert relation="em:label">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrdef">
<r:assert relation="em:definition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrdefs">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrdomv/edom">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:enumeratedDomain">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="EnumeratedDomain">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="attrdomv/rdom">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:rangeDomain">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="RangeDomain">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="attrdomv/codesetd">
<xsl:variable name="objectNode">
<xsl:call-template name="sys-objprop-obj" />
</xsl:variable>
<xsl:if test="$objectNode != '__NONE__'">
<r:assert relation="em:codesetDomain">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:copy-of select="$objectNode" />
</r:assert>
<xsl:call-template name="CodesetDomain">
<xsl:with-param name="subject" select="$objectNode" />
</xsl:call-template>
</xsl:if>
</xsl:for-each>
<xsl:for-each select="attrdomv/udom">
<r:assert relation="em:unrepresentableDomain">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="begdatea">
<r:assert relation="em:beginningDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="enddatea">
<r:assert relation="em:endingDate">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-date" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrvai/attrva">
<r:assert relation="em:valueAccuracy">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrvai/attrvae">
<r:assert relation="em:accuracyExplanation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrmfrq">
<r:assert relation="em:measurementFrequency">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== EnumeratedDomain ==-->
<xsl:template name="EnumeratedDomain">
<xsl:param name="subject" />
<xsl:for-each select="edomv">
<r:assert relation="em:value">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="edomvd">
<r:assert relation="em:definition">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="edomvds">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== RangeDomain ==-->
<xsl:template name="RangeDomain">
<xsl:param name="subject" />
<xsl:for-each select="rdommin">
<r:assert relation="em:minimumValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rdommax">
<r:assert relation="em:maximumValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rdommean">
<r:assert relation="em:meanValue">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="rdomstdv">
<r:assert relation="em:standardDeviation">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrunit">
<r:assert relation="em:units">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="attrmres">
<r:assert relation="em:measurementResolution">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-number" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== CodesetDomain ==-->
<xsl:template name="CodesetDomain">
<xsl:param name="subject" />
<xsl:for-each select="codesetn">
<r:assert relation="em:name">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="codesets">
<r:assert relation="em:source">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:apply-templates />
</xsl:template>
<!--== FieldsOverview ==-->
<xsl:template name="FieldsOverview">
<xsl:param name="subject" />
<xsl:for-each select="eaover">
<r:assert relation="em:overview">
<xsl:choose><xsl:when test="starts-with($subject, '#')"><r:uri><xsl:value-of select="$subject" /></r:uri></xsl:when><xsl:otherwise><r:qname><xsl:value-of select="$subject" /></r:qname></xsl:otherwise></xsl:choose>
<xsl:call-template name="sys-literal" />
</r:assert>
</xsl:for-each>
<xsl:for-each select="eadetcit">
<r:assert relation="em:description">
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

