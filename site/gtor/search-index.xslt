<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.couchbase.com/xsl/extension-functions"
                exclude-result-prefixes="fn">

<xsl:include href="util.xslt"/>

<xsl:template match="*" mode="search-index">
    <xsl:variable name="docs" select="descendant-or-self::*[self::article or self::lesson or self::page or self::xhtml-page or self::class[../parent::package]]"/>
    
    <xsl:text>var searchIndex = {&#10;</xsl:text>
    
    <!-- Groups -->
    <xsl:text>"groups":[&#10;</xsl:text>
    <xsl:variable name="groups">
        <xsl:for-each select="$docs">
            <group>
                <xsl:value-of select="concat('[&quot;', string-join(ancestor-or-self::*[self::item or self::group]/@title, '&quot;,&quot;'), '&quot;]')"/>
            </group>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="unique-groups" select="distinct-values($groups/group)"/>
    <xsl:value-of select="string-join($unique-groups, ',')"/>
    <xsl:text>]&#10;</xsl:text>

    <!-- Docs -->
    <xsl:text>,"docs":[&#10;</xsl:text>
    <xsl:for-each select="$docs">
        <xsl:variable name="group" select="concat('[&quot;', string-join(ancestor-or-self::*[self::item or self::group]/@title, '&quot;,&quot;'), '&quot;]')"/>
        
        <xsl:text>[</xsl:text>
        <xsl:value-of select="concat('&quot;', fn:relative-result-path(/*[1], .), '&quot;')"/>
        <xsl:variable name="name" select="replace(fn:iif(self::class, @name, title), '&quot;', '\\&quot;')"/>
        <xsl:value-of select="concat(',&quot;', $name, '&quot;')"/>
        <xsl:value-of select="concat(',', index-of($unique-groups, $group)-1)"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="not(position() = last())">,&#10;</xsl:if>
    </xsl:for-each>
    <xsl:text>]&#10;</xsl:text>
    
    <!-- Terms -->
    <xsl:variable name="terms">
        <xsl:variable name="words">
            <xsl:value-of select="string-join($docs/descendant-or-self::title | $docs/descendant-or-self::*/@name, ' ')"/>
        </xsl:variable>
        
        <xsl:variable name="words-cleaned">
            <xsl:value-of select="replace($words, '[^a-zA-Z0-9_\-'']', ' ')"/>
        </xsl:variable>
        
        <xsl:value-of select="lower-case(normalize-space($words-cleaned))"/>
    </xsl:variable>
    <xsl:variable name="unique-terms" select="distinct-values(tokenize($terms, ' '))"/>
    
    <!-- Index -->
    <xsl:text>,"index":{&#10;</xsl:text>
    <xsl:for-each select="$unique-terms">
        <xsl:variable name="word" select="."/>
        <xsl:value-of select="concat('&quot;', $word, '&quot;:[')"/>
        
        <xsl:variable name="matches">
            <xsl:for-each select="$docs">
                <xsl:variable name="doc-index" select="position()-1"/>
                <xsl:variable name="words" select="lower-case(string-join(descendant-or-self::*/title | descendant-or-self::*/@name, ' '))"/>
                
                <xsl:if test="contains($words, $word)">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="$doc-index"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="count(tokenize($words, $word))"/>
                    <xsl:text>] </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join(distinct-values(tokenize(normalize-space($matches), ' ')), ',')"/>
        
        <xsl:text>]</xsl:text>
        <xsl:if test="not(position() = last())">,&#10;</xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
    
    <xsl:text>};</xsl:text>
</xsl:template>
    
<xsl:template match="*" mode="search-index-advanced">
    <xsl:variable name="docs" select="descendant-or-self::*[self::article or self::lesson or self::page or self::xhtml-page or self::class[../parent::package]]"/>
    
    <xsl:text>var searchIndexAdvanced = {&#10;</xsl:text>
    
    <!-- Doc Descriptions -->
    <xsl:text>"docDescriptions":[&#10;</xsl:text>
    <xsl:for-each select="$docs">
        <!-- Description w/ %Entity% values dereferenced. -->
        <xsl:variable name="description" select="replace(fn:iif(description, description, @description), '&quot;', '\\&quot;')"/>
        <xsl:value-of select="concat('&quot;', normalize-space(replace($description, '%([^%]*)%', '$1')), '&quot;')"/>
        <xsl:if test="not(position() = last())">,&#10;</xsl:if>
    </xsl:for-each>
    <xsl:text>]&#10;</xsl:text>
    
    <xsl:text>};</xsl:text>
</xsl:template>

</xsl:stylesheet>