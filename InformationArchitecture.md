Mobile Information Architecture
===============================

Format:  ENTITY_NAME\<CHILD_TYPES>, * = required, [...] = array+bounds

Guides
------
- guide
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - articles\<article>[1-n]
- article
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - topics\<topic>[1-n]
- topic\<content>
  - id\<string> *
  - title\<string> *

"Guides" DITA
-------------
- IDs: \<task id>, \<concept id>, \<topic id>, /<topic id> all with w/ xml:lang
- \<title>
- \<shortdesc>
- \<prereqs
- Body: \<conbody>, \<taskbody>, \<body> (topic) 
- \<related-links>



Training
--------
- class
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - dependencies\<simple-content>[0-n]
  - lessons\<lesson>[1-n]
- lesson
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - tasks\<task>[1-n]
- task\<content>
  - id\<string> *
  - title\<string> *

Training DITA:
--------------
- \<learningAssessment id=>  \<learningAssessmentbody>  \<learningPostAssessmentRef>
- \<learningContent id=>     \<learningContentbody>     \<learningContentRef>
- \<learningOverview id=>    \<learningOverviewbody>    \<learningOverviewRef>
- \<learningPlan id=>        \<learningPlanbody>        \<learningPlanRef>
- \<learningSummary id=>     \<learningSummarybody>     \<learningSummaryRef>
- \<title>
- \<shortdesc>
- \<lcIntro>
- \<lcAudience>
- \<lcObjective>
- \<lcDuration>
- \<lcInteraction>
- \<lsTrueFalse id=>
- \<lcAsset>
- \<lcAnswerOption> <lcAnswerOptionGroup>
- \<lcReview>
- \<lcResources>
- \<task id>
- \<taskbody>



Sets
----
- set
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - items\<set | class | guide | page>[1-n]

Sets DITA
---------
- DITA MAP
  - task, concept, and topic IDs
  - title
  - shortdesc
  - taskbody, conceptbody, body
  - \<related-links>



Linking
-------
- link
  - target-id\<string> *
- external-link
  - target\<string> *

Linking DITA
-------------
- EXTERNAL and Internal: \<related-links> \<link ref=""> <linktext>
- INTERNAL: Cross-references are also stored in the relationship table of the ditamap.

Content
-------
- simple-content\<link | external-link | emphasis | strong>[1-n]
- content\<link | external-link | emphasis | strong | paragraph | ordered-list | unordered-list | description-list | image | figure | note | section | subsection | table | code | code-set>[1-n]
- emphasis\<string>
- strong\<string>
- paragraph\<string>
- ordered-list\<list-item>[1-n]
- unordered-list\<list-item>[1-n]
- list-item\<simple-content>
- description-list\<description-list-item>[1-n]
- description-list-item
  - title\<simple-content> *
  - description\<content> *
- image
  - source\<string> *
  - description\<string> *
  - width\<string>
  - height\<string>
- figure
  - image\<image> *
  - caption\<simple-content>
  - importance\<string>(primary | secondary | tertiary) *
- note\<content-type>
  - type\<string>(note | tip | caution) *
- section\<content-type>
  - id\<string> *
  - title\<string> *
- subsection\<content-type>
  - title\<string> *
- table
  - header\<cell>[0-n]
  - rows\<row>[1-n] 
- row\<cell>[1-n]
- cell\<content>
  - colspan\<int>
  - rowspan\<int>
- code\<string>
- code-set\<code>[1-n]
  - language\<string> *



Content DITA:
------------
- Emphasis: \<i>
- Bold: \<b>
- Paragraph: \<p>
- Ordered lists: \<ol>
- Un-ordered lists:
  -  \<ul> and 
  -  \<dl> (definition lists: term with definition)
-  \<li> (for unordered and order lists)
- Simple list: \<sl> \<sli> (simple lists: short phrases w/o bullets)
- Definition list: \<dl> \<dlentry> \<dt> \<dd>  
- Parameter list: \<parml> \<plentry> \<pt> \<pd>
- Notes: \<note type=" tip, note, important, warning, caution, attention, remember, etc ">
- Images: \<image placement align width height href> \<alt>
- Figures: \<fig> \<title> \<desc> \<image placement align width height href> <alt>
- Tables:
  - \<table frame="" id=""> \<title> \<tgroup cols=""> 
  - \<colspec colname="c1" colnum="1" colwidth="1*"/> \<thead> \<row> \<entry>
- Code: 
  - \<codeph> (paragragh) 
  - \<codeblock outputclass=""> (code block with language processing)
  - \<coderef> (code sample that are external but imported during processing)
- Sections: \<section id=""> \<title> (title is optional)
- Sub-sections: No sub-sections. Individual files can be children topics of parent topics.
  - Grouping of topics are done through the dita map.


Entity
------
- entity
  - name<string> *
- ctor
  - entity-name<string> *
  - name<string> *
- property
  - entity-name<string> *
  - name<string> *
- method
  - entity-name<string> *
  - name<string> *


Entity DITA
-----------
- Include and Exclude
```
<prop att="product" val="impress" action="flag">
<startflag imageref="delta_olive.gif">
<alt-text>Start of product - Impress</alt-text>
</startflag> </prop> 
```

```
action="include_or_exclude_or_passthrough"

```








