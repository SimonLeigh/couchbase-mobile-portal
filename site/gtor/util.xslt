<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.couchbase.com/xsl/extension-functions"
                xmlns:file="java:java.io.File"
                xmlns:runtime="java.lang.Runtime"
                exclude-result-prefixes="fn file runtime">

<xsl:param name="output-directory">gen/</xsl:param>

<!-- Creates a directory path using the output directory as root and using each set as a child directory. -->
<xsl:function name="fn:result-directory">
	<xsl:param name="node"/>
	
	<xsl:variable name="result-directory">
		<xsl:value-of select="$output-directory"/>
		
		<xsl:for-each select="$node/ancestor-or-self::*[self::group or self::item or self::set or self::guide or self::article or self::class or self::lesson or self::page]">
			<xsl:value-of select="concat(@id, '/')"/>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:value-of select="$result-directory"/>
</xsl:function>

<!-- Creates a file path using the result directory. -->
<xsl:function name="fn:result-path">
    <xsl:param name="node"/>
    
	<xsl:variable name="result-path">
		<xsl:value-of select="fn:result-directory($node)"/>
	    <xsl:text>index.html</xsl:text>
	</xsl:variable>
	
	<xsl:value-of select="$result-path"/>
</xsl:function>
	
<!-- Creates a file path using the output directory as root and using each set as a child directory. -->
<xsl:function name="fn:relative-result-path">
	<xsl:param name="fromNode"/>
	<xsl:param name="toNode"/>
	
	<xsl:variable name="path">
		<!-- Back up the tree from the source node to root. -->
		<xsl:for-each select="$fromNode/ancestor-or-self::*[self::group or self::item or self::set or self::guide or self::article or self::class or self::lesson or self::page]">
			<xsl:value-of select="'../'"/>
		</xsl:for-each>
		
		<!-- Drill down the tree to the target node. -->
		<xsl:for-each select="$toNode/ancestor-or-self::*[self::group or self::item or self::set or self::guide or self::article or self::class or self::lesson or self::page]">
			<xsl:value-of select="concat(@id, '/')"/>
		</xsl:for-each>
		
		<xsl:text>index.html</xsl:text>
	</xsl:variable>
	
	<xsl:value-of select="$path"/>
</xsl:function>

<!-- Creates a relative file path starting w/ result-path(node) and backing down to root. -->
<xsl:function name="fn:root-path">
    <xsl:param name="node"/>
    <xsl:param name="file-name"/>
    
    <xsl:variable name="path">
    	<xsl:for-each select="$node/ancestor-or-self::*[self::group or self::item or self::set or self::guide or self::article or self::class or self::lesson or self::page]">
    		<xsl:value-of select="'../'"/>
    	</xsl:for-each>
    	
    	<xsl:value-of select="$file-name"/>
    </xsl:variable>
	
	<xsl:value-of select="$path"/>
</xsl:function>
	
<xsl:function name="fn:base-direcotry">
	<xsl:param name="current"/>
	
	<!-- HACK: For some reason base-uri doesn't back up the relative file path for
	 includes.  So for now we will just remove the 'site' node since we know
	 how the dirs are structured. -->
	<xsl:value-of select="replace(file:getParent(file:new(base-uri($current))), '/site', '')"/>
</xsl:function>

<xsl:function name="fn:copy-file">
	<xsl:param name="source"/>
	<xsl:param name="destination"/>
	
	<xsl:value-of select="fn:void(file:mkdirs(file:getParentFile(file:new(string($destination)))))"/>
	<xsl:value-of select="fn:void(runtime:exec(runtime:getRuntime(), concat('cp ', $source, ' ', $destination)))"/>
</xsl:function>
	
<xsl:function name="fn:copy-directory">
	<xsl:param name="source"/>
	<xsl:param name="destination"/>
	
	<xsl:value-of select="fn:void(file:mkdirs(file:getParentFile(file:new(string($destination)))))"/>
	<xsl:value-of select="fn:void(runtime:exec(runtime:getRuntime(), concat('cp -r ', $source, ' ', $destination)))"/>
</xsl:function>

<!-- If expr == true then returns the supplied 'true' othewise returns the supplied 'false'. -->
<xsl:function name="fn:iif">
    <xsl:param name="expr"/>
    <xsl:param name="true"/>
    <xsl:param name="false"/>
    
    <xsl:choose>
        <xsl:when test="$expr">
            <xsl:value-of select="$true"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$false"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:function>
	
<xsl:function name="fn:void">
	<xsl:param name="expr"/>
	
	<!-- Evaluate so that the expression will get executed but don't return anything. -->
	<xsl:if test="$expr">
		<xsl:text/>
	</xsl:if>
</xsl:function>
	
<xsl:function name="fn:trim">
	<xsl:param name="string"/>
	
	<xsl:value-of select="replace($string, '^(\s\n\r)*(.+?)(\s\n\r)*$', '$1')"/>
</xsl:function>
	
<xsl:function name="fn:equals">
	<xsl:param name="node1"/>
	<xsl:param name="node2"/>
	
	<xsl:copy-of select="generate-id($node1) = generate-id($node2)"/>
</xsl:function>

</xsl:stylesheet>