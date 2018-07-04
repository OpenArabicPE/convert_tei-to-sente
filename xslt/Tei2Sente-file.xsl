<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://www.loc.gov/mods/v3" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" version="1.0"/>
<!--    <xsl:strip-space elements="*"/>-->
    <xsl:preserve-space elements="tei:head tei:bibl"/>

    <xsl:include href="Tei2Sente-functions.xsl"/>
    
    <!-- parameter to actively select the language of some fields (if available): 'ar-Latn-x-ijmes', 'ar', 'en' etc. -->
    <xsl:param name="p_lang-target" select="'ar-Latn-x-ijmes'"/>
    <xsl:param name="p_title-long" select="true()"/>
    <xsl:param name="p_base-cit-id" select="'thamarat-oib'"></xsl:param>

    <xsl:template match="/">
        <xsl:result-document href="../metadata/{$vgFileId}.TSS.xml">
            <tss:senteContainer version="1.0" xsi:schemaLocation="http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd">
                <tss:library>
                    <tss:references>
                        <xsl:call-template name="t_bibl-to-reference">
                            <xsl:with-param name="p_input" select="descendant::tei:teiHeader/descendant::tei:sourceDesc/tei:biblStruct"/>
                            <xsl:with-param name="p_url-attachments">
                                <xsl:value-of select="concat('../images/pdfs/',$vgFileId,'.pdf,')"/>
                                <xsl:for-each select="descendant::tei:facsimile/tei:surface/tei:graphic/@url">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="ancestor::tei:surface/following-sibling::tei:surface">
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:with-param>
                        </xsl:call-template>
                <!--<xsl:apply-templates select="descendant::tei:teiHeader/descendant::tei:sourceDesc/tei:biblStruct" mode="m_tei2sente"/>-->
                    </tss:references>
                </tss:library>
            </tss:senteContainer>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
