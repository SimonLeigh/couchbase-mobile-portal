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

Linking
-------
- link
  - target-id\<string> *
- external-link
  - target\<string> *

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
