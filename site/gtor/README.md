Generate Hippo-Ingest HTML
--------------------------
- Navigate to the site generator directory:  `cd couchbase-mobile-portal/site/gtor`
- Execute the site generator:  `./gen-hippo`
  - NOTE: This is uses saxon, which is Java, so you will need a JRE installed.
- Navigate to the generated site:  `cd ../gen-hippo`
- Open one of the generated html files (e.g. index.html)

Notes
-----

The `gen-hippo` shell script will apply the `hippo.xslt` stylesheet,which is
an inartfully hacked up version of `html.xslt`, to the xml found
in the `docs` folder. If you want the traditional rendered HTML site, use `gen`.

Landing pages now live outside this repo and in the HIPPO CMS directly.

Todo
----
 * [X] **Add primary and secondary navigation items** to the `<ul class="developer-portal-sidebar-navigation">` element. Currently these reside outside of the `<nav>` container.
 * [ ] [Optional] **Add `<keyword>` tags to each doc page**. This will be written into the html as the `<meta name="keywords">` tag contents. This can either be "grandfathered in", or done programatically with a default set common to each page, then customized later. Additionally, the search index stylesheet might provide good starting values given a sufficient list of stop words.