<?xml version="1.0"?>
<!DOCTYPE xml [
  <!ENTITY left-chevron "〈">
  <!ENTITY right-chevron "〉">
]>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:uri="java:java.net.URI"
    xmlns:url="java:java.net.URL"
    xmlns:file="java:java.io.File"
    xmlns:fn="http://www.couchbase.com/xsl/extension-functions"
    xmlns:xfn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="uri url file fn">
<xsl:output method="xhtml" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="util.xslt"/>

<xsl:param name="languages" select="//programming-languages/programming-language"/>

<xsl:template match="/">
    <xsl:apply-templates select="site"/>
</xsl:template>

<!-- ==== -->
<!-- Site -->
<!-- ==== -->
  
<xsl:template match="site">
  <xsl:for-each select="site-map/top">
    <xsl:apply-templates select="*"/>
  </xsl:for-each>
  
  <!--<xsl:for-each select="site-map/landing-pages">-->
  <!--<xsl:apply-templates select="*"/>-->
  <!--</xsl:for-each>-->
  
  <!--<xsl:for-each select="site-map/(item | group/item)">-->
  <!--<xsl:apply-templates select="set | guide | class | article | lesson | page | xhtml-page | api | hippo-root"/>-->
  <!--</xsl:for-each>-->
  
  <xsl:apply-templates select="(site-map | site-map/landing-pages)/(set | guide | class | article | lesson | page | xhtml-page | api)"/>
  
  <!-- Copy Resources -->
  <xsl:variable name="source-base-directory" select="string(file:getParent(file:new(base-uri())))"/>
  <xsl:variable name="destination-base-directory" select="string(fn:result-directory(.))"/>
  <xsl:for-each select="tokenize('styles scripts images', ' ')">
    <xsl:value-of select="fn:copy-directory(file:getAbsolutePath(file:new($source-base-directory, string(.))), file:getAbsolutePath(file:new($destination-base-directory)))"/>
  </xsl:for-each>

</xsl:template>
  
<!-- ==================== -->
<!-- Common Page Template -->
<!-- ==================== -->

<xsl:template match="*" mode="wrap-page">
    <xsl:param name="content"/>
    
    <xsl:variable name="site" select="ancestor-or-self::site"/>
    
    <xsl:variable name="site-version">1.3</xsl:variable>
    <xsl:variable name="site-title" select="$site/title"/>
    <xsl:variable name="site-subtitle" select="$site/subtitle"/>
    <xsl:variable name="title" select="fn:iif(title, title, fn:iif(name, name, fn:iif(@name, @name, '')))"/>

    <html>
        <head>
            <title>
                <xsl:value-of select="$title"/>
            </title>
            

            <meta>
                <xsl:attribute name="name">description</xsl:attribute>
                <xsl:attribute name="content" select="description"/>
            </meta>
            <meta>
                <xsl:attribute name="name">keywords</xsl:attribute>
                <xsl:attribute name="content" select="keywords"/>
            </meta>
            <meta>
                <xsl:attribute name="name">product</xsl:attribute>
                <xsl:attribute name="content">mobile</xsl:attribute>
            </meta>
            <meta>
                <xsl:attribute name="name">version</xsl:attribute>
                <xsl:attribute name="content" select="$site-version"/>
            </meta>

<!--             <link rel="stylesheet" type="text/css" href="{fn:root-path(., 'styles/style.css')}"/> -->
            
            <!-- Include language stripes as inline styles. -->
            <xsl:for-each select="$languages/@name">
                <xsl:variable name="stripe" select="."/>
                <xsl:variable name="escaped-stripe" select="fn:escape-css-name($stripe)"/>
                
                <style class="language-stripe" id="language-stripe-{$escaped-stripe}" type="text/css">
                    <xsl:for-each select="$languages/@name">
                        <xsl:variable name="language" select="."/>
                        <xsl:variable name="escaped-language" select="fn:escape-css-name($language)"/>
                        
                        <xsl:value-of select="concat('*.stripe-display.', $escaped-language, '{display:')"/>
                        <xsl:value-of select="concat(fn:iif($language=$stripe, 'inline', 'none'),';}')"/>
                        
                        <xsl:value-of select="concat('*.stripe-active.', $escaped-language, '{background:')"/>
                        <xsl:value-of select="concat(fn:iif($language=$stripe, 'rgba(0, 0, 0, 0.05)', 'transparent'),';}')"/>
                    </xsl:for-each>
                </style>
            </xsl:for-each>

            <!-- NOTE: If we have a language set then write out a default style element that enables the selected
                 stripe, and disables the other stripes, during the initial parse.  This keeps the code sets from
                 flashing during load. -->
            <script type="text/javascript">
                <xsl:text>var languages = [</xsl:text>
                <xsl:for-each select="$languages/@name">
                    <xsl:value-of select="concat(fn:iif(position() > 1, ',', ''), '&quot;', fn:escape-css-name(.), '&quot;')"/>
                </xsl:for-each>
                <xsl:text>];</xsl:text>
                
                <xsl:text disable-output-escaping="yes">
                    <![CDATA[
	                var cookies = document.cookie.split(';');
				    for(var i=0; i<cookies.length; i++) {
				        var cookie = cookies[i].trim();
				        
				        if (cookie.indexOf("language=")==0) {
				            var selectedLanguage = cookie.substring(9, cookie.length);
				            if (selectedLanguage.length > 0) {
				                document.write("<style class='language-stripe' type='text/css'>");
				                for (var j=0; j<languages.length; j++) {
				                    var language = languages[j];
				                    document.write("*.stripe-display." + language + "{display:" + (language == selectedLanguage ? "inline" : "none") + ";}");
                                    document.write("*.stripe-active." + language + "{background:" + (language == selectedLanguage ? "rgba(0, 0, 0, 0.05)" : "transparent") + ";}");
				                }
				                document.write("</style>");
				            }
				            break;
				        }
				    }
				    ]]>
			    </xsl:text>
            </script>
            
            <xsl:apply-templates select="/site/head/* | descendant-or-self::head/*"/>
        </head>
        <body>
            <xsl:apply-templates select="$site/site-map">
                <xsl:with-param name="active" select="."/>
            </xsl:apply-templates>
            
            <h1>
                <xsl:value-of select="$title"/>
            </h1>
            <div>
                <!-- XHTML pages are responsible for the entire content canvas so we
                     don't space page. -->
                <xsl:if test="not(ancestor-or-self::xhtml-page)">
                    <xsl:attribute name="class">page-wrapper</xsl:attribute>
                </xsl:if>
                
                <xsl:apply-templates select="." mode="navigator">
                    <xsl:with-param name="current" select="."/>
                </xsl:apply-templates>
                
                <xsl:if test="$content">
                    <article>
                        <!-- XHTML pages are responsible for the entire content canvas so we
                             don't space content. -->
                        <xsl:if test="not(ancestor-or-self::xhtml-page)">
                          <xsl:attribute name="class">
                              <xsl:text>body</xsl:text>
                              
                              <xsl:variable name="navigator-items" select="ancestor-or-self::*[self::item[parent::group or parent::site-map]]/descendant::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package]"/>
                              <xsl:if test="count($navigator-items) &lt; 2"> wide</xsl:if>
                          </xsl:attribute>
                        </xsl:if>
                        
                        <xsl:copy-of select="$content"/>
                    </article>
                </xsl:if>
            </div>
                
            <xsl:apply-templates select="ancestor-or-self::site" mode="footer"/>
        </body>
    </html>
