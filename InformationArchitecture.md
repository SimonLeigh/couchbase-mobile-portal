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

DITA
  - IDs: task id, concept id, topic id, reference id all with w/ xml:lang
  - <title>
  - <shortdesc>
  - Body: <conbody>, <taskbody>, <body> (topic) 




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

DITA:
  <learningAssessment id=>  <learningAssessmentbody>  <learningPostAssessmentRef>
  <learningContent id=>     <learningContentbody>     <learningContentRef>
  <learningOverview id=>    <learningOverviewbody>    <learningOverviewRef>
  <learningPlan id=>        <learningPlanbody>        <learningPlanRef>
  <learningSummary id=>     <learningSummarybody>     <learningSummaryRef>

  <title>
  <shortdesc>
  <lcIntro>
  <lcAudience>
  <lcObjective>
  <lcDuration>
  <lcInteraction>
  <lsTrueFalse id=>
  <lcAsset>
  <lcAnswerOption> <lcAnswerOptionGroup>
  <lcReview>
  <lcResources>
  
  <task id>
  <taskbody>



Sets
----
- set
  - id\<string> *
  - title\<string> *
  - description\<string> *
  - introduction\<content> *
  - related\<simple-content>[0-n]
  - items\<set | class | guide | page>[1-n]

Linking
-------
- link
  - target-id\<string> *
- external-link
  - target\<string> *

DITA: EXTERNAL/Internal: <related-links> <link ref=""> <linktext>
      INTERNAL: Cross-references are also stored in the relationship table of the ditamap.

Content
-------
- simple-content\<link | external-link | emphasis | strong>[1-n]
- content\<link | external-link | emphasis | strong | paragraph | ordered-list | unordered-list | description-list | image | figure | note | section | subsection | table | code | code-set>[1-n]
- emphasis\<string>
-     DITA: <i>
- strong\<string>
-      DITA: <b>
- paragraph\<string>
-     DITA: <p>
- ordered-list\<list-item>[1-n]
-     DITA: <ol>
- unordered-list\<list-item>[1-n]
-     DITA: <ul> and 
-     DITA: <dl> (definition lists: term with definition)
-     DITA: <li> (for unordered and order lists)
- list-item\<simple-content>
-     DITA: <sl> <sli>(simple lists: short phrases w/o bullets)

- description-list\<description-list-item>[1-n]
- description-list-item
  - title\<simple-content> *
  - description\<content> *
      DITA: Definition list: <dl> <dlentry> <dt> <dd>  
      DITA: Parameter list: <parml> <plentry> <pt> <pd>


- image
  - source\<string> *
  - description\<string> *
  - width\<string>
  - height\<string>
      DITA: <image placement align width height href> <alt>
        

- figure
  - image\<image> *
  - caption\<simple-content>
  - importance\<string>(primary | secondary | tertiary) *
      DITA: <fig> <title> <desc> <image placement align width height href> <alt>


- note\<content-type>
  - type\<string>(note | tip | caution) *
      DITA: <note type=" tip, note, important, warning, caution, attention, remember, etc ">


- section\<content-type>
  - id\<string> *
  - title\<string> *
      DITA: <section id=""><title> (title is optional)


- subsection\<content-type>
  - title\<string> *
      DITA: no sub-sections. Individual files can be children topics of parent topics.
            Grouping of topics are done through the dita map.


- table
  - header\<cell>[0-n]
  - rows\<row>[1-n] 
- row\<cell>[1-n]
- cell\<content>
  - colspan\<int>
  - rowspan\<int>
      DITA: <table frame="" id=""> <title> <tgroup cols=""> 
            <colspec colname="c1" colnum="1" colwidth="1*"/> <thead> <row> <entry>



- code\<string>
- code-set\<code>[1-n]
  - language\<string> *
      DITA: <codeph> (paragragh) 
            <codeblock outputclass=""> (code block with language processing)
            <coderef> (code sample that are external but imported during processing)


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
