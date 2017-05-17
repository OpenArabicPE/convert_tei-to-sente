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

    <xsl:template match="/">
        <xsl:result-document href="../metadata/{$vgFileId}-bibl.Sente.xml">
            <tss:senteContainer version="1.0" xsi:schemaLocation="http://www.thirdstreetsoftware.com/SenteXML-1.0 SenteXML.xsd">
                <tss:library>
                    <tss:references>
                <xsl:apply-templates select=".//tei:body//tei:bibl[descendant::tei:title] | .//tei:body//tei:biblStruct" mode="m_tei2sente"/>
                    </tss:references>
                </tss:library>
            </tss:senteContainer>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