</xsl:template>

<xsl:template match="site" mode="footer">
    <div class="page-footer">
        <span>
            <xsl:value-of select="copyright"/>
        </span>
        <xsl:apply-templates select="terms-of-use/*"/>
        <xsl:apply-templates select="privacy-policy/*"/>
    </div>
</xsl:template>
    
<xsl:template match="script">
    <xsl:if test="@src">
        <!-- Copy the linked file from the source, to the destination. -->
        <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@src))"/>
        <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@src))"/>
        <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
    </xsl:if>
    
    <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*"/>
        <xsl:value-of select="." disable-output-escaping="yes"/>
    </xsl:copy>
</xsl:template>

<!-- ========= -->
<!-- Navigator -->
<!-- ========= -->
    
<xsl:template match="site-map">
    <xsl:param name="active"/>
    <xsl:param name="excludeSearch" select="false()"/>
    
    <div class="page-header">
    </div>
</xsl:template>

<xsl:template match="group[parent::site-map] | item[parent::site-map or parent::group[parent::site-map]]">
    <xsl:param name="active"/>
    
    <td>
        <a class="dark">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@href">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="fn:relative-result-path($active, descendant-or-self::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package][1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <xsl:attribute name="class">
                <xsl:text>dark</xsl:text>
                <xsl:if test="descendant-or-self::*[fn:equals(self::*, $active)]"> active</xsl:if>
            </xsl:attribute>
            
            <xsl:value-of select="@title"/>
        </a>
    </td>
</xsl:template>

<xsl:template match="set | guide | class | article | lesson | page | xhtml-page | api | package | hippo-root" mode="navigator">
    <xsl:variable name="active" select="."/>
        <nav>
            <ul class="developer-portal-sidebar-navigation">    
            <xsl:variable name="set" select="/site/site-map/*"/>
            <xsl:for-each select="$set">
                <xsl:if test="xfn:not(xfn:deep-equal(xfn:name(.), xfn:string('top')))">
                    <xsl:variable name="title" select="./@title"/>
                    <xsl:apply-templates select="." mode="navigator-item">
                        <xsl:with-param name="active" select="$active"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:for-each>
            </ul>
        </nav>
</xsl:template>

<xsl:template match="set | guide | class[not(parent::classes/parent::package)] | api | package | item" mode="navigator-item">
    <xsl:param name="active"/>

    <li>
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="fn:equals(self::*, $active)">nav-item current</xsl:when>
                <xsl:otherwise>nav-item</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <xsl:if test="./@title">
            <xsl:variable name="node" select="self::item/*[1]"/>
            <xsl:choose>
                <xsl:when test="xfn:empty($node)">
                    <a href="{fn:relative-result-path($active, self::*/*[1]/*[1])}">
                        <xsl:value-of select="./@title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{fn:relative-result-path($active, $node)}">
                        <xsl:value-of select="./@title"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
        <a href="{fn:relative-result-path($active, .)}">
            <xsl:value-of select="(title | name | @name)[1]"/>
        </a>
        
        <xsl:for-each select="descendant::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package][1]">
            <ul>
                <xsl:apply-templates select="." mode="navigator-item">
                    <xsl:with-param name="active" select="$active"/>
                </xsl:apply-templates>
                
                <xsl:for-each select="following-sibling::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package]">
                    <xsl:apply-templates select="." mode="navigator-item">
                        <xsl:with-param name="active" select="$active"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </ul>
        </xsl:for-each>
    </li>
</xsl:template>

<xsl:template match="group" mode="navigator-item">
    <xsl:param name="active"/>

    <li>
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="fn:equals(self::*, $active)">nav-item current</xsl:when>
                <xsl:otherwise>nav-item</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

        <xsl:if test="./@title">
            <xsl:variable name="node" select="self::item/*[1]"/>
            <xsl:choose>
                <xsl:when test="xfn:empty($node)">
                    <a href="{fn:relative-result-path($active, self::*/*[1]/*[1])}">
                        <xsl:value-of select="./@title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{fn:relative-result-path($active, $node)}">
                        <xsl:value-of select="./@title"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <xsl:for-each select="child::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package or self::item]">
            <ul>
                <xsl:apply-templates select="." mode="navigator-item">
                    <xsl:with-param name="active" select="$active"/>
                </xsl:apply-templates>
                
                <xsl:for-each select="following-sibling::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package]">
                    <xsl:apply-templates select="." mode="navigator-item">
                        <xsl:with-param name="active" select="$active"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </ul>
        </xsl:for-each>
    </li>
</xsl:template>

<xsl:template match="article | lesson | page | xhtml-page | hippo-root | class[parent::classes/parent::package]" mode="navigator-item">
    <xsl:param name="active"/>

    <li>
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="fn:equals(self::*, $active)">nav-item current</xsl:when>
                <xsl:otherwise>nav-item</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        
        <a href="{fn:relative-result-path($active, .)}">
            <xsl:value-of select="(title | name | @name)[1]"/>
        </a>
    </li>
</xsl:template>

<!-- ==== -->
<!-- Sets -->
<!-- ==== -->

<xsl:template match="set">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="items/(set | guide | class | article | lesson | page | xhtml-page | api | hippo-root)"/>
        
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                <h1>
                    <xsl:value-of select="title"/>
                </h1> -->
                
                <xsl:apply-templates select="introduction/*"/>
                
                <ul class="set-item-list">
                    <xsl:variable name="set" select="."/>
                    
                    <xsl:for-each select="items/*">
                        <li>
                            <a class="title" href="{fn:relative-result-path($set, .)}">
                                <h2>
                                    <xsl:value-of select="title"/>
                                </h2>
                            </a>
                            
                            <xsl:choose>
                                <xsl:when test="icon/image">
                                    <img class="icon" src="{fn:root-path($set, concat('images/', icon/image/@href))}" alt="{icon/image/@alt}"/>
                                </xsl:when>
                                <xsl:when test="self::class">
                                    <img class="icon" src="{fn:root-path($set, 'images/class-icon.svg')}" alt="Class"/>
                                </xsl:when>
                                <xsl:when test="self::guide">
                                    <img class="icon" src="{fn:root-path($set, 'images/guide-icon.svg')}" alt="Guide"/>
                                </xsl:when>
                            </xsl:choose>
                            
                            <p class="description">
                                <xsl:value-of select="description"/>
                            </p>
                            
                            <ul class="item-list">
                                <xsl:for-each select="items/* | lessons/lesson | articles/article | packages/package">
                                    <li>
                                        <a href="{fn:relative-result-path($set, .)}">
                                            <xsl:value-of select="title | name"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<!-- ======== -->
<!-- Training -->
<!-- ======== -->

<xsl:template match="class[not(parent::classes/parent::package)]">
    <xsl:apply-templates select="lessons/lesson"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="toc"/>
                
<!--                 <h1>
                    <xsl:value-of select="title"/>
                </h1>
 -->                
                <xsl:apply-templates select="introduction/*"/>
                
                <xsl:if test="lessons/lesson">
                    <h2>Lessons</h2>
                    <hr/>
                    <dl>
                        <xsl:variable name="class" select="."/>
                        
                        <xsl:for-each select="lessons/lesson">
                            <dt>
                                <a href="{fn:relative-result-path($class, .)}">
                                    <xsl:value-of select="title"/>
                                </a>
                            </dt>
                            <dd>
                                <xsl:value-of select="description"/>
                            </dd>
                        </xsl:for-each>
                    </dl>
                </xsl:if>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="class" mode="toc">
    <div class="toc">
        <div class="class-nav">
            <a class="first">
                <xsl:choose>
                    <xsl:when test="lessons/lesson">
                        <xsl:attribute name="href">
                            <xsl:value-of select="fn:relative-result-path(., lessons/lesson[1])"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">first disabled</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:text>Get started &right-chevron;</xsl:text>
            </a>
        </div>
        
        <xsl:if test="lessons/lesson">
            <h2>This class teaches you about</h2>
            <ol>
                <xsl:variable name="class" select="."/>
                
                <xsl:for-each select="lessons/lesson">
                    <li>
                        <a href="{fn:relative-result-path($class, .)}"><xsl:value-of select="title"/></a>
                    </li>
                </xsl:for-each>
            </ol>
        </xsl:if>
        
        <xsl:if test="dependencies/item">
            <h2>Dependencies &amp; prerequisites</h2>
            <ul>
                <xsl:for-each select="dependencies/item">
                    <li>
                        <xsl:apply-templates select="text()|*"/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        
        <xsl:if test="related/item">
            <h2>You should also read</h2>
            <ul>
                <xsl:for-each select="related/item">
                    <li>
                        <xsl:apply-templates select="text()|*"/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </div>
</xsl:template>

<xsl:template match="lesson">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="toc"/>
                
<!--                 <h1>
                    <xsl:value-of select="title"/>
                </h1>
 -->                
                <xsl:apply-templates select="introduction/*"/>
                
                <xsl:apply-templates select="tasks/task"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="lesson" mode="toc">
    <div class="toc">
        <div class="lesson-nav">
            <a class="first">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::lesson">
                        <xsl:attribute name="href">
                            <xsl:value-of select="fn:relative-result-path(., preceding-sibling::lesson[1])"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">first disabled</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:text>&left-chevron; Previous</xsl:text>
            </a>
            <a>
                <xsl:choose>
                    <xsl:when test="following-sibling::lesson">
                        <xsl:attribute name="href">
                            <xsl:value-of select="fn:relative-result-path(., following-sibling::lesson[1])"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">disabled</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:text>Next &right-chevron;</xsl:text>
            </a>
        </div>
        
        <xsl:if test="descendant::task">
            <h2>This lesson teaches you to</h2>
            <ol>
                <xsl:for-each select="descendant::task">
                    <li>
                        <a href="#{@id}"><xsl:value-of select="title"/></a>
                    </li>
                </xsl:for-each>
            </ol>
        </xsl:if>
        
        <xsl:if test="related/item">
            <h2>You should also read</h2>
            <ul>
                <xsl:for-each select="related/item">
                    <li>
                        <xsl:apply-templates select="text()|*"/>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </div>
</xsl:template>

<xsl:template match="task">
    <h2 id="{@id}">
        <xsl:value-of select="title"/>
    </h2>
    <hr />
    
    <xsl:apply-templates select="body/(*|text())"/>
</xsl:template>

<!-- ====== -->
<!-- Guides -->
<!-- ====== -->

<xsl:template match="guide">
    <xsl:apply-templates select="articles/article"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>
                    <xsl:value-of select="title"/>
                </h1> -->
                
                <xsl:apply-templates select="introduction/*"/>
                
                <xsl:if test="articles/article">
                    <h2>Articles</h2>
                    <hr/>
                    <dl>
                        <xsl:variable name="article" select="."/>
                        
                        <xsl:for-each select="articles/article">
                            <dt>
                                <a href="{fn:relative-result-path($article, .)}">
                                    <xsl:value-of select="title"/>
                                </a>
                            </dt>
                            <dd>
                                <xsl:value-of select="description"/>
                            </dd>
                        </xsl:for-each>
                    </dl>
                </xsl:if>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="article">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>
                    <xsl:value-of select="title"/>
                </h1>
 -->                
                <xsl:apply-templates select="introduction/*"/>
                
                <xsl:apply-templates select="topics/topic"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="topic">
    <h2 id="{@id}">
        <xsl:value-of select="title"/>
    </h2>
    <hr />
    
    <xsl:apply-templates select="body/(text()|*)"/>
</xsl:template>

<!-- ==== -->
<!-- Page -->
<!-- ==== -->

<xsl:template match="page">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>
                    <xsl:value-of select="title"/>
                </h1>
 -->                
                <xsl:apply-templates select="body/(text()|*)"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="xhtml-page">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
                <xsl:apply-templates select="body/(text()|*)"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="hippo-root">
    <xsl:param name="active"/>
    
    <td>
        <a class="dark">
            <xsl:attribute name="href">
                <xsl:value-of select="@href"/>
<!--                 <xsl:choose>
                    <xsl:when test="@href">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="fn:relative-result-path($active, descendant-or-self::*[self::set or self::guide or self::class or self::article or self::lesson or self::page or self::xhtml-page or self::api or self::package][1])"/>
                    </xsl:otherwise>
                </xsl:choose> -->
            </xsl:attribute>
            
            <xsl:attribute name="class">
                <xsl:text>dark</xsl:text>
<!--                 <xsl:if test="descendant-or-self::*[fn:equals(self::*, $active)]"> active</xsl:if> -->
            </xsl:attribute>
            
            <xsl:value-of select="@title"/>
        </a>
    </td>
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
                <xsl:apply-templates select="body/(text()|*)"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<!-- ==== -->
<!-- APIs -->
<!-- ==== -->

<xsl:template match="api">
    <xsl:apply-templates select="packages/package"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>Package Index</h1> -->
                <p>
                    <xsl:apply-templates select="introduction/(*|text())"/>
                </p>
                
                <div class="table">
                    <table>
                        <tr>
                            <th>Package</th>
                            <th>Description</th>
                        </tr>
                        <tbody>
                            <xsl:variable name="api" select="."/>
                            
                            <xsl:for-each select="packages/package">
                                <tr>
                                    <td>
                                        <a href="{fn:relative-result-path($api, .)}">
                                            <xsl:value-of select="name"/>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:copy-of select="fn:link($api, description)"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="package">
    <xsl:apply-templates select="classes/class"/>
    
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>
                    <xsl:value-of select="name"/>
                </h1>
 -->                <p>
                    <xsl:copy-of select="fn:link(., description)"/>
                </p>
                <div class="table">
                    <table>
                        <tr>
                            <th>Class</th>
                            <th>Description</th>
                        </tr>
                        <tbody>
                            <xsl:variable name="package" select="."/>
                            
                            <xsl:for-each select="classes/class">
                                <tr>
                                    <td>
                                        <a href="{fn:relative-result-path($package, .)}">
                                            <xsl:apply-templates select="@name"/>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:copy-of select="fn:link($package, @description)"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="class[parent::classes/parent::package]">
    <xsl:result-document href="{fn:result-path(.)}">
        <xsl:apply-templates select="." mode="wrap-page">
            <xsl:with-param name="content">
<!--                 <h1>
                    <xsl:value-of select="@name"/>
                </h1> -->
                <xsl:if test="@extends">
                    <div style="margin-top:-28px">
                        <xsl:text>extends </xsl:text>
                        <xsl:copy-of select="fn:link(., @extends)"/>
                    </div>
                </xsl:if>
                <p>
                    <xsl:copy-of select="fn:link(., @description)"/>
                </p>
                
                <h2>Syntax</h2>
                <hr/>
                <xsl:apply-templates select="syntax"/>
                
                <h2>Summary</h2>
                <hr/>
                <xsl:call-template name="members-summary">
                    <xsl:with-param name="title">Constants</xsl:with-param>
                    <xsl:with-param name="members" select="constants/constant"/>
                </xsl:call-template>
                <xsl:apply-templates select="ctors" mode="summary"/>
                <xsl:apply-templates select="events" mode="summary"/>
                <xsl:apply-templates select="enums" mode="summary"/>
                <xsl:call-template name="members-summary">
                    <xsl:with-param name="title">Properties</xsl:with-param>
                    <xsl:with-param name="members" select="classMembers/properties/property | instanceMembers/properties/property"/>
                </xsl:call-template>
                <xsl:call-template name="members-summary">
                    <xsl:with-param name="title">Methods</xsl:with-param>
                    <xsl:with-param name="members" select="classMembers/methods/method | instanceMembers/methods/method"/>
                </xsl:call-template>
                <xsl:call-template name="members-summary">
                    <xsl:with-param name="title">Delegates</xsl:with-param>
                    <xsl:with-param name="members" select="delegates/method"/>
                </xsl:call-template>
                
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Constants</xsl:with-param>
                    <xsl:with-param name="members" select="constants/constant"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Constructors</xsl:with-param>
                    <xsl:with-param name="members" select="ctors/method"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Events</xsl:with-param>
                    <xsl:with-param name="members" select="events/event"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Enums</xsl:with-param>
                    <xsl:with-param name="members" select="enums/enum"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Properties</xsl:with-param>
                    <xsl:with-param name="members" select="classMembers/properties/property | instanceMembers/properties/property"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Methods</xsl:with-param>
                    <xsl:with-param name="members" select="classMembers/methods/method | instanceMembers/methods/method"/>
                </xsl:call-template>
                <xsl:call-template name="members-detail">
                    <xsl:with-param name="title">Delegates</xsl:with-param>
                    <xsl:with-param name="members" select="delegates/method"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:result-document>
</xsl:template>

<xsl:template match="ctors" mode="summary">
    <xsl:if test="method">
        <div class="table">
            <table>
                <tr>
                    <th>Constructors</th>
                </tr>
                <tbody>
                    <xsl:for-each select="method">
                        <xsl:sort select="fn:get-member-name-parts(@name)[4]"/>
                        
                        <xsl:variable name="member-name-parts" select="fn:get-member-name-parts(@name)"/>
                        <tr>
                            <td>
                                <div>
                                    <a href="{concat('#', fn:create-member-anchor-name(@name))}">
                                        <xsl:value-of select="$member-name-parts[2]"/>
                                    </a>
                                    <xsl:copy-of select="fn:link(., $member-name-parts[3])"/>
                                </div>
                                <div style="margin-left:10px">
                                    <xsl:copy-of select="fn:link(., @description)"/>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="events" mode="summary">
    <xsl:if test="event">
        <div class="table">
            <table>
                <tr>
                    <th>Events</th>
                </tr>
                <tbody>
                    <xsl:for-each select="event">
                        <xsl:sort select="fn:get-member-name-parts(@name)[4]"/>
                        
                        <xsl:variable name="member-name-parts" select="fn:get-member-name-parts(@name)"/>
                        <tr>
                            <td>
                                <div>
                                    <a href="{concat('#', fn:create-member-anchor-name(@name))}">
                                        <xsl:value-of select="$member-name-parts[2]"/>
                                    </a>
                                </div>
                                <div style="margin-left:10px">
                                    <xsl:copy-of select="fn:link(., @description)"/>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="enums" mode="summary">
    <xsl:if test="enum">
        <div class="table">
            <table>
                <tr>
                    <th>Enums</th>
                </tr>
                <tbody>
                    <xsl:for-each select="enum">
                        <xsl:sort select="fn:get-member-name-parts(@name)[4]"/>
                        
                        <xsl:variable name="member-name-parts" select="fn:get-member-name-parts(@name)"/>
                        <tr>
                            <td>
                                <div>
                                    <a href="{concat('#', fn:create-member-anchor-name(@name))}">
                                        <xsl:value-of select="$member-name-parts[2]"/>
                                    </a>
                                </div>
                                <div style="margin-left:10px">
                                    <xsl:copy-of select="fn:link(., @description)"/>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="members-summary">
    <xsl:param name="title"/>
    <xsl:param name="members"/>
    
    <xsl:if test="$members">
        <div class="table">
            <table>
                <tr>
                    <th colspan="2">
                        <xsl:value-of select="$title"/>
                    </th>
                </tr>
                <tbody>
                    <xsl:for-each select="$members">
                        <xsl:sort select="fn:get-member-name-parts(@name)[4]"/>
                        
                        <xsl:variable name="member-name-parts" select="fn:get-member-name-parts(@name)"/>
                        <tr>
                            <td>
                                <nobr>
                                    <xsl:if test="parent::*/parent::classMembers">
                                        <xsl:text>static </xsl:text>
                                    </xsl:if>
                                    <xsl:copy-of select="fn:link(., $member-name-parts[1])"/>
                                </nobr>
                            </td>
                            <td>
                                <div>
                                    <a href="{concat('#', fn:create-member-anchor-name(@name))}">
                                        <xsl:value-of select="$member-name-parts[2]"/>
                                    </a>
                                    <xsl:if test="self::property">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                    <xsl:copy-of select="fn:link(., $member-name-parts[3])"/>
                                </div>
                                <div style="margin-left:10px">
                                    <xsl:copy-of select="fn:link(., @description)"/>
                                </div>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="members-detail">
    <xsl:param name="title"/>
    <xsl:param name="members"/>
    
    <xsl:if test="$members">
        <h2>
            <xsl:value-of select="$title"/>
        </h2>
        <hr/>
        
        <xsl:for-each select="$members">
            <xsl:sort select="fn:get-member-name-parts(@name)[4]"/>
            
            <xsl:variable name="member-name-parts" select="fn:get-member-name-parts(@name)"/>
            <a id="{fn:create-member-anchor-name(@name)}"/>
            <div style="background-color:rgba(0, 0, 0, 0.05); padding:10px">
                <xsl:if test="parent::*/parent::classMembers">
                    <xsl:text>static </xsl:text>
                </xsl:if>
                <xsl:copy-of select="fn:link(., $member-name-parts[1])"/>
                <xsl:text> </xsl:text>
                <strong>
                    <xsl:value-of select="$member-name-parts[2]"/>
                </strong>
                <xsl:if test="self::property">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:copy-of select="fn:link(., $member-name-parts[3])"/>
            </div>
            
            <div style="padding:15px">
                <div>
                    <xsl:copy-of select="fn:link(., @description)"/>
                </div>
                
                <xsl:if test="params/param">
                    <h3>Parameters</h3>
                    
                    <table>
                        <tbody>
                            <xsl:for-each select="params/param">
                                <tr>
                                    <td>
                                        <em>
                                            <xsl:value-of select="@name"/>
                                        </em>
                                    </td>
                                    <td style="padding-left:15px">
                                        <xsl:copy-of select="fn:link(., @description)"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:if>
                
                <xsl:if test="values/value">
                    <h3>Values</h3>
                    
                    <table>
                        <tbody>
                            <xsl:for-each select="values/value">
                                <tr>
                                    <td style="vertical-align:top">
                                        <em>
                                            <xsl:value-of select="@name"/>
                                        </em>
                                    </td>
                                    <td style="padding-left:15px; vertical-align:top">
                                        <xsl:copy-of select="fn:link(., @description)"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:if>
                
                <xsl:if test="@returns">
                    <h3>Returns</h3>
                    
                    <div>
                        <xsl:copy-of select="fn:link(., @returns)"/>
                    </div>
                </xsl:if>
                
                <xsl:if test="@errors">
                    <h3>Errors</h3>
                    
                    <div>
                        <xsl:copy-of select="fn:link(., @errors)"/>
                    </div>
                </xsl:if>
                
                <xsl:if test="syntax/syntax">
                    <h3>Syntax</h3>
                    
                    <xsl:apply-templates select="syntax"/>
                </xsl:if>
            </div>
        </xsl:for-each>
    </xsl:if>
</xsl:template>

<xsl:function name="fn:get-syntax">
    <xsl:param name="syntax-set"/>
    <xsl:param name="language"/>
    
    <!-- If there is a syntax for the current language then return that otherwise climb the super-language tree until we find a block. -->
    <xsl:choose>
        <xsl:when test="$syntax-set/syntax[lower-case(@language)=lower-case($language/@name)]">
            <xsl:copy-of select="$syntax-set/syntax[lower-case(@language)=lower-case($language/@name)]"/>
        </xsl:when>
        <xsl:when test="$language/@extends">
            <xsl:copy-of select="fn:get-syntax($syntax-set, $languages[@name = $language/@extends])"/>
        </xsl:when>
    </xsl:choose>
</xsl:function>
    
<xsl:template match="syntax">
    <xsl:variable name="syntax-set" select="."/>
    
    <div class="tab-bar">
        <xsl:for-each select="$languages">
            <xsl:variable name="language" select="."/>
            <xsl:variable name="language-name" select="$language/@name"/>
            <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
            
            <a href="javascript:setLanguage({fn:iif($escaped-language-name, concat('&quot;', $escaped-language-name, '&quot;'), 'null')})">
                <xsl:attribute name="class">
                    <xsl:text>tab</xsl:text>
                    <xsl:value-of select="fn:iif($escaped-language-name, concat(' stripe-active ', $escaped-language-name), '')"/>
                    
                    <xsl:if test="not(fn:get-syntax($syntax-set, $language))">
                        <xsl:text> disabled</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                
                <xsl:value-of select="$language-name"/>
            </a>
        </xsl:for-each>
    </div>
    <xsl:for-each select="$languages">
        <xsl:variable name="language" select="."/>
        <xsl:variable name="language-name" select="$language/@name"/>
        <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
        <xsl:variable name="syntax" select="fn:get-syntax($syntax-set, $language)"/>
        
        <span class="stripe-display {$escaped-language-name}">
            <xsl:choose>
                <xsl:when test="$syntax/@syntax">
                    <xsl:call-template name="code-block">
                        <xsl:with-param name="code" select="replace($syntax/@syntax, '%', '')"/>
                        <xsl:with-param name="escaped-language-name" select="$escaped-language-name"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$syntax">
                    <xsl:call-template name="code-block">
                        <xsl:with-param name="code" select="replace($syntax, '%', '')"/>
                        <xsl:with-param name="escaped-language-name" select="$escaped-language-name"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <pre>
                        <code class="disabled">
                            <xsl:text>Not applicable.</xsl:text>
                        </code>
                    </pre>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:for-each>
</xsl:template>

<xsl:function name="fn:get-member-name-parts">
    <xsl:param name="name"/>
    
    <xsl:variable name="first-part">
        <xsl:choose>
            <xsl:when test="contains($name, '{')">
                <xsl:value-of select="substring-before($name, ' {')"/>
            </xsl:when>
            <xsl:when test="contains($name, '(')">
                <xsl:value-of select="substring-before($name, '(')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="return-part">
        <xsl:for-each select="tokenize($first-part, ' ')[position() &lt; last()]">
            <xsl:if test="position() != 1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="name-part" select="tokenize($first-part, ' ')[last()]"/>
    <xsl:variable name="signature-part" select="substring-after($name, $first-part)"/>
    
    <xsl:value-of select="$return-part"/>
    <xsl:value-of select="$name-part"/>
    <xsl:value-of select="$signature-part"/>
    <xsl:value-of select="concat($name-part, ' ', $signature-part)"/>
</xsl:function>

<xsl:function name="fn:create-member-anchor-name">
    <xsl:param name="name"/>
    
    <xsl:value-of select="replace(replace(lower-case($name), '[^a-z0-9\-\.\s]', ''), '\s', '-')"/>
</xsl:function>

<xsl:function name="fn:link">
    <xsl:param name="current"/>
    <xsl:param name="value"/>
    
    <xsl:variable name="classes" select="$current/ancestor-or-self::api[1]/descendant::class"/>
    <xsl:variable name="delegates" select="$current/ancestor-or-self::class[1]/descendant::delegates/method"/>
    
    <xsl:for-each select="tokenize($value, '%')">
        <xsl:variable name="name" select="."/>
        <xsl:variable name="unpluralized-name">
            <xsl:choose>
                <xsl:when test="ends-with($name, 'ies')">
                    <xsl:value-of select="concat(substring($name, 1, string-length($name)-3), 'y')"/>
                </xsl:when>
                <xsl:when test="ends-with($name, 's')">
                    <xsl:value-of select="substring($name, 1, string-length($name)-1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="unpossessive-name" select="fn:iif(contains($name, &quot;'&quot;), substring-before($name, &quot;'&quot;), $name)"/>
        
        <xsl:variable name="class" select="$classes[@name=$name or @name=$unpluralized-name or @name=$unpossessive-name]"/>
        <xsl:variable name="delegate" select="$delegates[fn:get-member-name-parts(@name)[2]=$name or fn:get-member-name-parts(@name)[2]=$unpluralized-name or fn:get-member-name-parts(@name)[2]=$unpossessive-name]"/>
        
        <xsl:choose>
            <xsl:when test="$class">
                <a href="{fn:relative-result-path($current, $class)}">
                    <xsl:value-of select="$name"/>
                </a>
            </xsl:when>
            <xsl:when test="$delegate">
                <a href="{concat('#', fn:create-member-anchor-name($delegate/@name))}">
                    <xsl:value-of select="$name"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:function>

<!-- ====== -->
<!-- Common -->
<!-- ====== -->

<xsl:template match="section">
    <h3 id="{@id}">
        <xsl:value-of select="title"/>
    </h3>
    
    <xsl:apply-templates select="body/*"/>
</xsl:template>
    
<xsl:template match="subsection">
    <h4 id="{@id}">
        <xsl:value-of select="title"/>
    </h4>
    
    <xsl:apply-templates select="body/*"/>
</xsl:template>

<xsl:template match="paragraph">
    <p>
        <xsl:apply-templates select="text()|*"/>
    </p>
</xsl:template>

<xsl:template match="image">
    <!-- Copy the image from the source, to the destination. -->
    <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@href))"/>
    <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@href))"/>
    <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
    
    <img src="{@href}" alt="{@alt}" width="{@width}" height="{@height}" style="{@style}"/>
