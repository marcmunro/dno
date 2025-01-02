<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Change article to be appendix -->
  <xsl:template match="/d:article">
    <appendix>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </appendix>
  </xsl:template>

  <!-- Change title to be command name and man section in lower-case -->
  <xsl:template match="/d:article/d:info/d:title">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
	  <xsl:when test="contains(text(), '1')">
	    <xsl:value-of
		select="translate(concat(substring-before(text(), ')'), ')'),
			          'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
			          'abcdefghijklmnopqrstuvwxyz')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of
		select="concat(substring-before(text(), ')'), ')')"/>
	  </xsl:otherwise>
	</xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
