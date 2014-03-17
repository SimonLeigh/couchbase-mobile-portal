<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.couchbase.com/xsl/extension-functions"
                exclude-result-prefixes="fn">

<xsl:include href="util.xslt"/>

<xsl:template match="*" mode="search-index">
	<xsl:variable name="docs" select="descendant-or-self::*[self::article or self::lesson or self::page]"/>
	
	<xsl:text>var searchIndex = {&#10;</xsl:text>
	
	<!-- Groups -->
	<xsl:text>"groups":[&#10;</xsl:text>
	<xsl:variable name="groups">
		<xsl:for-each select="$docs">
			<xsl:value-of select="concat('[&quot;', string-join(ancestor-or-self::*[self::item or self::group]/@title, '&quot;,&quot;'), '&quot;]')"/>
			<xsl:if test="not(position() = last())">%%%</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="unique-groups" select="distinct-values(tokenize($groups, '%%%'))"/>
	<xsl:value-of select="string-join($unique-groups, ',')"/>
	<xsl:text>]&#10;</xsl:text>
	
	<!--  Docs -->
	<xsl:text>,"docs":[&#10;</xsl:text>
	<xsl:for-each select="$docs">
		<xsl:variable name="group" select="concat('[&quot;', string-join(ancestor-or-self::*[self::item or self::group]/@title, '&quot;,&quot;'), '&quot;]')"/>
		
		<xsl:text>[</xsl:text>
		<xsl:value-of select="concat('&quot;', fn:relative-result-path(/*[1], .), '&quot;')"/>
		<xsl:value-of select="concat(',&quot;', title, '&quot;')"/>
		<xsl:value-of select="concat(',', index-of($unique-groups, $group)-1)"/>
		<xsl:text>]</xsl:text>
		<xsl:if test="not(position() = last())">,&#10;</xsl:if>
	</xsl:for-each>
	<xsl:text>]&#10;</xsl:text>
	
	<!--  Terms -->
	<xsl:variable name="terms">
		<xsl:variable name="words">
			<xsl:value-of select="string-join($docs/title | $docs/descendant::*[self::task or self::topic]/title, ' ')"/>
		</xsl:variable>
		
		<xsl:variable name="words-cleaned">
			<xsl:value-of select="replace($words, '[^a-zA-Z0-9_\-'']', ' ')"/>
		</xsl:variable>
		
		<xsl:value-of select="lower-case(normalize-space($words-cleaned))"/>
	</xsl:variable>
	<xsl:variable name="unique-terms" select="distinct-values(tokenize($terms, ' '))"/>
	
	<!--  Index -->
	<xsl:text>,"index":{&#10;</xsl:text>
	<xsl:for-each select="$unique-terms">
		<xsl:variable name="word" select="."/>
		<xsl:value-of select="concat('&quot;', $word, '&quot;:[')"/>
		
		<xsl:variable name="matches">
			<xsl:for-each select="$docs">
				<xsl:variable name="doc-index" select="position()-1"/>
				<xsl:variable name="words" select="lower-case(string-join(title | $docs/descendant::*[self::task or self::topic]/title, ' '))"/>
				
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
	<xsl:variable name="docs" select="descendant-or-self::*[self::article or self::lesson or self::page]"/>
	
	<xsl:text>var searchIndexAdvanced = {&#10;</xsl:text>
	
	<!--  Docs -->
	<xsl:text>"docDescriptions":[&#10;</xsl:text>
	<xsl:for-each select="$docs">
		<xsl:value-of select="concat('&quot;', description, '&quot;')"/>
		<xsl:if test="not(position() = last())">,&#10;</xsl:if>
	</xsl:for-each>
	<xsl:text>]&#10;</xsl:text>
	
	<xsl:text>};</xsl:text>
</xsl:template>

</xsl:stylesheet>