</xsl:template>

<xsl:template match="figure">
    <div>
        <xsl:attribute name="class">
            <xsl:text>figure</xsl:text>
            <xsl:choose>
                <xsl:when test="@importance='high'"> high</xsl:when>
                <xsl:when test="@importance='normal'"> normal</xsl:when>
                <xsl:otherwise> low</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        
        <xsl:choose>
            <xsl:when test="@width">
                <xsl:attribute name="style">
                    <xsl:text>width:</xsl:text>
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="descendant::*/@width">
                <xsl:attribute name="style">
                    <xsl:text>width:</xsl:text>
                    <xsl:value-of select="descendant::*/@width"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
        
        <xsl:apply-templates select="*[not(self::description)]"/>
        
        <xsl:if test="description">
            <div class="caption">
                <xsl:variable name="base-uri" select="base-uri()"/>
                
                <span class="tag">Figure <xsl:value-of select="count(preceding::fig[description and base-uri()=$base-uri]) + 1"/>.</span>
                <xsl:apply-templates select="description[1]/(text()|*)"/>
            </div>
        </xsl:if>
    </div>
</xsl:template>
    
<xsl:template match="code">
    <code>
        <xsl:apply-templates select="text()"/>
    </code>
</xsl:template>
    
<xsl:template match="code-block">
    <xsl:call-template name="code-block">
        <xsl:with-param name="code" select="."/>
        <xsl:with-param name="escaped-language-name" select="none"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="code-block">
    <xsl:param name="code"/>
    <xsl:param name="escaped-language-name" tunnel="yes"/>
    
    <pre>
        <xsl:choose>
          <xsl:when test="$escaped-language-name='objective-c'">
            <code class="pre codeblock language-c">
              <!-- Get the number of leading spaces on the 1st line. -->
              <xsl:variable name="lines" select="tokenize(replace(string($code), '\t', '    '), '\n\r?')"/>
              <xsl:variable name="firstLine" select="fn:iif(string-length($lines[1]) > 0, $lines[1], $lines[2])"/>
              <xsl:variable name="indentSize" select="string-length(substring-before($firstLine, substring(normalize-space($firstLine), 1, 1))) + 1"/>
    
              <xsl:for-each select="$lines">
                <xsl:variable name="unindented-line" select="substring(., $indentSize)"/>
      
                <xsl:if test="string-length($unindented-line)">
                  <xsl:value-of select="$unindented-line" />
                  <xsl:text>&#10;</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </code>
          </xsl:when>
          <xsl:when test="$escaped-language-name='android'">
            <code class="pre codeblock language-java">
              <!-- Get the number of leading spaces on the 1st line. -->
              <xsl:variable name="lines" select="tokenize(replace(string($code), '\t', '    '), '\n\r?')"/>
              <xsl:variable name="firstLine" select="fn:iif(string-length($lines[1]) > 0, $lines[1], $lines[2])"/>
              <xsl:variable name="indentSize" select="string-length(substring-before($firstLine, substring(normalize-space($firstLine), 1, 1))) + 1"/>
    
              <xsl:for-each select="$lines">
                <xsl:variable name="unindented-line" select="substring(., $indentSize)"/>
      
                <xsl:if test="string-length($unindented-line)">
                  <xsl:value-of select="$unindented-line" />
                  <xsl:text>&#10;</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </code>
          </xsl:when>
          <xsl:otherwise>
            <code class="pre codeblock language-{$escaped-language-name}">
              <!-- Get the number of leading spaces on the 1st line. -->
              <xsl:variable name="lines" select="tokenize(replace(string($code), '\t', '    '), '\n\r?')"/>
              <xsl:variable name="firstLine" select="fn:iif(string-length($lines[1]) > 0, $lines[1], $lines[2])"/>
              <xsl:variable name="indentSize" select="string-length(substring-before($firstLine, substring(normalize-space($firstLine), 1, 1))) + 1"/>
    
              <xsl:for-each select="$lines">
                <xsl:variable name="unindented-line" select="substring(., $indentSize)"/>
      
                <xsl:if test="string-length($unindented-line)">
                  <xsl:value-of select="$unindented-line" />
                  <xsl:text>&#10;</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </code>
          </xsl:otherwise>
        </xsl:choose>
    </pre>
