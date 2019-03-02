<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:oape="https://openarabicpe.github.io/ns"
    xpath-default-namespace="http://www.loc.gov/mods/v3" version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" version="1.0"/>
<!--    <xsl:strip-space elements="*"/>-->
    <xsl:preserve-space elements="tei:head tei:bibl"/>


    <!-- this stylesheet generates a MODS XML file with bibliographic metadata for each <div> in the body of the TEI source file. File names are based on the source's @xml:id and the @xml:id of the <div>. -->
    <!-- to do:
        + add information on edition: i.e. TEI edition
        + add information on collaborators on the digital edition -->
<!--    <xsl:include href="https://cdn.rawgit.com/tillgrallert/xslt-calendar-conversion/master/date-function.xsl"/>-->
    <xsl:include href="https://tillgrallert.github.io/xslt-calendar-conversion/functions/date-functions.xsl"/>


    
    <xsl:param name="p_switch-vol-issue" select="true()"/>
    
    <xsl:variable name="v_today" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>

    <xsl:variable name="vgFileId" select="tei:TEI/@xml:id"/>
    <xsl:variable name="vgFileUrl"
        select="concat('https://rawgit.com/tillgrallert/digital-muqtabas/master/xml/', tokenize(base-uri(), '/')[last()])"/>
    <xsl:variable name="vgSchemaLocation" select="'http://www.loc.gov/standards/mods/v3/mods-3-6.xsd'"/>


  

    <!-- the Sente output -->
    <xsl:template match="tei:bibl | tei:biblStruct" name="t_bibl-to-reference" mode="m_tei2sente">
        <xsl:param name="p_input" select="."/>
        <!-- other params can derive from p_input -->
        <xsl:param name="p_author" select="$p_input/descendant::tei:author"/>
        <xsl:param name="p_editor" select="$p_input/descendant::tei:editor"/>
        <xsl:param name="p_date-publication" select="$p_input/descendant::tei:imprint/tei:date[1]"/>
        <xsl:param name="p_biblScope" select="$p_input/descendant::tei:monogr/tei:biblScope"/>
        <xsl:param name="p_url" select="$p_input/descendant::tei:ref[@type='url'][1]/@target"/>
        <!-- takes CSV as input -->
        <xsl:param name="p_url-attachments">
            <xsl:for-each select="$p_input/descendant::tei:ref[@type='url']/@target">
                <xsl:value-of select="."/>
                <xsl:if test="following::tei:ref[@type='url']/@target">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:param>
        <tss:reference>
            <tss:publicationType>
                <!-- this depends on the input -->
                <xsl:attribute name="name">
                    <xsl:choose>
                        <xsl:when test="descendant::tei:title[@level='a'] and descendant::tei:title[@level='j']">
                            <xsl:text>Not yet implemented</xsl:text>
                        </xsl:when>
                        <!-- a periodical -->
                        <xsl:when test="descendant::tei:title[@level='j']">
                            <xsl:text>Archival Periodical</xsl:text>
                        </xsl:when>
                        <!-- book chapter -->
                        <xsl:when test="descendant::tei:title[@level='a'] and descendant::tei:title[@level='m']">
                            <xsl:text>Not yet implemented</xsl:text>
                        </xsl:when>
                        <!-- a book -->
                        <xsl:when test="descendant::tei:title[@level='m']">
                            <xsl:text>Book</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </tss:publicationType>
            <tss:authors>
                <xsl:apply-templates select="$p_author" mode="m_tei2sente"/>
                <xsl:apply-templates select="$p_editor" mode="m_tei2sente"/>
            </tss:authors>
            <tss:dates>
                <!-- publication date -->
                <xsl:apply-templates select="$p_date-publication" mode="m_tei2sente"/>
                <!-- date of retrieval (i.e. date of transformation) -->
                <tss:date type="Retrieval" day="{ day-from-date(current-date())}" month="{ month-from-date(current-date())}" year="{ year-from-date(current-date())}"/>
            </tss:dates>
            <tss:characteristics>
                <!-- titles -->
                <xsl:apply-templates select="descendant::tei:title[@xml:lang=$p_lang-target][not(@type='sub')]" mode="m_tei2sente"/>
                <!-- imprint -->
                <xsl:apply-templates select="descendant::tei:imprint/tei:publisher/node()[@xml:lang=$p_lang-target]" mode="m_tei2sente"/>
                <xsl:apply-templates select="descendant::tei:imprint/tei:pubPlace/node()[@xml:lang=$p_lang-target]" mode="m_tei2sente"/>
                <!-- biblScope -->
                <xsl:apply-templates select="$p_biblScope" mode="m_tei2sente"/>
                <!-- non-Gregoian calendars -->
                <!--  toggle Islamic date-->
                <xsl:if test="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_islamic'][@when-custom]">
                    <xsl:variable name="v_date" select="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_islamic'][@when-custom][1]/@when-custom"/>
                    <tss:characteristic name="Date Hijri">
                        <xsl:value-of select="oape:date-format-iso-string-to-tei($v_date, '#cal_islamic', true(), false(),'ar-Latn-x-ijmes')"/>
                    </tss:characteristic>
                </xsl:if>
                <!-- toggle Julian (*rūmī*) date -->
                <xsl:if test="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_julian'][@when-custom]">
                    <xsl:variable name="v_date" select="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_julian'][@when-custom][1]/@when-custom"/>
                    <tss:characteristic name="Date Rumi">
                        <xsl:value-of select="oape:date-format-iso-string-to-tei($v_date, '#cal_julian', true(), false(),'ar-Latn-x-ijmes')"/>
                    </tss:characteristic>
                </xsl:if>
                <!-- toggle Ottoman fiscal (*mālī*) date -->
                <xsl:if test="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_ottomanfiscal'][@when-custom]">
                    <xsl:variable name="v_date" select="$p_input/descendant::tei:imprint/tei:date[@datingMethod='#cal_ottomanfiscal'][@when-custom][1]/@when-custom"/>
                    <tss:characteristic name="Date Rumi">
                        <xsl:value-of select="oape:date-format-iso-string-to-tei($v_date, '#cal_ottomanfiscal', true(), false(),'ar-Latn-x-ijmes')"/>
                    </tss:characteristic>
                </xsl:if>
                <!-- citation identifier -->
                <tss:characteristic name="Citation identifier">
                    <xsl:variable name="v_volume" select="$p_biblScope/descendant-or-self::tei:biblScope[@unit='volume']/@from"/>
                    <xsl:variable name="v_issue" select="$p_biblScope/descendant-or-self::tei:biblScope[@unit='issue']/@from"/>
                    <xsl:choose>
                        <xsl:when test="$p_base-cit-id!=''">
                            <xsl:value-of select="concat($p_base-cit-id,'-',$v_volume,'-',$v_issue)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(lower-case(replace(descendant::tei:title[@xml:lang=$p_lang-target][not(@type='sub')],'\W','-')),'-',$v_volume,'-',$v_issue)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </tss:characteristic>
                <!-- URL -->
                <tss:characteristic name="URL">
                    <xsl:value-of select="$p_url"/>
                </tss:characteristic>
            </tss:characteristics>
            <!-- potential attachments -->
            <tss:attachments>
                <xsl:for-each select="tokenize($p_url-attachments,',')">
                    <tss:attachmentReference>
                        <URL><xsl:value-of select="."/></URL>
                    </tss:attachmentReference>
                </xsl:for-each>
            </tss:attachments>
        </tss:reference>
    </xsl:template>
    
    <!-- plain text output: beware that heavily marked up nodes will have most whitespace omitted -->
    <xsl:template match="text()" mode="m_plain-text">
        <xsl:value-of select="normalize-space(replace(.,'(\w)[\s|\n]+','$1 '))"/>
