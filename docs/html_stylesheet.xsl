<?xml version='1.0'?>
<!--
       Custom docbook stylesheet for html for the dno user guide.
       This is part of dno, the Arduino build system.

       Copyright (c) 2025 Marc Munro
       Author:  Marc Munro
       License: GPL-3.0

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:lxslt="http://xml.apache.org/xslt"
                xmlns:redirect="http://xml.apache.org/xalan/redirect"
                xmlns:exsl="http://exslt.org/common"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:d="http://docbook.org/ns/docbook"
		version="1.0"
                exclude-result-prefixes="saxon lxslt redirect exsl doc"
                extension-element-prefixes="saxon redirect lxslt exsl">

  <xsl:import href="core-stylesheet.xsl"/>

  <xsl:param name="custom.css.source">dno.css.xml</xsl:param>

  <!-- Auto-generation of tables of contents -->
  <xsl:param name="generate.toc">
    set         toc
    book     toc,title
    part     toc,title
  </xsl:param>
  <xsl:param name="toc.max.depth">2</xsl:param>
  <xsl:param name="toc.section.depth">2</xsl:param>
  <xsl:param name="toc.appendix.depth">2</xsl:param>

  <!-- Auto-numbering of sections -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

  <xsl:param name="appendix.autolabel" select="A"/>
  <xsl:param name="section.autolabel.max.depth" select="3"/>
  <xsl:param name="chunk.section.depth" select="0"/>

  <!-- Easier to read html -->
  <xsl:param name="chunker.output.indent" select="'yes'"/>
  <xsl:param name="chunker.output.encoding">UTF-8</xsl:param>


  <!-- Prevent appendix sections appearing in tocs -->
  <xsl:template match="d:appendix/d:section" mode="toc"/>

  <!-- Prevent section numbering in appendices 
       This hacks the template for a title section to remove the
       %n. part.  It's not a great hack but it's as simple as I can
       come up with for now.  MM 2025 -->
  <xsl:template match="d:appendix/d:section" mode="object.title.markup">

    <xsl:param name="allow-anchors" select="0"/>
    <xsl:variable name="template">
      <xsl:apply-templates select="." mode="object.title.template"/>
    </xsl:variable>
  
    <!--
	<xsl:message>
	<xsl:text>object.title.markup: </xsl:text>
	<xsl:value-of select="local-name(.)"/>
	<xsl:text>: </xsl:text>
	<xsl:value-of select="$template"/>
	</xsl:message>
    -->

    <xsl:call-template name="substitute-markup">
      <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
      <xsl:with-param name="template"
		      select="concat('%t', substring-after($template, '%t'))"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

