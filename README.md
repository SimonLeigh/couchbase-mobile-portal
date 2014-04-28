Couchbase Mobile Developer Portal
=================================

Create/Edit Content
-------------------
- Clone this repo
- Create/Edit content under `couchbase-mobile-portal/docs/src`
- For new content, add reference to doc in site-map in `couchbase-mobile-portal/site/src/site.xml`
- To view, generate site using the process below

Generate Site
-------------
- Clone this repo
- Navigate to the site generator directory:  `cd couchbase-mobile-portal/site/gtor`
- Execute the site generator:  `./gen`
  - NOTE: This is uses saxon, which is Java, so you will need a JRE installed.
- Navigate to the generated site:  `cd ../gen`
- Open one of the generated html files (e.g. search.html)