<!--        <xsl:text> </xsl:text>-->
<!--        <xsl:value-of select="normalize-space(.)"/>-->
        <!--<xsl:text> </xsl:text>-->
    </xsl:template>
    <xsl:template match="tei:lb | tei:cb | tei:pb" mode="m_plain-text">
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- add whitespace around descendants of tei:head -->
    <!-- prevent notes in div/head from producing output -->
    <xsl:template match="tei:head/tei:note" mode="m_plain-text" priority="100"/>
    
    <!-- dates -->
    <xsl:template match="tei:date[@when]" mode="m_tei2sente">
        <tss:date type="Publication" day="{ day-from-date(@when)}" month="{ month-from-date(@when)}" year="{ year-from-date(@when)}"/>
    </xsl:template>
    
    <!-- titles -->
    <xsl:template match="tei:title" mode="m_tei2sente">
        <xsl:variable name="v_level" select="@level"/>
        <xsl:choose>
            <xsl:when test="@level='a'">
                <tss:characteristic name="articleTitle">
                    <xsl:apply-templates select="." mode="m_plain-text"/>
                    <xsl:if test="following-sibling::tei:title[@level=$v_level][@xml:lang=$p_lang-target]">
                        <xsl:text>: </xsl:text>
                        <xsl:apply-templates select="following-sibling::tei:title[@level=$v_level][@xml:lang=$p_lang-target][1]" mode="m_plain-text"/>
                    </xsl:if>
                </tss:characteristic>
            </xsl:when>
            <xsl:otherwise>
                <tss:characteristic name="publicationTitle">
                    <xsl:apply-templates select="." mode="m_plain-text"/>
                    <xsl:if test="$p_title-long=true()">
                        <xsl:if test="following-sibling::tei:title[@level=$v_level][@xml:lang=$p_lang-target]">
                            <xsl:text>: </xsl:text>
                            <xsl:apply-templates select="following-sibling::tei:title[@level=$v_level][@xml:lang=$p_lang-target][1]" mode="m_plain-text"/>
                        </xsl:if>
                    </xsl:if>
                </tss:characteristic>
                <tss:characteristic name="Short Titel">
                    <xsl:value-of select="tokenize(.,'\s')[1]"/>
                </tss:characteristic>
                <tss:characteristic name="Shortened title">
                    <xsl:value-of select="tokenize(.,'\s')[1]"/>
                </tss:characteristic>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- transform TEI names to Sente -->
    <xsl:template match="tei:author" mode="m_tei2sente">
        <xsl:element name="tss:author">
            <xsl:attribute name="role" select="'Author'"/>
            <xsl:apply-templates select="tei:persName[@xml:lang=$p_lang-target]/tei:surname" mode="m_tei2sente"/>
            <xsl:apply-templates select="tei:persName[@xml:lang=$p_lang-target]/tei:forename" mode="m_tei2sente"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:editor" mode="m_tei2sente">
        <xsl:element name="tss:author">
            <xsl:attribute name="role" select="'Editor'"/>
            <xsl:apply-templates select="tei:persName[@xml:lang=$p_lang-target]/tei:surname" mode="m_tei2sente"/>
            <xsl:apply-templates select="tei:persName[@xml:lang=$p_lang-target]/tei:forename" mode="m_tei2sente"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:surname" mode="m_tei2sente">
        <xsl:element name="tss:surname">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:forename" mode="m_tei2sente">
        <xsl:element name="tss:forenames">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
   
    
    
    <xsl:template match="tei:publisher/tei:orgName[@xml:lang=$p_lang-target] | tei:publisher/tei:persName[@xml:lang=$p_lang-target] " mode="m_tei2sente">
        <!-- tei:publisher can have a variety of child nodes, which are completely ignored by this template -->
            <tss:characteristic name="publisher">
                <xsl:apply-templates select="." mode="m_plain-text"/>
            </tss:characteristic>
    </xsl:template>
    
    <xsl:template match="tei:pubPlace/tei:placeName[@xml:lang=$p_lang-target]" mode="m_tei2sente">
        <tss:characteristic name="publicationCountry">
            <xsl:apply-templates select="." mode="m_plain-text"/>
        </tss:characteristic>
    </xsl:template>
    
    <!-- volume, issue, pages -->
    <xsl:template match="tei:biblScope[@unit='volume']" mode="m_tei2sente">
        <tss:characteristic>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="$p_switch-vol-issue=true()">
                            <xsl:text>issue</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>volume</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="@from"/>
            <xsl:if test="@to and not(@from=@to)">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="@to"/>
            </xsl:if>
        </tss:characteristic>
    </xsl:template>
    <xsl:template match="tei:biblScope[@unit='issue']" mode="m_tei2sente">
        <tss:characteristic>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="$p_switch-vol-issue=true()">
                        <xsl:text>volume</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>issue</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="@from"/>
            <xsl:if test="@to and not(@from=@to)">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="@to"/>
            </xsl:if>
        </tss:characteristic>
    </xsl:template>
    <xsl:template match="tei:biblScope[@unit='page']" mode="m_tei2sente">
        <tss:characteristic name="pages">
            <xsl:value-of select="@from"/>
            <xsl:if test="@to and not(@from=@to)">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="@to"/>
            </xsl:if>
        </tss:characteristic>
    </xsl:template>
   
    
    <xsl:template match="tei:persName | tei:orgName | tei:editor | tei:author" mode="m_authority">
            <xsl:if test="@ref!=''''">
                <xsl:choose>
                    <xsl:when test="matches(@ref, 'viaf:\d+')">
                        <xsl:attribute name="authority" select="'viaf'"/>
                        <!-- it is arguably better to directly dereference VIAF IDs -->
                        <xsl:attribute name="valueURI" select="replace(@ref,'(viaf):(\d+)','https://viaf.org/viaf/$2')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
    </xsl:template>
    
    <!-- IDs -->
    <xsl:template match="tei:idno" mode="m_tei2mods">
        <identifier type="{@type}">
            <xsl:apply-templates select="." mode="m_plain-text"/>
        </identifier>
    </xsl:template>
    
   


</xsl:stylesheet>