</xsl:template>
    
<xsl:template match="code-set">
    <xsl:variable name="code-set" select="."/>
    
    <div class="tab-bar">
        <xsl:for-each select="$languages">
            <xsl:variable name="language" select="."/>
            <xsl:variable name="language-name" select="$language/@name"/>
            <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
            
            <a href="javascript:setLanguage({fn:iif($escaped-language-name, concat('&quot;', $escaped-language-name, '&quot;'), 'null')})">
                <xsl:attribute name="class">
                    <xsl:text>tab</xsl:text>
                    <xsl:value-of select="fn:iif($escaped-language-name, concat(' stripe-active ', $escaped-language-name), '')"/>
                    
                    <xsl:if test="not(fn:get-code-block($code-set, $language))">
                        <xsl:text> disabled</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                
                <xsl:value-of select="$language-name"/>
            </a>
        </xsl:for-each>
    </div>
    <xsl:for-each select="$languages">
        <xsl:variable name="language" select="."/>
        <xsl:variable name="language-name" select="$language/@name"/>
        <xsl:variable name="escaped-language-name" select="fn:escape-css-name($language-name)"/>
        <xsl:variable name="code-block" select="fn:get-code-block($code-set, $language)"/>
        
        <span class="stripe-display {$escaped-language-name}">
            <xsl:choose>
                <xsl:when test="$code-block">
                    <xsl:comment>
                      $code-block
                    </xsl:comment>
                    <xsl:apply-templates select="$code-block">
                      <xsl:with-param name="escaped-language-name" select="$escaped-language-name" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <pre>
                        <code class="disabled">
                            <xsl:text>No code example is currently available.</xsl:text>
                        </code>
                    </pre>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:for-each>
