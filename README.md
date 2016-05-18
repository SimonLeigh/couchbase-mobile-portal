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
- For new content, add reference to doc in site-map in `couchbase-mobile-portal/site/src/site-hippo.xml`
- To view, generate site using the process below

Getting Started
---------------
- Clone this repo
- Navigate to the site generator directory:  `cd couchbase-mobile-portal/site/gtor`

**NOTE:** The site generation uses saxon, which is Java, so you will need a JRE installed.

Generate Site for Hippo
-----------------------

```
$ cd site/gtor
$ ./gen-hippo
```

Generated output at `site/gen-hippo`.

Generate Site for Preview
-------------------------

```
$ cd site/gtor
$ ./gen-preview
```

Generated output at `site/gen-preview`.

Auto-rebuild when files changed
-------------------------------
Use a file watcher tool to build the site when a file is modified.
For example, with [filewatcher](https://github.com/thomasfl/filewatcher):
```
$ filewatcher '**/*.xml' '(cd site/gtor; bash gen-preview)'
```

Faster build times
------------------
While making changes to the site, it's nice to be able to see the results quickly in the browser.
To reduce the time it takes to build the site, comment out the links to content you're not working on in `site/src/site.xml`.

Use the ` git update-index` command to ignore changes to site.xml. That way, you can keep site.xml with the minimum 
links
to files and still commit changes to other xml files.

To ignore changes:
```
$ git update-index --assume-unchanged site/src/site-hippo.xml
```

To track changes:
```
$ git update-index --no-assume-unchanged site/src/site-hippo.xml
```

**NOTE:** Both the hippo.xslt and preview.xslt use site-hippo.xml for the site map.

Livereload
----------

Use Livereload to auto-reload the site in Chrome when the `filewatcher` is done building.

1. Download the Livereload [Chrome extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en)
2. Install the [Livereload CLI](https://www.npmjs.com/package/livereload)
3. Start Livereload:

  ```
  $ livereload site/gen-preview/
  ```
4. Start a web server:

  ```
  $ python -m SimpleHTTPServer 8000
  ```
5. Open `http://localhost:8000` in the browser and enable Livereload through the Chrome extension
![gif](http://i.gyazo.com/40c4b00380e7b372336810673a0d31d8.gif)
6. Change some .xml file, the `filewatcher` should pick up the change and Livereload automatically reload the site in
 Chrome.