Couchbase Mobile Developer Portal
=================================

Clone the git repository
------------------------

Use Git to clone the Couchbase Mobile Portal repository to your local disk: 

```
git clone git@github.com:couchbaselabs/couchbase-mobile-portal.git
cd couchbase-mobile-portal
git submodule init && git submodule update
```

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

Dev Mode
--------
While making changes to the site, it's nice to be able to see the results quickly in the browser.
To reduce the time it takes to build the site, comment out the links to content you're not working on in `site/src/site.xml`.

Use a file watcher tool to build the site when a file is modified.
For example, with [filewatcher](https://github.com/thomasfl/filewatcher):
```
$ filewatcher '**/*.xml' '(cd site/gtor; bash gen)'
```