</xsl:template>

<xsl:function name="fn:get-code-block">
    <xsl:param name="code-set"/>
    <xsl:param name="language"/>
    
    <!-- If there is a code-block for the current language then return that otherwise climb the super-language tree until we find a block. -->
    <xsl:choose>
        <xsl:when test="$code-set/code-block[lower-case(@language)=lower-case($language/@name)]">
            <xsl:copy-of select="$code-set/code-block[lower-case(@language)=lower-case($language/@name)]"/>
        </xsl:when>
        <xsl:when test="$language/@extends">
            <xsl:copy-of select="fn:get-code-block($code-set, $languages[@name = $language/@extends])"/>
        </xsl:when>
    </xsl:choose>
</xsl:function>

<!-- Keys used for ref lookups. -->
<xsl:key name="target-uris" match="*" use="fn:get-uri(.)" />
<xsl:key name="target-id-urls" match="*[@id]" use="url:new(url:new(string(fn:get-uri(.))), concat('#', @id))" />

<xsl:template match="ref">
    <a>
        <xsl:if test="@href">
            <xsl:variable name="base-uri" select="fn:get-uri(.)"/>
            <xsl:variable name="target-url" select="url:new(url:new(string($base-uri)), @href)"/>
            
            <xsl:variable name="target" select="key('target-id-urls', string($target-url))"/>
            <xsl:variable name="href">
                <xsl:choose>
                    <xsl:when test="$target">
                        <xsl:value-of select="fn:relative-result-path(., $target)"/>
                        
                        <xsl:variable name="target-fragment" select="uri:getFragment(url:toURI($target-url))"/>
                        <xsl:if test="$target-fragment">
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="$target-fragment"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="target" select="key('target-uris', string($target-url))"/>
                        
                        <xsl:if test="$target">
                            <xsl:value-of select="fn:relative-result-path(., $target)"/>
                            
                            <xsl:variable name="target-fragment" select="uri:getFragment(url:toURI($target-url))"/>
                            <xsl:if test="$target-fragment">
                                <xsl:text>#</xsl:text>
                                <xsl:value-of select="$target-fragment"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="string-length($href) > 0">
                    <xsl:attribute name="href" select="$href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:text>ERROR: Ref not found</xsl:text>
                        <xsl:text>&#10;  Base Uri: </xsl:text>
                        <xsl:value-of select="$base-uri"/>
                        <xsl:text>&#10;  Target Uri: </xsl:text>
                        <xsl:value-of select="$target-url"/>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
        <xsl:value-of select="."/>
    </a>
