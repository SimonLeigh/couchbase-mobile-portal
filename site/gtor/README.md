Generate Hippo-Ingest HTML
--------------------------
- Clone this repo
- Checkout branch `hippo-ingest`
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

Todo
----

[ ] Add primary and secondary navgation items to the `<ul class="developer-portal-sidebar-navigation">` element. Currently these reside outside of the `<nav>` container.
[ ] Add `<keyword>` tags to each doc page. This will be written into the html as the `<meta name="keywords">` tag contents. This can either be "grandfathered in", or done programatically with a default set common to each page, then customized later. Additionally, the search index stylesheet might provide good starting values given a sufficient list of stop words.
[ ] Update stylesheet processing to generate a root index.html containing all pages to be ingested. Reference example looks like:
```html
<html>
  <head>
    <title>Couchbase Server Documentation</title>
  </head>
  <body>
    <h1>Couchbase Server Documentation</h1>
    <nav>
      <ul>
        <li>Couchbase concepts and architecture
          <ul>
            <li>
              <a href="admin/server-concepts.html">Key concepts</a>
              <ul>
                <li>
                  <a href="admin/server-concepts/big-data-challenges.html">Big data challenges</a>
                </li>
                <li>
                  <a href="admin/server-concepts/why-couchbase.html">Why Couchbase?</a>
                </li>
                <li>
                  <a href="admin/server-concepts/big-picture.html">The big picture</a>
                  <ul>
                    <li>
                      <a href="admin/server-concepts/cb-server.html">Couchbase server</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/cb-clients.html">Couchbase clients</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/cb-mobile.html">Couchbase mobile</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/server-concepts/dist-data-mgmt.html">Distributed data management</a>
                  <ul>
                    <li>
                      <a href="admin/server-concepts/data-replication.html">Data replication</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/data-manager.html">Data manager</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/cluster-manager.html">Cluster manager</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/server-concepts/doc-data-model.html">Data model</a>
                  <ul>
                    <li>
                      <a href="admin/server-concepts/data-modeling.html">JSON documents</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/doc-dynamic-schema.html">Dynamic schema</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/doc-design-considerations.html">Design considerations</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/query-index-model.html">Data queries</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/server-concepts/sql-for-docs.html">SQL for Documents</a>
                  <ul>
                    <li>
                      <a href="admin/server-concepts/querying.html">SQL for Documents queries</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/indexing.html">SQL for Documents indexes</a>
                    </li>
                    <li>
                      <a href="admin/server-concepts/crud-operations.html">SQL for Documents CRUD operations</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/server-concepts/operations.html">Database operations</a>
                </li>
              </ul>
            </li>
            <li>
              <a href="admin/Concepts/architecture.html">Architecture</a>
              <ul>
                <li>
                  <a href="admin/Concepts/couchbase-services.html">Couchbase services</a>
                </li>
                <li>
                  <a href="admin/Concepts/concepts-MDS.html">Multi-Dimensional Scaling (MDS)</a>
                </li>
              </ul>
            </li>
            <li>Data modeling</li>
            <li>Data access</li>
            <li>
              <a href="indexes/query-intro.html">Views and indexes</a>
              <ul>
                <li>
                  <a href="views/views-intro.html">Views</a>
                  <ul>
                    <li>
                      <a href="views/views-basics.html">View concepts</a>
                      <ul>
                        <li>
                          <a href="views/views-streaming.html">Stream-based views</a>
                        </li>
                        <li>
                          <a href="views/views-operation.html">Views operations</a>
                        </li>
                        <li>
                          <a href="views/views-storedData.html">Views and stored data</a>
                        </li>
                        <li>
                          <a href="views/views-development.html">Development views</a>
                        </li>
                        <li>
                          <a href="views/views-production.html">Production views</a>
                        </li>
                      </ul>
                    </li>
                    <li>
                      <a href="views/views-mapreduce-intro.html">MapReduce views</a>
                      <ul>
                        <li>
                          <a href="views/views-writing.html">Writing MapReduce views</a>
                          <ul>
                            <li>
                              <a href="views/views-writing-views.html">Views best practices</a>
                            </li>
                            <li>
                              <a href="views/views-writing-map.html">Map function</a>
                            </li>
                            <li>
                              <a href="views/views-writing-reduce.html">Reduce function</a>
                            </li>
                            <li>
                              <a href="views/views-writing-utility.html">Built-in utility functions</a>
                            </li>
                            <li>
                              <a href="views/views-writing-count.html">Built-in _count function</a>
                            </li>
                            <li>
                              <a href="views/views-writing-sum.html">Built-in _sum function</a>
                            </li>
                            <li>
                              <a href="views/views-writing-stats.html">Built-in _stats function</a>
                            </li>
                            <li>
                              <a href="views/views-writing-rewriting.html">Re-writing built-in functions</a>
                            </li>
                            <li>
                              <a href="views/views-writing-custom-reduce.html">Custom reduce functions</a>
                            </li>
                            <li>
                              <a href="views/views-writing-rereduce.html">Re-reduce arguments</a>
                            </li>
                            <li>
                              <a href="views/views-writing-nonjson.html">Views on non-JSON</a>
                            </li>
                            <li>
                              <a href="views/views-translateSQL.html">Translating SQL to MapReduce</a>
                            </li>
                            <li>
                              <a href="views/views-schemaless.html">Views in a schema-less database</a>
                            </li>
                          </ul>
                        </li>
                        <li>
                          <a href="views/views-querying.html">Querying MapReduce views</a>
                          <ul>
                            <li>
                              <a href="views/views-querySample.html">View and query examples</a>
                            </li>
                          </ul>
                        </li>
                      </ul>
                    </li>
                    <li>
                      <a href="views/spatial-views.html">Spatial views</a>
                      <ul>
                        <li>
                          <a href="views/sv-writing-views.html">Writing spatial views</a>
                          <ul>
                            <li>
                              <a href="views/sv-writing-views-functions.html">Writing spatial view functions</a>
                            </li>
                            <li>
                              <a href="views/sv-writing-views-keys.html">Keys in spatial view functions</a>
                            </li>
                          </ul>
                        </li>
                        <li>
                          <a href="views/sv-query-parameters.html">Querying spatial views</a>
                          <ul>
                            <li>
                              <a href="views/sv-queries-open-range.html">Open range queries</a>
                            </li>
                            <li>
                              <a href="views/sv-queries-closed-range.html">Closed range queries</a>
                            </li>
                            <li>
                              <a href="views/sv-queries-bbox.html">Bounding box queries</a>
                            </li>
                          </ul>
                        </li>
                        <li>
                          <a href="views/sv-example1.html">Example: GeoJSON polygons</a>
                          <ul>
                            <li>
                              <a href="views/sv-ex1-create.html">Creating a spatial view function</a>
                            </li>
                            <li>
                              <a href="views/sv-ex1-query-all.html">Querying all data</a>
                            </li>
                            <li>
                              <a href="views/sv-ex1-query-east.html">Querying on the east</a>
                            </li>
                            <li>
                              <a href="views/sv-ex1-query-area.html">Querying on the area</a>
                            </li>
                            <li>
                              <a href="views/sv-ex1-query-nonintersect.html">Querying on non-intersect</a>
                            </li>
                          </ul>
                        </li>
                        <li>
                          <a href="views/sv-example2.html">Example: non-geographic</a>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="indexes/index-intro.html">Indexes</a>
                  <ul>
                    <li>
                      <a href="indexes/index-arch.html">Index service architecture</a>
                    </li>
                    <li>
                      <a href="indexes/index-manage.html">Managing indexes</a>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
            <li>High availability and disaster recovery (HA/DR)</li>
            <li>
              <a href="admin/security/security-intro.html">Security in Couchbase </a>
              <ul>
                <li>
                  <a href="admin/security/security-watsnew.html">What's new in the current version</a>
                </li>
                <li>
                  <a href="admin/security/security-authentication.html">Authentication </a>
                  <ul>
                    <li>
                      <a href="admin/security/security-CB-admins.html">Authentication for administrators using passwords</a>
                    </li>
                    <li>
                      <a href="admin/security/security-buckets.html">Authentication for applications</a>
                    </li>
                    <li>
                      <a href="admin/security/security-LDAP.html">LDAP authentication</a>
                      <ul>
                        <li>
                          <a href="admin/security/security-LDAP-setup.html">Configuring LDAP on the server</a>
                        </li>
                        <li>
                          <a href="admin/security/security-LDAP-UI.html">Configuring LDAP administrators</a>
                        </li>
                        <li>
                          <a href="admin/security/security-saslauthd.html">Setting up saslauthd</a>
                        </li>
                        <li>
                          <a href="admin/security/security-LDAP-tbls.html">Troubleshooting LDAP settings</a>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/security/security-authorisation.html">Authorization</a>
                  <ul>
                    <li>
                      <a href="admin/security/security-author-admins.html">Authorization for administrators</a>
                      <ul>
                        <li>
                          <a href="admin/security/security-author-fulladmin.html">Authorization for full administrators</a>
                        </li>
                        <li>
                          <a href="admin/security/security-author-readonly.html">Authorization for read-only administrators</a>
                        </li>
                      </ul>
                    </li>
                    <li>
                      <a href="admin/security/security-author-apps.html">Authorization for applications</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/security/security-auditing.html">Auditing for Couchbase administrators</a>
                  <ul>
                    <li>
                      <a href="admin/security/security-audit-events.html">Audit events</a>
                    </li>
                    <li>
                      <a href="admin/security/security-audit-targets.html">Audit targets</a>
                      <ul>
                        <li>
                          <a href="admin/security/security-JSON-fields.html">Audit file details</a>
                        </li>
                        <li>
                          <a href="admin/security/security-audit-guarantee.html">Audit guarantee</a>
                        </li>
                      </ul>
                    </li>
                    <li>
                      <a href="admin/security/security-conf-auditing.html">Configuring auditing</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/security/security-encryption.html">Encryption</a>
                  <ul>
                    <li>
                      <a href="admin/security/security-data-encryption.html">Encryption at rest</a>
                    </li>
                    <li>
                      <a href="admin/security/security-comm-encryption.html">Encryption on the wire</a>
                      <ul>
                        <li>
                          <a href="admin/security/security-admin-access.html">Secure administrative access</a>
                        </li>
                        <li>
                          <a href="admin/security/security-client-ssl.html">Secure data access</a>
                        </li>
                      </ul>
                    </li>
                    <li>
                      <a href="admin/security/security-in-applications.html">Encryption in applications</a>
                    </li>
                  </ul>
                </li>
                <li>
                  <a href="admin/security/security-best-practices.html">Security best practices</a>
                  <ul>
                    <li>
                      <a href="admin/security/security-passwords.html">Couchbase passwords</a>
                    </li>
                    <li>
                      <a href="admin/security/security-bucket-protection.html">Bucket protection</a>
                    </li>
                    <li>
                      <a href="admin/security/security-access-logs.html">Access logs</a>
                    </li>
                    <li>
                      <a href="admin/security/security-iptables.html">IP tables and ports</a>
                    </li>
                    <li>
                      <a href="admin/security/security-config-cache.html">Client configuration cache</a>
                    </li>
                    <li>
                      <a href="admin/security/security-user-input.html">NoSQL injection</a>
                    </li>
                    <li>
                      <a href="admin/security/security-ACLs.html">Network ACLs and security groups</a>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
          </ul>
        </li>
      </ul>
    </nav>
  </body>
</html>
```