<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                version="3.0"
                xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all">
   <xsl:output indent="yes" method="xml"/>
   <!-- OSCAL system-security-plan conversion stylesheet supports JSON->XML conversion -->
   <xsl:param name="target-ns"
              as="xs:string?"
              select="'http://csrc.nist.gov/ns/oscal/1.0'"/>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <xsl:output indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xsl:preserve-space elements="string"/>
   <xsl:param name="json-file" as="xs:string?"/>
   <xsl:variable name="using-json-file"
                 select="replace($json-file,'^/','') ! ('file:///' || .)"/>
   <xsl:variable name="json-xml"
                 select="unparsed-text($using-json-file) ! json-to-xml(.)"/>
   <xsl:template name="xsl:initial-template" match="/">
      <xsl:choose>
         <xsl:when test="matches($json-file,'\S') and exists($json-xml/map)">
            <xsl:apply-templates select="$json-xml" mode="json2xml"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="json2xml"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="/map[empty(@key)]" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current" select="*[@key=('system-security-plan')]"/>
   </xsl:template>
   <xsl:template match="array" priority="10" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template match="string[@key='RICHTEXT']" mode="json2xml">
      <xsl:call-template name="parse">
         <xsl:with-param name="markdown-str" select="string(.)"/>
      </xsl:call-template>
   </xsl:template>
   <xsl:template match="string[@key='STRVALUE']" mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template mode="as-attribute" match="*"/>
   <xsl:template mode="as-attribute" match="string[@key='id']" priority="0.4">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- *** Handling assembly "metadata" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='metadata']" priority="4" mode="json2xml">
      <xsl:element name="metadata" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('published')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('last-modified')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('oscal-version')]"/>
         <xsl:for-each-group group-by="true()" select="*[@key=('revision', 'revision-history')]">
            <xsl:element name="revision-history" namespace="http://csrc.nist.gov/ns/oscal/1.0">
               <xsl:apply-templates mode="#current" select="current-group()"/>
            </xsl:element>
         </xsl:for-each-group>
         <xsl:apply-templates mode="#current" select="*[@key=('doc-id', 'document-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role', 'roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('location', 'locations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party', 'parties')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "back-matter" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='back-matter']" priority="4" mode="json2xml">
      <xsl:element name="back-matter" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('resource', 'resources')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "revision" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='revision'] | array[@key='revision-history']/* | map[@key='revision-history']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="revision" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('published')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('last-modified')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('oscal-version')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "link" *** -->
   <!--*[@key='link'] | *[@key='links']  | *[@key='links']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='link'] | *[@key='links']  | *[@key='links']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="link" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='text'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='link'] | *[@key='links']  | *[@key='links']/*)/string[@key='text']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='link'] | *[@key='links']  | *[@key='links']/*)/string[@key='text']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'links']/array[@key = 'text'] | array[@key = 'links']/map/array[@key = 'text']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="links">
            <xsl:apply-templates mode="expand" select="array[@key = 'text']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'links']/array[@key = 'text']/string | array[@key = 'links']/map/array[@key = 'text']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'text']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="text">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "published" *** -->
   <!--*[@key='published']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='published']" priority="5" mode="json2xml">
      <xsl:element name="published" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "last-modified" *** -->
   <!--*[@key='last-modified']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='last-modified']" priority="5" mode="json2xml">
      <xsl:element name="last-modified" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "version" *** -->
   <!--*[@key='version']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='version']" priority="5" mode="json2xml">
      <xsl:element name="version" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "oscal-version" *** -->
   <!--*[@key='oscal-version']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='oscal-version']" priority="5" mode="json2xml">
      <xsl:element name="oscal-version" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "doc-id" *** -->
   <!--*[@key='doc-id'] | *[@key='document-ids']  | *[@key='document-ids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='doc-id'] | *[@key='document-ids']  | *[@key='document-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="doc-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='identifier']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='doc-id'] | *[@key='document-ids']  | *[@key='document-ids']/*)/string[@key='identifier']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='doc-id'] | *[@key='document-ids']  | *[@key='document-ids']/*)/string[@key='identifier']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'document-ids']/array[@key = 'identifier'] | array[@key = 'document-ids']/map/array[@key = 'identifier']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="document-ids">
            <xsl:apply-templates mode="expand" select="array[@key = 'identifier']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'document-ids']/array[@key = 'identifier']/string | array[@key = 'document-ids']/map/array[@key = 'identifier']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'identifier']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="identifier">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag @type *** -->
   <xsl:template match="*[@key='type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='doc-id']/*[@key='type'] | *[@key='document-ids']/*[@key='type'] | array[@key='document-ids']/*/*[@key='type'] | map[@key='document-ids']/*/*[@key='type'] | *[@key='party']/*[@key='type'] | *[@key='parties']/*[@key='type'] | array[@key='parties']/*/*[@key='type'] | map[@key='parties']/*/*[@key='type'] | *[@key='external-id']/*[@key='type'] | *[@key='external-ids']/*[@key='type'] | array[@key='external-ids']/*/*[@key='type'] | map[@key='external-ids']/*/*[@key='type'] | *[@key='address']/*[@key='type'] | *[@key='addresses']/*[@key='type'] | array[@key='addresses']/*/*[@key='type'] | map[@key='addresses']/*/*[@key='type'] | *[@key='phone']/*[@key='type'] | *[@key='telephone-numbers']/*[@key='type'] | array[@key='telephone-numbers']/*/*[@key='type'] | map[@key='telephone-numbers']/*/*[@key='type']"
                 mode="as-attribute">
      <xsl:attribute name="type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "prop" *** -->
   <!--*[@key='prop'] | *[@key='properties']  | *[@key='properties']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='prop'] | *[@key='properties']  | *[@key='properties']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="prop" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='value']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='prop'] | *[@key='properties']  | *[@key='properties']/*)/string[@key='value']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='prop'] | *[@key='properties']  | *[@key='properties']/*)/string[@key='value']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'properties']/array[@key = 'value'] | array[@key = 'properties']/map/array[@key = 'value']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="properties">
            <xsl:apply-templates mode="expand" select="array[@key = 'value']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'properties']/array[@key = 'value']/string | array[@key = 'properties']/map/array[@key = 'value']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'value']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="value">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling assembly "annotation" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='annotation'] | array[@key='annotations']/* | map[@key='annotations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="annotation" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "annotation/@value" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='annotation']/*[@key='value'] | *[@key='annotations']/*[@key='value'] | *[@key='annotations']/*/*[@key='value']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='annotation']/*[@key='value'] | *[@key='annotations']/*[@key='value'] | *[@key='annotations']/*/*[@key='value']"
                 mode="as-attribute">
      <xsl:attribute name="value">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @name *** -->
   <xsl:template match="*[@key='name']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='name'] | *[@key='properties']/*[@key='name'] | array[@key='properties']/*/*[@key='name'] | map[@key='properties']/*/*[@key='name'] | *[@key='annotation']/*[@key='name'] | *[@key='annotations']/*[@key='name'] | array[@key='annotations']/*/*[@key='name'] | map[@key='annotations']/*/*[@key='name'] | *[@key='protocol']/*[@key='name'] | *[@key='protocols']/*[@key='name'] | array[@key='protocols']/*/*[@key='name'] | map[@key='protocols']/*/*[@key='name']"
                 mode="as-attribute">
      <xsl:attribute name="name">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @ns *** -->
   <xsl:template match="*[@key='ns']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='ns'] | *[@key='properties']/*[@key='ns'] | array[@key='properties']/*/*[@key='ns'] | map[@key='properties']/*/*[@key='ns'] | *[@key='annotation']/*[@key='ns'] | *[@key='annotations']/*[@key='ns'] | array[@key='annotations']/*/*[@key='ns'] | map[@key='annotations']/*/*[@key='ns']"
                 mode="as-attribute">
      <xsl:attribute name="ns">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @class *** -->
   <xsl:template match="*[@key='class']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='class'] | *[@key='properties']/*[@key='class'] | array[@key='properties']/*/*[@key='class'] | map[@key='properties']/*/*[@key='class']"
                 mode="as-attribute">
      <xsl:attribute name="class">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "location" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='location'] | array[@key='locations']/* | map[@key='locations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="location" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('address')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('url', 'URLs')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "location-uuid" *** -->
   <!--*[@key='location-uuid'] | *[@key='location-uuids']  | *[@key='location-uuids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='location-uuid'] | *[@key='location-uuids']  | *[@key='location-uuids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="location-uuid" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'location-uuids']/array[@key = 'STRVALUE'] | array[@key = 'location-uuids']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="location-uuids">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'location-uuids']/array[@key = 'STRVALUE']/string | array[@key = 'location-uuids']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling assembly "party" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='party'] | array[@key='parties']/* | map[@key='parties']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="party" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('external-id', 'external-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('address', 'addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('email', 'email-addresses')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('phone', 'telephone-numbers')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('member-of-organization', 'member-of-organizations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('location-uuid', 'location-uuids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "party/@type" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='party']/*[@key='type'] | *[@key='parties']/*[@key='type'] | *[@key='parties']/*/*[@key='type']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='party']/*[@key='type'] | *[@key='parties']/*[@key='type'] | *[@key='parties']/*/*[@key='type']"
                 mode="as-attribute">
      <xsl:attribute name="type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "party-uuid" *** -->
   <!--*[@key='party-uuid'] | *[@key='party-uuids']  | *[@key='party-uuids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='party-uuid'] | *[@key='party-uuids']  | *[@key='party-uuids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="party-uuid" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'party-uuids']/array[@key = 'STRVALUE'] | array[@key = 'party-uuids']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="party-uuids">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'party-uuids']/array[@key = 'STRVALUE']/string | array[@key = 'party-uuids']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "external-id" *** -->
   <!--*[@key='external-id'] | *[@key='external-ids']  | *[@key='external-ids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='external-id'] | *[@key='external-ids']  | *[@key='external-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="external-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='id']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='external-id'] | *[@key='external-ids']  | *[@key='external-ids']/*)/string[@key='id']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='external-id'] | *[@key='external-ids']  | *[@key='external-ids']/*)/string[@key='id']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'external-ids']/array[@key = 'id'] | array[@key = 'external-ids']/map/array[@key = 'id']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="external-ids">
            <xsl:apply-templates mode="expand" select="array[@key = 'id']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'external-ids']/array[@key = 'id']/string | array[@key = 'external-ids']/map/array[@key = 'id']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'id']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="id">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "member-of-organization" *** -->
   <!--*[@key='member-of-organization'] | *[@key='member-of-organizations']  | *[@key='member-of-organizations']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='member-of-organization'] | *[@key='member-of-organizations']  | *[@key='member-of-organizations']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="member-of-organization"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'member-of-organizations']/array[@key = 'STRVALUE'] | array[@key = 'member-of-organizations']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions"
                key="member-of-organizations">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'member-of-organizations']/array[@key = 'STRVALUE']/string | array[@key = 'member-of-organizations']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling assembly "rlink" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='rlink'] | array[@key='rlinks']/* | map[@key='rlinks']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="rlink" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('hash', 'hashes')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag @rel *** -->
   <xsl:template match="*[@key='rel']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='rel'] | *[@key='links']/*[@key='rel'] | array[@key='links']/*/*[@key='rel'] | map[@key='links']/*/*[@key='rel']"
                 mode="as-attribute">
      <xsl:attribute name="rel">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @media-type *** -->
   <xsl:template match="*[@key='media-type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='media-type'] | *[@key='links']/*[@key='media-type'] | array[@key='links']/*/*[@key='media-type'] | map[@key='links']/*/*[@key='media-type'] | *[@key='rlink']/*[@key='media-type'] | *[@key='rlinks']/*[@key='media-type'] | array[@key='rlinks']/*/*[@key='media-type'] | map[@key='rlinks']/*/*[@key='media-type'] | *[@key='base64']/*[@key='media-type'] | *[@key='attachments']/*[@key='media-type'] | array[@key='attachments']/*/*[@key='media-type'] | map[@key='attachments']/*/*[@key='media-type']"
                 mode="as-attribute">
      <xsl:attribute name="media-type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "party-name" *** -->
   <!--*[@key='party-name']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='party-name']" priority="5" mode="json2xml">
      <xsl:element name="party-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "short-name" *** -->
   <!--*[@key='short-name']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='short-name']" priority="5" mode="json2xml">
      <xsl:element name="short-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "address" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='address'] | array[@key='addresses']/* | map[@key='addresses']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="address" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('addr-line', 'postal-address')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('city')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('state')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('postal-code')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('country')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "addr-line" *** -->
   <!--*[@key='addr-line'] | *[@key='postal-address']  | *[@key='postal-address']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='addr-line'] | *[@key='postal-address']  | *[@key='postal-address']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="addr-line" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'postal-address']/array[@key = 'STRVALUE'] | array[@key = 'postal-address']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="postal-address">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'postal-address']/array[@key = 'STRVALUE']/string | array[@key = 'postal-address']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "city" *** -->
   <!--*[@key='city']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='city']" priority="5" mode="json2xml">
      <xsl:element name="city" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "state" *** -->
   <!--*[@key='state']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='state']" priority="5" mode="json2xml">
      <xsl:element name="state" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "postal-code" *** -->
   <!--*[@key='postal-code']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='postal-code']" priority="5" mode="json2xml">
      <xsl:element name="postal-code" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "country" *** -->
   <!--*[@key='country']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='country']" priority="5" mode="json2xml">
      <xsl:element name="country" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "email" *** -->
   <!--*[@key='email'] | *[@key='email-addresses']  | *[@key='email-addresses']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='email'] | *[@key='email-addresses']  | *[@key='email-addresses']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="email" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'email-addresses']/array[@key = 'STRVALUE'] | array[@key = 'email-addresses']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="email-addresses">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'email-addresses']/array[@key = 'STRVALUE']/string | array[@key = 'email-addresses']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "phone" *** -->
   <!--*[@key='phone'] | *[@key='telephone-numbers']  | *[@key='telephone-numbers']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='phone'] | *[@key='telephone-numbers']  | *[@key='telephone-numbers']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="phone" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='number']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='phone'] | *[@key='telephone-numbers']  | *[@key='telephone-numbers']/*)/string[@key='number']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='phone'] | *[@key='telephone-numbers']  | *[@key='telephone-numbers']/*)/string[@key='number']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'telephone-numbers']/array[@key = 'number'] | array[@key = 'telephone-numbers']/map/array[@key = 'number']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="telephone-numbers">
            <xsl:apply-templates mode="expand" select="array[@key = 'number']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'telephone-numbers']/array[@key = 'number']/string | array[@key = 'telephone-numbers']/map/array[@key = 'number']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'number']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="number">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "url" *** -->
   <!--*[@key='url'] | *[@key='URLs']  | *[@key='URLs']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='url'] | *[@key='URLs']  | *[@key='URLs']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="url" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'URLs']/array[@key = 'STRVALUE'] | array[@key = 'URLs']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="URLs">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'URLs']/array[@key = 'STRVALUE']/string | array[@key = 'URLs']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling field "desc" *** -->
   <!--*[@key='desc']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='desc']" priority="5" mode="json2xml">
      <xsl:element name="desc" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "text" *** -->
   <!--*[@key='text']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='text']" priority="5" mode="json2xml">
      <xsl:element name="text" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "biblio" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='biblio']" priority="4" mode="json2xml">
      <xsl:element name="biblio" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "resource" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='resource'] | array[@key='resources']/* | map[@key='resources']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="resource" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('doc-id', 'document-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('citation')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('rlink', 'rlinks')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base64', 'attachments')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "citation" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='citation']" priority="4" mode="json2xml">
      <xsl:element name="citation" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('text')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('biblio')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "hash" *** -->
   <!--*[@key='hash'] | *[@key='hashes']  | *[@key='hashes']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='hash'] | *[@key='hashes']  | *[@key='hashes']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="hash" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='value']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='hash'] | *[@key='hashes']  | *[@key='hashes']/*)/string[@key='value']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='hash'] | *[@key='hashes']  | *[@key='hashes']/*)/string[@key='value']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'hashes']/array[@key = 'value'] | array[@key = 'hashes']/map/array[@key = 'value']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="hashes">
            <xsl:apply-templates mode="expand" select="array[@key = 'value']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'hashes']/array[@key = 'value']/string | array[@key = 'hashes']/map/array[@key = 'value']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'value']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="value">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag @algorithm *** -->
   <xsl:template match="*[@key='algorithm']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='hash']/*[@key='algorithm'] | *[@key='hashes']/*[@key='algorithm'] | array[@key='hashes']/*/*[@key='algorithm'] | map[@key='hashes']/*/*[@key='algorithm']"
                 mode="as-attribute">
      <xsl:attribute name="algorithm">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "role" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='role'] | array[@key='roles']/* | map[@key='roles']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="role" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('desc')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "responsible-party" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='responsible-party'] | array[@key='responsible-parties']/* | map[@key='responsible-parties']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="responsible-party" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-uuid', 'party-uuids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('responsible-parties')]"
                 priority="5"
                 mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('responsible-parties')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('responsible-parties')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="responsible-party" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-uuid', 'party-uuids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "responsible-party/@role-id" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='responsible-party']/*[@key='role-id'] | *[@key='responsible-parties']/*[@key='role-id'] | *[@key='responsible-parties']/*/*[@key='role-id']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='responsible-party']/*[@key='role-id'] | *[@key='responsible-parties']/*[@key='role-id'] | *[@key='responsible-parties']/*/*[@key='role-id']"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @href *** -->
   <xsl:template match="*[@key='href']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='link']/*[@key='href'] | *[@key='links']/*[@key='href'] | array[@key='links']/*/*[@key='href'] | map[@key='links']/*/*[@key='href'] | *[@key='rlink']/*[@key='href'] | *[@key='rlinks']/*[@key='href'] | array[@key='rlinks']/*/*[@key='href'] | map[@key='rlinks']/*/*[@key='href'] | *[@key='import-profile']/*[@key='href']"
                 mode="as-attribute">
      <xsl:attribute name="href">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @id *** -->
   <xsl:template match="*[@key='id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='role']/*[@key='id'] | *[@key='roles']/*[@key='id'] | array[@key='roles']/*/*[@key='id'] | map[@key='roles']/*/*[@key='id']"
                 mode="as-attribute">
      <xsl:attribute name="id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @uuid *** -->
   <xsl:template match="*[@key='uuid']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='prop']/*[@key='uuid'] | *[@key='properties']/*[@key='uuid'] | array[@key='properties']/*/*[@key='uuid'] | map[@key='properties']/*/*[@key='uuid'] | *[@key='annotation']/*[@key='uuid'] | *[@key='annotations']/*[@key='uuid'] | array[@key='annotations']/*/*[@key='uuid'] | map[@key='annotations']/*/*[@key='uuid'] | *[@key='location']/*[@key='uuid'] | *[@key='locations']/*[@key='uuid'] | array[@key='locations']/*/*[@key='uuid'] | map[@key='locations']/*/*[@key='uuid'] | *[@key='party']/*[@key='uuid'] | *[@key='parties']/*[@key='uuid'] | array[@key='parties']/*/*[@key='uuid'] | map[@key='parties']/*/*[@key='uuid'] | *[@key='resource']/*[@key='uuid'] | *[@key='resources']/*[@key='uuid'] | array[@key='resources']/*/*[@key='uuid'] | map[@key='resources']/*/*[@key='uuid'] | *[@key='system-security-plan']/*[@key='uuid'] | *[@key='information-type']/*[@key='uuid'] | *[@key='information-types']/*[@key='uuid'] | array[@key='information-types']/*/*[@key='uuid'] | map[@key='information-types']/*/*[@key='uuid'] | *[@key='leveraged-authorization']/*[@key='uuid'] | *[@key='leveraged-authorizations']/*[@key='uuid'] | array[@key='leveraged-authorizations']/*/*[@key='uuid'] | map[@key='leveraged-authorizations']/*/*[@key='uuid'] | *[@key='diagram']/*[@key='uuid'] | *[@key='diagrams']/*[@key='uuid'] | array[@key='diagrams']/*/*[@key='uuid'] | map[@key='diagrams']/*/*[@key='uuid'] | *[@key='user']/*[@key='uuid'] | *[@key='users']/*[@key='uuid'] | array[@key='users']/*/*[@key='uuid'] | map[@key='users']/*/*[@key='uuid'] | *[@key='component']/*[@key='uuid'] | *[@key='components']/*[@key='uuid'] | array[@key='components']/*/*[@key='uuid'] | map[@key='components']/*/*[@key='uuid'] | *[@key='protocol']/*[@key='uuid'] | *[@key='protocols']/*[@key='uuid'] | array[@key='protocols']/*/*[@key='uuid'] | map[@key='protocols']/*/*[@key='uuid'] | *[@key='inventory-item']/*[@key='uuid'] | *[@key='inventory-items']/*[@key='uuid'] | array[@key='inventory-items']/*/*[@key='uuid'] | map[@key='inventory-items']/*/*[@key='uuid'] | *[@key='implemented-requirement']/*[@key='uuid'] | *[@key='implemented-requirements']/*[@key='uuid'] | array[@key='implemented-requirements']/*/*[@key='uuid'] | map[@key='implemented-requirements']/*/*[@key='uuid'] | *[@key='statement']/*[@key='uuid'] | *[@key='statements']/*[@key='uuid'] | array[@key='statements']/*/*[@key='uuid'] | map[@key='statements']/*/*[@key='uuid'] | *[@key='by-component']/*[@key='uuid'] | *[@key='by-components']/*[@key='uuid'] | array[@key='by-components']/*/*[@key='uuid'] | map[@key='by-components']/*/*[@key='uuid'] | *[@key='provided']/*[@key='uuid'] | *[@key='provided-group']/*[@key='uuid'] | array[@key='provided-group']/*/*[@key='uuid'] | map[@key='provided-group']/*/*[@key='uuid'] | *[@key='responsibility']/*[@key='uuid'] | *[@key='responsibilities']/*[@key='uuid'] | array[@key='responsibilities']/*/*[@key='uuid'] | map[@key='responsibilities']/*/*[@key='uuid'] | *[@key='inherited']/*[@key='uuid'] | *[@key='inherited-group']/*[@key='uuid'] | array[@key='inherited-group']/*/*[@key='uuid'] | map[@key='inherited-group']/*/*[@key='uuid'] | *[@key='satisfied']/*[@key='uuid'] | *[@key='satisfied-group']/*[@key='uuid'] | array[@key='satisfied-group']/*/*[@key='uuid'] | map[@key='satisfied-group']/*/*[@key='uuid']"
                 mode="as-attribute">
      <xsl:attribute name="uuid">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "title" *** -->
   <!--*[@key='title']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='title']" priority="5" mode="json2xml">
      <xsl:element name="title" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "base64" *** -->
   <!--*[@key='base64'] | *[@key='attachments']  | *[@key='attachments']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='base64'] | *[@key='attachments']  | *[@key='attachments']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="base64" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='value']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='base64'] | *[@key='attachments']  | *[@key='attachments']/*)/string[@key='value']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='base64'] | *[@key='attachments']  | *[@key='attachments']/*)/string[@key='value']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'attachments']/array[@key = 'value'] | array[@key = 'attachments']/map/array[@key = 'value']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="attachments">
            <xsl:apply-templates mode="expand" select="array[@key = 'value']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'attachments']/array[@key = 'value']/string | array[@key = 'attachments']/map/array[@key = 'value']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'value']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="value">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag @filename *** -->
   <xsl:template match="*[@key='filename']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='base64']/*[@key='filename'] | *[@key='attachments']/*[@key='filename'] | array[@key='attachments']/*/*[@key='filename'] | map[@key='attachments']/*/*[@key='filename']"
                 mode="as-attribute">
      <xsl:attribute name="filename">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!--*[@key='description']-->
   <xsl:template match="*[@key='description']" priority="5" mode="json2xml">
      <xsl:element name="description" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:for-each select="string[@key='description'], self::string">
            <xsl:call-template name="parse">
               <xsl:with-param name="markdown-str" select="string(.)"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!--*[@key='remarks']-->
   <xsl:template match="*[@key='remarks']" priority="5" mode="json2xml">
      <xsl:element name="remarks" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:for-each select="string[@key='remarks'], self::string">
            <xsl:call-template name="parse">
               <xsl:with-param name="markdown-str" select="string(.)"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag @component-type *** -->
   <xsl:template match="*[@key='component-type']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='component']/*[@key='component-type'] | *[@key='components']/*[@key='component-type'] | array[@key='components']/*/*[@key='component-type'] | map[@key='components']/*/*[@key='component-type']"
                 mode="as-attribute">
      <xsl:attribute name="component-type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @control-id *** -->
   <xsl:template match="*[@key='control-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='implemented-requirement']/*[@key='control-id'] | *[@key='implemented-requirements']/*[@key='control-id'] | array[@key='implemented-requirements']/*/*[@key='control-id'] | map[@key='implemented-requirements']/*/*[@key='control-id']"
                 mode="as-attribute">
      <xsl:attribute name="control-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @statement-id *** -->
   <xsl:template match="*[@key='statement-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='statement']/*[@key='statement-id'] | *[@key='statements']/*[@key='statement-id'] | array[@key='statements']/*/*[@key='statement-id'] | map[@key='statements']/*/*[@key='statement-id']"
                 mode="as-attribute">
      <xsl:attribute name="statement-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "responsible-role" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='responsible-role'] | array[@key='responsible-roles']/* | map[@key='responsible-roles']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="responsible-role" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-uuid', 'party-uuids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('responsible-roles')]"
                 priority="5"
                 mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('responsible-roles')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('responsible-roles')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="responsible-role" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-uuid', 'party-uuids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "responsible-role/@role-id" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='responsible-role']/*[@key='role-id'] | *[@key='responsible-roles']/*[@key='role-id'] | *[@key='responsible-roles']/*/*[@key='role-id']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='responsible-role']/*[@key='role-id'] | *[@key='responsible-roles']/*[@key='role-id'] | *[@key='responsible-roles']/*/*[@key='role-id']"
                 mode="as-attribute">
      <xsl:attribute name="role-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "set-parameter" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='set-parameter'] | array[@key='parameter-settings']/* | map[@key='parameter-settings']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="set-parameter" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('parameter-settings')]"
                 priority="5"
                 mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('parameter-settings')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="param-id">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('parameter-settings')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="set-parameter" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('value')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "value" *** -->
   <!--*[@key='value']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='value']" priority="5" mode="json2xml">
      <xsl:element name="value" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag @param-id *** -->
   <xsl:template match="*[@key='param-id']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='set-parameter']/*[@key='param-id'] | *[@key='parameter-settings']/*[@key='param-id'] | array[@key='parameter-settings']/*/*[@key='param-id'] | map[@key='parameter-settings']/*/*[@key='param-id']"
                 mode="as-attribute">
      <xsl:attribute name="param-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "system-security-plan" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-security-plan'] | /map[empty(@key)]"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-security-plan"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('metadata')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('import-profile')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-characteristics')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-implementation')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('control-implementation')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('back-matter')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "import-profile" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='import-profile']" priority="4" mode="json2xml">
      <xsl:element name="import-profile" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "system-characteristics" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-characteristics']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-characteristics"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-id', 'system-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-name-short')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('date-authorized')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-sensitivity-level')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-information')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-impact-level')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('authorization-boundary')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('network-architecture')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('data-flow')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "system-id" *** -->
   <!--*[@key='system-id'] | *[@key='system-ids']  | *[@key='system-ids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-id'] | *[@key='system-ids']  | *[@key='system-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="system-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='id']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template match="(*[@key='system-id'] | *[@key='system-ids']  | *[@key='system-ids']/*)/string[@key='id']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='system-id'] | *[@key='system-ids']  | *[@key='system-ids']/*)/string[@key='id']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'system-ids']/array[@key = 'id'] | array[@key = 'system-ids']/map/array[@key = 'id']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="system-ids">
            <xsl:apply-templates mode="expand" select="array[@key = 'id']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'system-ids']/array[@key = 'id']/string | array[@key = 'system-ids']/map/array[@key = 'id']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'id']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="id">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag "system-id/@identifier-type" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='system-id']/*[@key='identifier-type'] | *[@key='system-ids']/*[@key='identifier-type'] | *[@key='system-ids']/*/*[@key='identifier-type']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='system-id']/*[@key='identifier-type'] | *[@key='system-ids']/*[@key='identifier-type'] | *[@key='system-ids']/*/*[@key='identifier-type']"
                 mode="as-attribute">
      <xsl:attribute name="identifier-type">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "system-name" *** -->
   <!--*[@key='system-name']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-name']" priority="5" mode="json2xml">
      <xsl:element name="system-name" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "system-name-short" *** -->
   <!--*[@key='system-name-short']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-name-short']" priority="5" mode="json2xml">
      <xsl:element name="system-name-short" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "security-sensitivity-level" *** -->
   <!--*[@key='security-sensitivity-level']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='security-sensitivity-level']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-sensitivity-level"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "system-information" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-information']" priority="4" mode="json2xml">
      <xsl:element name="system-information" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('information-type', 'information-types')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "information-type" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='information-type'] | array[@key='information-types']/* | map[@key='information-types']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="information-type" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('information-type-id', 'information-type-ids')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('confidentiality-impact')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('integrity-impact')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('availability-impact')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "information-type-id" *** -->
   <!--*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="information-type-id"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <!--Flag 'system' is the key on an assembly or field (map) with a json-key.-->
         <xsl:attribute name="system" select="@key"/>
         <xsl:apply-templates select="string[@key='id']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="2"
                 match="(*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*)/string[@key='system']"
                 mode="as-attribute">
      <xsl:attribute name="system">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- To supervene template priority="5" matching "*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*" in the case of an object grouped
            in a map, by virtue of json-key assignments to flags on that object... -->
   <xsl:template match="map[@key=('information-type-ids')]"
                 mode="json2xml"
                 priority="6">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template match="(*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*)/string[@key='id']"
                 mode="as-attribute"/>
   <xsl:template priority="8"
                 match="(*[@key='information-type-id'] | *[@key='information-type-ids']  | *[@key='information-type-ids']/*)/string[@key='id']"
                 mode="json2xml">
      <xsl:apply-templates mode="#current"/>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'information-type-ids']/array[@key = 'id'] | array[@key = 'information-type-ids']/map/array[@key = 'id']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="information-type-ids">
            <xsl:apply-templates mode="expand" select="array[@key = 'id']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'information-type-ids']/array[@key = 'id']/string | array[@key = 'information-type-ids']/map/array[@key = 'id']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'id']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="id">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag "information-type-id/@system" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='information-type-id']/*[@key='system'] | *[@key='information-type-ids']/*[@key='system'] | *[@key='information-type-ids']/*/*[@key='system']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='information-type-id']/*[@key='system'] | *[@key='information-type-ids']/*[@key='system'] | *[@key='information-type-ids']/*/*[@key='system']"
                 mode="as-attribute">
      <xsl:attribute name="system">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "confidentiality-impact" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='confidentiality-impact']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="confidentiality-impact"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "integrity-impact" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='integrity-impact']" priority="4" mode="json2xml">
      <xsl:element name="integrity-impact" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "availability-impact" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='availability-impact']" priority="4" mode="json2xml">
      <xsl:element name="availability-impact"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('base')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('selected')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('adjustment-justification')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "base" *** -->
   <!--*[@key='base']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='base']" priority="5" mode="json2xml">
      <xsl:element name="base" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "selected" *** -->
   <!--*[@key='selected']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='selected']" priority="5" mode="json2xml">
      <xsl:element name="selected" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!--*[@key='adjustment-justification']-->
   <xsl:template match="*[@key='adjustment-justification']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="adjustment-justification"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:for-each select="string[@key='adjustment-justification'], self::string">
            <xsl:call-template name="parse">
               <xsl:with-param name="markdown-str" select="string(.)"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "security-impact-level" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='security-impact-level']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="security-impact-level"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-confidentiality')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-integrity')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('security-objective-availability')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "security-objective-confidentiality" *** -->
   <!--*[@key='security-objective-confidentiality']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='security-objective-confidentiality']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-confidentiality"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "security-objective-integrity" *** -->
   <!--*[@key='security-objective-integrity']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='security-objective-integrity']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-integrity"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "security-objective-availability" *** -->
   <!--*[@key='security-objective-availability']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='security-objective-availability']"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="security-objective-availability"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "status" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='status']" priority="4" mode="json2xml">
      <xsl:element name="status" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "status/@state" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='status']/*[@key='state']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='status']/*[@key='state']"
                 mode="as-attribute">
      <xsl:attribute name="state">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "leveraged-authorization" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='leveraged-authorization'] | array[@key='leveraged-authorizations']/* | map[@key='leveraged-authorizations']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="leveraged-authorization"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('party-uuid')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('date-authorized')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "date-authorized" *** -->
   <!--*[@key='date-authorized']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='date-authorized']" priority="5" mode="json2xml">
      <xsl:element name="date-authorized" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "authorization-boundary" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='authorization-boundary']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="authorization-boundary"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('diagram', 'diagrams')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "diagram" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='diagram'] | array[@key='diagrams']/* | map[@key='diagrams']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="diagram" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('caption')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('diagrams')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('diagrams')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('diagrams')]/map" priority="3" mode="json2xml">
      <xsl:element name="diagram" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('caption')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "caption" *** -->
   <!--*[@key='caption']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='caption']" priority="5" mode="json2xml">
      <xsl:element name="caption" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "network-architecture" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='network-architecture']" priority="4" mode="json2xml">
      <xsl:element name="network-architecture"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('diagram', 'diagrams')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "data-flow" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='data-flow']" priority="4" mode="json2xml">
      <xsl:element name="data-flow" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('diagram', 'diagrams')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "system-implementation" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-implementation']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="system-implementation"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('leveraged-authorization', 'leveraged-authorizations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('user', 'users')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('component', 'components')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('system-inventory')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "user" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='user'] | array[@key='users']/* | map[@key='users']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="user" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role-id', 'role-ids')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authorized-privilege', 'authorized-privileges')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('users')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2" match="map[@key=('users')]/*/@key" mode="as-attribute">
      <xsl:attribute name="uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('users')]/map" priority="3" mode="json2xml">
      <xsl:element name="user" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('short-name')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('role-id', 'role-ids')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('authorized-privilege', 'authorized-privileges')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "role-id" *** -->
   <!--*[@key='role-id'] | *[@key='role-ids']  | *[@key='role-ids']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='role-id'] | *[@key='role-ids']  | *[@key='role-ids']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="role-id" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'role-ids']/array[@key = 'STRVALUE'] | array[@key = 'role-ids']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="role-ids">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'role-ids']/array[@key = 'STRVALUE']/string | array[@key = 'role-ids']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling assembly "authorized-privilege" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='authorized-privilege'] | array[@key='authorized-privileges']/* | map[@key='authorized-privileges']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="authorized-privilege"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('function-performed', 'functions-performed')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "function-performed" *** -->
   <!--*[@key='function-performed'] | *[@key='functions-performed']  | *[@key='functions-performed']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='function-performed'] | *[@key='functions-performed']  | *[@key='functions-performed']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="function-performed" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'functions-performed']/array[@key = 'STRVALUE'] | array[@key = 'functions-performed']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="functions-performed">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'functions-performed']/array[@key = 'STRVALUE']/string | array[@key = 'functions-performed']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling assembly "component" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='component'] | array[@key='components']/* | map[@key='components']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="component" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('purpose')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('protocol', 'protocols')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('components')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('components')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('components')]/map" priority="3" mode="json2xml">
      <xsl:element name="component" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('purpose')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('status')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('protocol', 'protocols')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "protocol" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='protocol'] | array[@key='protocols']/* | map[@key='protocols']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="protocol" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('title')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('port-range', 'port-ranges')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling field "port-range" *** -->
   <!--*[@key='port-range'] | *[@key='port-ranges']  | *[@key='port-ranges']/*-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='port-range'] | *[@key='port-ranges']  | *[@key='port-ranges']/*"
                 priority="5"
                 mode="json2xml">
      <xsl:element name="port-range" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:apply-templates select="string[@key='STRVALUE']" mode="json2xml"/>
         <xsl:for-each select="self::string | self::boolean | self::number">
            <xsl:apply-templates mode="json2xml"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template priority="3"
                 mode="json2xml"
                 match="map[@key = 'port-ranges']/array[@key = 'STRVALUE'] | array[@key = 'port-ranges']/map/array[@key = 'STRVALUE']">
      <xsl:variable name="expanded" as="element()*">
         <array xmlns="http://www.w3.org/2005/xpath-functions" key="port-ranges">
            <xsl:apply-templates mode="expand" select="array[@key = 'STRVALUE']/string"/>
         </array>
      </xsl:variable>
      <xsl:apply-templates select="$expanded" mode="json2xml"/>
   </xsl:template>
   <xsl:template mode="expand"
                 match="map[@key = 'port-ranges']/array[@key = 'STRVALUE']/string | array[@key = 'port-ranges']/map/array[@key = 'STRVALUE']/string">
      <xsl:variable name="me" select="."/>
      <xsl:for-each select="parent::array/parent::map">
         <xsl:copy>
            <xsl:copy-of select="* except array[@key = 'STRVALUE']"/>
            <string xmlns="http://www.w3.org/2005/xpath-functions" key="STRVALUE">
               <xsl:value-of select="$me"/>
            </string>
         </xsl:copy>
      </xsl:for-each>
   </xsl:template>
   <!-- *** Handling flag "port-range/@start" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='port-range']/*[@key='start'] | *[@key='port-ranges']/*[@key='start'] | *[@key='port-ranges']/*/*[@key='start']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='port-range']/*[@key='start'] | *[@key='port-ranges']/*[@key='start'] | *[@key='port-ranges']/*/*[@key='start']"
                 mode="as-attribute">
      <xsl:attribute name="start">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag "port-range/@end" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='port-range']/*[@key='end'] | *[@key='port-ranges']/*[@key='end'] | *[@key='port-ranges']/*/*[@key='end']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='port-range']/*[@key='end'] | *[@key='port-ranges']/*[@key='end'] | *[@key='port-ranges']/*/*[@key='end']"
                 mode="as-attribute">
      <xsl:attribute name="end">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag "port-range/@transport" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='port-range']/*[@key='transport'] | *[@key='port-ranges']/*[@key='transport'] | *[@key='port-ranges']/*/*[@key='transport']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='port-range']/*[@key='transport'] | *[@key='port-ranges']/*[@key='transport'] | *[@key='port-ranges']/*/*[@key='transport']"
                 mode="as-attribute">
      <xsl:attribute name="transport">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling field "purpose" *** -->
   <!--*[@key='purpose']-->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='purpose']" priority="5" mode="json2xml">
      <xsl:element name="purpose" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="*" mode="as-attribute"/>
         <xsl:for-each select="string[@key='RICHTEXT'], self::string">
            <xsl:variable name="markup">
               <xsl:apply-templates mode="infer-inlines"/>
            </xsl:variable>
            <xsl:apply-templates mode="cast-ns" select="$markup"/>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "system-inventory" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='system-inventory']" priority="4" mode="json2xml">
      <xsl:element name="system-inventory" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('inventory-item', 'inventory-items')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "inventory-item" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='inventory-item'] | array[@key='inventory-items']/* | map[@key='inventory-items']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="inventory-item" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('implemented-component', 'implemented-components')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('inventory-items')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('inventory-items')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('inventory-items')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="inventory-item" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('implemented-component', 'implemented-components')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "inventory-item/@asset-id" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='inventory-item']/*[@key='asset-id'] | *[@key='inventory-items']/*[@key='asset-id'] | *[@key='inventory-items']/*/*[@key='asset-id']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='inventory-item']/*[@key='asset-id'] | *[@key='inventory-items']/*[@key='asset-id'] | *[@key='inventory-items']/*/*[@key='asset-id']"
                 mode="as-attribute">
      <xsl:attribute name="asset-id">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "implemented-component" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='implemented-component'] | array[@key='implemented-components']/* | map[@key='implemented-components']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="implemented-component"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('implemented-components')]"
                 priority="5"
                 mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('implemented-components')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="component-uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('implemented-components')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="implemented-component"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-party', 'responsible-parties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "implemented-component/@component-uuid" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='implemented-component']/*[@key='component-uuid'] | *[@key='implemented-components']/*[@key='component-uuid'] | *[@key='implemented-components']/*/*[@key='component-uuid']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='implemented-component']/*[@key='component-uuid'] | *[@key='implemented-components']/*[@key='component-uuid'] | *[@key='implemented-components']/*/*[@key='component-uuid']"
                 mode="as-attribute">
      <xsl:attribute name="component-uuid">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag "implemented-component/@use" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='implemented-component']/*[@key='use'] | *[@key='implemented-components']/*[@key='use'] | *[@key='implemented-components']/*/*[@key='use']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='implemented-component']/*[@key='use'] | *[@key='implemented-components']/*[@key='use'] | *[@key='implemented-components']/*/*[@key='use']"
                 mode="as-attribute">
      <xsl:attribute name="use">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "control-implementation" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='control-implementation']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="control-implementation"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('implemented-requirement', 'implemented-requirements')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "implemented-requirement" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='implemented-requirement'] | array[@key='implemented-requirements']/* | map[@key='implemented-requirements']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="implemented-requirement"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('by-component', 'by-components')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('set-parameter', 'parameter-settings')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('statement', 'statements')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "statement" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='statement'] | array[@key='statements']/* | map[@key='statements']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="statement" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('by-component', 'by-components')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('statements')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('statements')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="statement-id">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('statements')]/map" priority="3" mode="json2xml">
      <xsl:element name="statement" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('by-component', 'by-components')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "by-component" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='by-component'] | array[@key='by-components']/* | map[@key='by-components']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="by-component" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('export')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('inherited', 'inherited-group')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('satisfied', 'satisfied-group')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('set-parameter', 'parameter-settings')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="map[@key=('by-components')]" priority="5" mode="json2xml">
      <xsl:apply-templates mode="json2xml"/>
   </xsl:template>
   <xsl:template priority="2"
                 match="map[@key=('by-components')]/*/@key"
                 mode="as-attribute">
      <xsl:attribute name="component-uuid">
         <xsl:value-of select="."/>
      </xsl:attribute>
   </xsl:template>
   <xsl:template match="map[@key=('by-components')]/map"
                 priority="3"
                 mode="json2xml">
      <xsl:element name="by-component" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates select="@key" mode="as-attribute"/>
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('export')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('inherited', 'inherited-group')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('satisfied', 'satisfied-group')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('set-parameter', 'parameter-settings')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag "by-component/@component-uuid" *** -->
   <!-- suppressing when matched in json2xml traversal-->
   <xsl:template match="*[@key='by-component']/*[@key='component-uuid'] | *[@key='by-components']/*[@key='component-uuid'] | *[@key='by-components']/*/*[@key='component-uuid']"
                 priority="7"
                 mode="json2xml"/>
   <xsl:template priority="3"
                 match="*[@key='by-component']/*[@key='component-uuid'] | *[@key='by-components']/*[@key='component-uuid'] | *[@key='by-components']/*/*[@key='component-uuid']"
                 mode="as-attribute">
      <xsl:attribute name="component-uuid">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling assembly "export" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='export']" priority="4" mode="json2xml">
      <xsl:element name="export" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('provided', 'provided-group')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('responsibility', 'responsibilities')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "provided" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='provided'] | array[@key='provided-group']/* | map[@key='provided-group']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="provided" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "responsibility" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='responsibility'] | array[@key='responsibilities']/* | map[@key='responsibilities']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="responsibility" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "inherited" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='inherited'] | array[@key='inherited-group']/* | map[@key='inherited-group']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="inherited" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling assembly "satisfied" *** -->
   <!-- *** NB - template matching 'array' overrides this one *** -->
   <xsl:template match="*[@key='satisfied'] | array[@key='satisfied-group']/* | map[@key='satisfied-group']"
                 priority="4"
                 mode="json2xml">
      <xsl:element name="satisfied" namespace="http://csrc.nist.gov/ns/oscal/1.0">
         <xsl:apply-templates mode="as-attribute"/>
         <xsl:apply-templates mode="#current" select="*[@key=('description')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('prop', 'properties')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('annotation', 'annotations')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('link', 'links')]"/>
         <xsl:apply-templates mode="#current"
                              select="*[@key=('responsible-role', 'responsible-roles')]"/>
         <xsl:apply-templates mode="#current" select="*[@key=('remarks')]"/>
      </xsl:element>
   </xsl:template>
   <!-- *** Handling flag @provided-uuid *** -->
   <xsl:template match="*[@key='provided-uuid']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='responsibility']/*[@key='provided-uuid'] | *[@key='responsibilities']/*[@key='provided-uuid'] | array[@key='responsibilities']/*/*[@key='provided-uuid'] | map[@key='responsibilities']/*/*[@key='provided-uuid'] | *[@key='inherited']/*[@key='provided-uuid'] | *[@key='inherited-group']/*[@key='provided-uuid'] | array[@key='inherited-group']/*/*[@key='provided-uuid'] | map[@key='inherited-group']/*/*[@key='provided-uuid']"
                 mode="as-attribute">
      <xsl:attribute name="provided-uuid">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- *** Handling flag @responsibility-uuid *** -->
   <xsl:template match="*[@key='responsibility-uuid']" priority="6" mode="json2xml"/>
   <xsl:template priority="2"
                 match="*[@key='satisfied']/*[@key='responsibility-uuid'] | *[@key='satisfied-group']/*[@key='responsibility-uuid'] | array[@key='satisfied-group']/*/*[@key='responsibility-uuid'] | map[@key='satisfied-group']/*/*[@key='responsibility-uuid']"
                 mode="as-attribute">
      <xsl:attribute name="responsibility-uuid">
         <xsl:apply-templates mode="#current"/>
      </xsl:attribute>
   </xsl:template>
   <!-- 00000000000000000000000000000000000000000000000000000000000000 -->
   <!-- Markdown converter-->
   <xsl:output indent="yes"/>
   <xsl:template name="parse"><!-- First, group according to ``` delimiters btw codeblocks and not
        within codeblock, escape & and < (only)
        within not-codeblock split lines at \n\s*\n
        
        --><!-- $str may be passed in, or we can process the current node -->
      <xsl:param name="markdown-str" as="xs:string" required="yes"/>
      <xsl:variable name="str" select="string($markdown-str) =&gt; replace('\\n','&#xA;')"/>
      <xsl:variable name="starts-with-code" select="matches($str,'^```')"/>
      <!-- Blocks is split between code blocks and everything else -->
      <xsl:variable name="blocks">
         <xsl:for-each-group select="tokenize($str, '\n')"
                             group-starting-with=".[matches(., '^```')]">
            <xsl:variable name="this-is-code"
                          select="not((position() mod 2) + number($starts-with-code))"/>
            <m:p><!-- Adding an attribute flag when this is a code block, code='code' -->
               <xsl:if test="$this-is-code">
                  <xsl:variable name="language"
                                expand-text="true"
                                select="(replace(.,'^```','') ! normalize-space(.))[matches(.,'\S')]"/>
                  <xsl:attribute name="code" select="if ($language) then $language else 'code'"/>
               </xsl:if>
               <xsl:value-of select="string-join(current-group()[not(matches(., '^```'))],'&#xA;')"/>
            </m:p>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="rough-blocks">
         <xsl:apply-templates select="$blocks" mode="parse-block"/>
      </xsl:variable>
      <xsl:variable name="flat-structures">
         <xsl:apply-templates select="$rough-blocks" mode="mark-structures"/>
      </xsl:variable>
      <!-- for debugging <xsl:copy-of select="$flat-structures"/>-->
      <xsl:variable name="nested-structures">
         <xsl:apply-templates select="$flat-structures" mode="build-structures"/>
      </xsl:variable>
      <!-- for debugging <xsl:copy-of select="$nested-structures"/>-->
      <xsl:variable name="fully-marked">
         <xsl:apply-templates select="$nested-structures" mode="infer-inlines"/>
      </xsl:variable>
      <xsl:apply-templates select="$fully-marked" mode="cast-ns"/>
   </xsl:template>
   <xsl:template match="*" mode="copy mark-structures build-structures infer-inlines">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template mode="parse-block"
                 priority="1"
                 match="m:p[exists(@code)]"
                 expand-text="true">
      <xsl:element name="m:pre" namespace="{ $target-ns }">
         <xsl:element name="code" namespace="{ $target-ns }">
            <xsl:for-each select="@code[not(.='code')]">
               <xsl:attribute name="class">language-{.}</xsl:attribute>
            </xsl:for-each>
            <xsl:value-of select="string(.)"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="parse-block" match="m:p" expand-text="true">
      <xsl:for-each select="tokenize(string(.),'\n\s*\n')[normalize-space(.)]">
         <m:p>
            <xsl:value-of select="replace(.,'^\s*\n','')"/>
         </m:p>
      </xsl:for-each>
   </xsl:template>
   <xsl:function name="m:is-table-row-demarcator" as="xs:boolean">
      <xsl:param name="line" as="xs:string"/>
      <xsl:sequence select="matches($line,'^[\|\-:\s]+$')"/>
   </xsl:function>
   <xsl:function name="m:is-table" as="xs:boolean">
      <xsl:param name="line" as="element(m:p)"/>
      <xsl:variable name="lines" select="tokenize($line,'\s*\n')[matches(.,'\S')]"/>
      <xsl:sequence select="(every $l in $lines satisfies matches($l,'^\|')) and (some $l in $lines satisfies m:is-table-row-demarcator($l))"/>
   </xsl:function>
   <xsl:template mode="mark-structures" priority="5" match="m:p[m:is-table(.)]">
      <xsl:variable name="rows">
         <xsl:for-each select="tokenize(string(.),'\s*\n')">
            <m:tr>
               <xsl:value-of select="."/>
            </m:tr>
         </xsl:for-each>
      </xsl:variable>
      <m:table>
         <xsl:apply-templates select="$rows/m:tr" mode="make-row"/>
      </m:table>
   </xsl:template>
   <xsl:template match="m:tr[m:is-table-row-demarcator(string(.))]"
                 priority="5"
                 mode="make-row"/>
   <xsl:template match="m:tr" mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:td>
               <xsl:value-of select="."/>
            </m:td>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template match="m:tr[some $f in (following-sibling::tr) satisfies m:is-table-row-demarcator(string($f))]"
                 mode="make-row">
      <m:tr>
         <xsl:for-each select="tokenize(string(.), '\s*\|\s*')[not(position() = (1,last())) ]">
            <m:th>
               <xsl:value-of select="."/>
            </m:th>
         </xsl:for-each>
      </m:tr>
   </xsl:template>
   <xsl:template mode="mark-structures" match="m:p[matches(.,'^#')]"><!-- 's' flag is dot-matches-all, so \n does not impede -->
      <m:p header-level="{ replace(.,'[^#].*$','','s') ! string-length(.) }">
         <xsl:value-of select="replace(.,'^#+\s*','') ! replace(.,'\s+$','')"/>
      </m:p>
   </xsl:template>
   <xsl:variable name="li-regex" as="xs:string">^\s*(\*|\d+\.)\s</xsl:variable>
   <xsl:template mode="mark-structures" match="m:p[matches(.,$li-regex)]">
      <m:list>
         <xsl:for-each-group group-starting-with=".[matches(.,$li-regex)]"
                             select="tokenize(., '\n')">
            <m:li level="{ replace(.,'\S.*$','') ! floor(string-length(.) div 2)}"
                  type="{ if (matches(.,'\s*\d')) then 'ol' else 'ul' }">
               <xsl:for-each select="current-group()[normalize-space(.)]">
                  <xsl:if test="not(position() eq 1)">
                     <m:br/>
                  </xsl:if>
                  <xsl:value-of select="replace(., $li-regex, '')"/>
               </xsl:for-each>
            </m:li>
         </xsl:for-each-group>
      </m:list>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:p[@header-level]">
      <xsl:variable name="level" select="(@header-level[6 &gt;= .],6)[1]"/>
      <xsl:element name="m:h{$level}"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>
   <xsl:template mode="build-structures" match="m:list" name="nest-lists"><!-- Starting at level 0 and grouping  --><!--        -->
      <xsl:param name="level" select="0"/>
      <xsl:param name="group" select="m:li"/>
      <xsl:variable name="this-type" select="$group[1]/@type"/>
      <!--first, splitting ul from ol groups -->
      <!--<xsl:for-each-group select="$group" group-starting-with="*[@level = $level and not(@type = preceding-sibling::*[1]/@type)]">-->
      <!--<xsl:for-each-group select="$group" group-starting-with="*[@level = $level]">-->
      <xsl:element name="m:{ $group[1]/@type }"
                   namespace="http://csrc.nist.gov/ns/oscal/1.0/md-convertor">
         <xsl:for-each-group select="$group"
                             group-starting-with="m:li[(@level = $level) or not(@type = preceding-sibling::*[1]/@type)]">
            <xsl:choose>
               <xsl:when test="@level = $level (: checking first item in group :)">
                  <m:li><!--<xsl:copy-of select="@level"/>-->
                     <xsl:apply-templates mode="copy"/>
                     <xsl:if test="current-group()/@level &gt; $level (: go deeper? :)">
                        <xsl:call-template name="nest-lists">
                           <xsl:with-param name="level" select="$level + 1"/>
                           <xsl:with-param name="group" select="current-group()[@level &gt; $level]"/>
                        </xsl:call-template>
                     </xsl:if>
                  </m:li>
               </xsl:when>
               <xsl:otherwise><!-- fallback for skipping levels -->
                  <m:li><!-- level="{$level}"-->
                     <xsl:call-template name="nest-lists">
                        <xsl:with-param name="level" select="$level + 1"/>
                        <xsl:with-param name="group" select="current-group()"/>
                     </xsl:call-template>
                  </m:li>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each-group>
      </xsl:element>
      <!--</xsl:for-each-group>-->
   </xsl:template>
   <xsl:template match="m:pre//text()" mode="infer-inlines">
      <xsl:copy-of select="."/>
   </xsl:template>
   <xsl:template match="text()" mode="infer-inlines">
      <xsl:variable name="markup">
         <xsl:apply-templates select="$tag-replacements/m:rules">
            <xsl:with-param name="original" tunnel="yes" as="text()" select="."/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:try select="parse-xml-fragment($markup)">
         <xsl:catch select="."/>
      </xsl:try>
   </xsl:template>
   <xsl:template mode="cast-ns" match="*">
      <xsl:element name="{local-name()}" namespace="{ $target-ns }">
         <xsl:copy-of select="@*[matches(.,'\S')]"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="m:rules" as="xs:string"><!-- Original is only provided for processing text nodes -->
      <xsl:param name="original" as="text()?" tunnel="yes"/>
      <xsl:param name="starting" as="xs:string" select="string($original)"/>
      <xsl:iterate select="*">
         <xsl:param name="original" select="$original" as="text()?"/>
         <xsl:param name="str" select="$starting" as="xs:string"/>
         <xsl:on-completion select="$str"/>
         <xsl:next-iteration>
            <xsl:with-param name="str">
               <xsl:apply-templates select=".">
                  <xsl:with-param name="str" select="$str"/>
               </xsl:apply-templates>
            </xsl:with-param>
         </xsl:next-iteration>
      </xsl:iterate>
   </xsl:template>
   <xsl:template match="m:replace" expand-text="true">
      <xsl:param name="str" as="xs:string"/>
      <!--<xsl:value-of>replace({$str},{@match},{string(.)})</xsl:value-of>-->
      <!-- 's' sets dot-matches-all       -->
      <xsl:sequence select="replace($str, @match, string(.),'s')"/>
      <!--<xsl:copy-of select="."/>-->
   </xsl:template>
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-replacements">
      <rules><!-- first, literal replacements -->
         <replace match="&amp;">&amp;amp;</replace>
         <replace match="&lt;">&amp;lt;</replace>
         <!-- next, explicit escape sequences -->
         <replace match="\\&#34;">&amp;quot;</replace>
         <!--<replace match="\\&#39;">&amp;apos;</replace>-->
         <replace match="\\\*">&amp;#x2A;</replace>
         <replace match="\\`">&amp;#x60;</replace>
         <replace match="\\~">&amp;#x7E;</replace>
         <replace match="\\^">&amp;#x5E;</replace>
         <!-- then, replacements based on $tag-specification -->
         <xsl:for-each select="$tag-specification/*">
            <xsl:variable name="match-expr">
               <xsl:apply-templates select="." mode="write-match"/>
            </xsl:variable>
            <xsl:variable name="repl-expr">
               <xsl:apply-templates select="." mode="write-replace"/>
            </xsl:variable>
            <replace match="{$match-expr}">
               <xsl:sequence select="$repl-expr"/>
            </replace>
         </xsl:for-each>
      </rules>
   </xsl:variable>
   <xsl:variable xmlns="http://csrc.nist.gov/ns/oscal/1.0/md-convertor"
                 name="tag-specification"
                 as="element(m:tag-spec)">
      <tag-spec><!-- The XML notation represents the substitution by showing both delimiters and tags  --><!-- Note that text contents are regex notation for matching so * must be \* -->
         <q>"<text/>"</q>
         <img alt="!\[{{$noclosebracket}}\]" src="\({{$nocloseparen}}\)"/>
         <insert param-id="\{{\{{{{$nws}}\}}\}}"/>
         <a href="\[{{$nocloseparen}}\]">\(<text not="\)"/>\)</a>
         <code>`<text/>`</code>
         <strong>
            <em>\*\*\*<text/>\*\*\*</em>
         </strong>
         <strong>\*\*<text/>\*\*</strong>
         <em>\*<text/>\*</em>
         <sub>~<text/>~</sub>
         <sup>\^<text/>\^</sup>
      </tag-spec>
   </xsl:variable>
   <xsl:template match="*" mode="write-replace"><!-- we can write an open/close pair even for an empty element b/c
             it will be parsed and serialized -->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <!-- coercing the order to ensure correct formation of regegex       -->
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:apply-templates mode="#current" select="*"/>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>&gt;</xsl:text>
   </xsl:template>
   <xsl:template match="*" mode="write-match">
      <xsl:apply-templates select="@*, node()" mode="write-match"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$text\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$text\}', '(.*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nocloseparen\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$nocloseparen\}', '([^\\(]*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$noclosebracket\}')]" mode="write-match">
      <xsl:value-of select="replace(., '\{\$noclosebracket\}', '([^\\[]*)?')"/>
   </xsl:template>
   <xsl:template match="@*[matches(., '\{\$nws\}')]" mode="write-match"><!--<xsl:value-of select="."/>--><!--<xsl:value-of select="replace(., '\{\$nws\}', '(\S*)?')"/>-->
      <xsl:value-of select="replace(., '\{\$nws\}', '\\s*(\\S+)?\\s*')"/>
   </xsl:template>
   <xsl:template match="m:text" mode="write-replace">
      <xsl:text>$1</xsl:text>
   </xsl:template>
   <xsl:template match="m:insert/@param-id" mode="write-replace">
      <xsl:text> param-id='$1'</xsl:text>
   </xsl:template>
   <xsl:template match="m:a/@href" mode="write-replace">
      <xsl:text> href='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@alt" mode="write-replace">
      <xsl:text> alt='$1'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:img/@src" mode="write-replace">
      <xsl:text> src='$2'</xsl:text>
      <!--<xsl:value-of select="replace(.,'\{\$insert\}','\$2')"/>-->
   </xsl:template>
   <xsl:template match="m:text" mode="write-match">
      <xsl:text>(.*?)</xsl:text>
   </xsl:template>
   <xsl:template match="m:text[@not]" mode="write-match">
      <xsl:text expand-text="true">([^{ @not }]*?)</xsl:text>
   </xsl:template>
   <xsl:variable name="line-example" xml:space="preserve"> { insertion } </xsl:variable>
</xsl:stylesheet>