</xsl:template>
    
<xsl:template match="external-ref">
    <a>
        <xsl:if test="@href">
            <xsl:attribute name="href" select="@href"/>
        </xsl:if>
        
        <xsl:value-of select="."/>
    </a>
</xsl:template>

<xsl:template match="emphasis">
    <em>
        <xsl:apply-templates select="text()|*"/>
    </em>
</xsl:template>

<xsl:template match="strong">
    <strong>
        <xsl:apply-templates select="text()|*"/>
    </strong>
</xsl:template>

<xsl:template match="ordered-list">
    <ol>
        <xsl:apply-templates select="list-item"/>
    </ol>
</xsl:template>

<xsl:template match="unordered-list">
    <ul class="ul">
        <xsl:apply-templates select="list-item"/>
    </ul>
</xsl:template>

<xsl:template match="description-list">
    <dl>
        <xsl:apply-templates select="entry"/>
    </dl>
</xsl:template>

<xsl:template match="list-item">
    <li>
        <xsl:apply-templates select="text()|*"/>
    </li>
</xsl:template>

<xsl:template match="entry">
    <dt>
        <xsl:apply-templates select="title[1]/(text()|*)"/>
    </dt>
    <dd>
        <xsl:apply-templates select="description[1]/(text()|*)"/>
    </dd>
</xsl:template>

<xsl:template match="note">
    <div>
        <xsl:attribute name="class">
            <xsl:text>note</xsl:text>
            <xsl:choose>
                <xsl:when test="@type='tip'"> tip</xsl:when>
                <xsl:when test="@type='caution'"> caution</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        
        <span class="tag">
            <xsl:choose>
                <xsl:when test="@type='tip'">Tip:</xsl:when>
                <xsl:when test="@type='caution'">Caution:</xsl:when>
                <xsl:otherwise>Note:</xsl:otherwise>
            </xsl:choose>
        </span>
        
        <xsl:apply-templates select="text()|*"/>
    </div>
</xsl:template>
    
<xsl:template match="table[not(descendant::tr)]">
    <div class="table">
        <table>
            <xsl:for-each select="header">
                <thead>
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <th>
                                    <xsl:if test="@colspan">
                                        <xsl:attribute name="colspan" select="@colspan"/>
                                    </xsl:if>
                                    <xsl:if test="@rowspan">
                                        <xsl:attribute name="rowspan" select="@rowspan"/>
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="text()|*"/>
                                </th>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </thead>
            </xsl:for-each>
            <xsl:for-each select="body">
                <tbody>
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <td>
                                    <xsl:if test="@colspan">
                                        <xsl:attribute name="colspan" select="@colspan"/>
                                    </xsl:if>
                                    <xsl:if test="@rowspan">
                                        <xsl:attribute name="rowspan" select="@rowspan"/>
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="text()|*"/>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </xsl:for-each>
        </table>
        
        <xsl:if test="description">
            <div class="caption">
                <xsl:variable name="base-uri" select="base-uri()"/>
                
                <span class="tag">Table <xsl:value-of select="count(preceding::table[description and base-uri()=$base-uri]) + 1"/>.</span>
                <xsl:apply-templates select="description[1]/(text()|*)"/>
            </div>  
        </xsl:if>
    </div>
</xsl:template>

<!-- ============================== -->
<!-- Broad match for XHTML Elements -->
<!-- ============================== -->

<xsl:template match="*" >
    <!-- Allow anything in an xhtml-page and a head element. -->
    <xsl:if test="ancestor::xhtml-page or ancestor::head">
        <xsl:if test="self::img">
            <!-- Copy the image from the source, to the destination. -->
            <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@src))"/>
            <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@src))"/>
            <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
        </xsl:if>
        
        <xsl:if test="self::link">
            <!-- Copy the linked file from the source, to the destination. -->
            <xsl:variable name="source-file" select="file:new(string(fn:base-directory(.)), string(@href))"/>
            <xsl:variable name="destination-file" select="file:new(string(fn:result-directory(.)), string(@href))"/>
            <xsl:value-of select="fn:copy-file(file:getAbsolutePath($source-file), file:getAbsolutePath($destination-file))"/>
        </xsl:if>
        
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            
            <xsl:apply-templates select="text()|*"/>
        </xsl:copy>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>