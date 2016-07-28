---
id: config-properties
title: Config properties
permalink: ready/guides/sync-gateway/configuring-sync-gateway/config-properties/index.html
---

You can use a configuration file to configure Sync Gateway. Configuration determines the runtime behavior of Sync Gateway, including server configuration and the database or set of databases with which a Sync Gateway instance can interact. All configuration properties have default values.

Using a configuration file is the recommended approach for configuring Sync Gateway, because you can provide values for all configuration properties and you can define configurations for multiple Couchbase Server databases.

When specifying a configuration file, the format of the `sync_gateway` command is:

```bash
sync_gateway [configuration file]
```

The following command starts Sync Gateway with the properties specified in the configuration file `config.json`:

```bash
$ sync_gateway config.json
```

## Configuration files

A Sync Gateway configuration file is a JSON file that defines Sync Gateway's runtime behavior. When starting Sync Gateway, provide the path to the file as a command-line argument. Configuration properties are case-insensitive.

Configuration files have one syntactic feature that is not standard JSON: any text between backticks (`) is treated as a string, even if it spans multiple lines or contains double-quotes. This makes it easy to embed JavaScript code, such as the sync and filter functions.

### Example

The following sample configuration file starts a server with the default settings:

```javascript
{
  "interface": ":4984",        // Begin server configuration
  "adminInterface": ":4985",
  "log": ["REST"],
  "databases": {               // Begin database configuration
    "sync_gateway": {
    "server": "http://localhost:8091",
    "bucket": "sync_gateway",
    "sync": `function(doc) {channel(doc.channels);}`
    }
  }
}
```

### Server configuration

Configuration properties for server configuration are root-level configuration properties, for example:

```javascript
{
	"interface":":4984",        // Begin server configuration
	"adminInterface":":4985",
	"log":["REST"]
}
```

Following are configuration properties for configuration of the Sync Gateway server:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`adminInterface`|`string`|Port or TCP network address (IP address and the port) that the Admin REST API listens on. The default is `127.0.0.1:4985`.|
|`adminUI`|`string`|URL of the Sync Gateway Admin Console HTML page. The default is the bundled Sync Gateway Admin Console at `localhost:4985/_admin/`.|
|`compressResponses`|`Boolean`|Whether to compress HTTP responses. Set to `false` to disable compression of HTTP responses. The default is `true`.|
|`configServer`|`string`|URL of a Couchbase database-configuration server (for dynamic database discovery). A database-configuration server allows Sync Gateway to load a database configuration dynamically from a remote endpoint. If a database configuration server is defined, when Sync Gateway gets a request for a database that it doesn't know about, then Sync Gateway will attempt to retrieve the database configuration properties from the URL `ConfigServer/DBname`, where `DBname` is the database name. There is no default.|
|`CORS`|Array of CORS configuration properties|Configuration for allowing CORS (cross-origin resource sharing). There is no default. For more information, see CORS configuration.|
|`CouchbaseKeepaliveInterval`|`integer`|TCP keep-alive interval in seconds between Sync Gateway and Couchbase Server. There is no default.|
|`databases`|Array of database configuration properties|Database settings. See Database configuration. There is no default.|
|`facebook`|Array of Facebook configuration properties|Configuration for Facebook Login authentication. See Facebook configuration. There is no default.|
|`interface`|`string`|Port or TCP network address (IP address and the port) that the Public REST API listens on. The default is `:4984`.|
|`log`|`string`|Comma-separated list of log keys to enable for diagnostic logging. Use `["*"]` to enable logging for all log keys. See Log keys. The default is `HTTP`.|
|`logFilePath`|`string`|Absolute or relative path on the filesystem to the log file. A relative path is from the directory that contains the Sync Gateway executable file. The default is `stderr`.|
|`maxCouchbaseConnections`|`integer`|Maximum number of sockets to open to a Couchbase Server node. The default is `16`.|
|`maxCouchbaseOverflow`|`integer`|Maximum number of overflow sockets to open. The default is no maximum.|
|`maxFileDescriptors`|`integer`|Maximum number of open file descriptors (RLIMIT_NOFILE). _Not available on Windows_. The default is `5000`.|
|`maxHeartbeat`|`integer`|Maximum heartbeat value for `_changes` feed requests (in seconds). The default is no maximum.|
|`maxIncomingConnections`|`integer`|Maximum number of incoming HTTP connections to accept. The default is no maximum.|
|`persona`|Mozilla Persona configuration property|Configuration for Mozilla Persona authentication. See Mozilla Persona configuration. There is no default.|
|`pretty`|`Boolean`|Whether to pretty-print JSON responses. The default is `false`.|
|`profileInterface`|`string`|TCP network address (IP address and the port) that the Go profile API listens on. You can obtain go profiling information from the interface. You can omit the IP address. There is no default.|
|`serverReadTimeout`|`integer`|Maximum duration in seconds before timing out the read of an HTTP(S) request. The default is no timeout.|
|`serverWriteTimeout`|`integer`|Maximum duration in seconds before timing out the write of an HTTP(S) response. The default is no timeout.|
|`slowServerCallWarningThreshold`|`integer`|Log warnings if database calls made by Sync Gateway take this many milliseconds or longer. The default is _200 milliseconds_.|
|`SSLCert`|`string`|Absolute or relative path on the filesystem to the TLS certificate file, if TLS is used to secure Sync Gateway connections, or `"nil"` for plaintext. A relative path is from the directory that contains the Sync Gateway executable file. There is no default. For more information, see Transport Layer Security (HTTPS).|
|`SSLKey`|`string`|Absolute or relative path on the filesystem to the TLS private key file, if TLS is used to secure Sync Gateway connections, or `"nil"` for plaintext. A relative path is from the directory that contains the Sync Gateway executable file. There is no default.|

## Log keys

Log keys specify functional areas. Enabling logging for a log key provides additional diagnostic information for that area.

Following are descriptions of the log keys that you can specify as a comma-separated list in the `Log` property. In some cases, a log key has two forms, one with a plus sign (+) suffix and one without, for example `CRUD+` and `CRUD`. The log key with the plus sign logs more verbosely. For example for `CRUD+`, the log contains all of the messages for `CRUD` and additional ones for `CRUD+`.

**Note:** Log keys are case sensitive. Specify them as shown below.

|Log key|What is logged|
|:------|:-------------|
|`Access`|`access()` calls made by the sync function|
|`Attach`|Attachment processing|
|`Auth`|Authentication|
|`Bucket`|Sync Gateway interactions with the bucket (verbose logging).|
|`Cache` or `Cache+`|Interactions with Sync Gateway's in-memory channel cache|
|`Changes` or `Changes+`|Processing of `_changes` requests|
|`CRUD` or `CRUD+`|Updates made by Sync Gateway to documents|
|`DCP`|DCP-feed processing (verbose logging)|
|`Events` or `Events+`|Event processing (webhooks)|
|`Feed` or `Feed+`|Server-feed processing|
|`HTTP` or `HTTP+`|All requests made to the Sync Gateway REST APIs (Sync and Admin). Note that the log keyword HTTP is always enabled, which means that HTTP requests and error responses are always logged (in a non-verbose manner). HTTP+ provides more verbose HTTP logging.|

## Database configuration

The `databases` configuration property specifies one or more mappings of database names to the configuration properties for each database. The Sync and Admin REST APIs refer to the database by this name. For example:

```javascript
{
  "databases": {               // Begin database configuration
    "database1": {             // Name of this database
       "server": "http://localhost:8091",     // Configuration properties that specify
                                             // the configuration of this database
       "bucket": "bucket",
       "sync": `function(doc) {channel(doc.channels);}`
    }
  }
}
```

In the example above, `database1` is the name of the database, and the configuration properties `server`, `bucket`, and `sync` are given values.

Following are the configuration properties for a specific database:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`allow_empty_password`|`Boolean`|Whether to allow empty passwords for Couchbase Server authentication. The default is `false`.|
|`bucket`|`string`|Bucket name on Couchbase Server or a Walrus bucket. The default is the value of the property `Name`.|
|`cache`|Array of cache configuration properties|Cache settings. See Cache configuration.|
|`event_handlers`|`interface`|Event handlers (for webhooks). There is no default. For more information, see Using webhooks.|
|`feed_type`|`string`|Feed type: `DCP` or `TAP`. The default is `TAP`.|
|`offline`|`string`|Whether the database if kept offline when Sync Gateway starts. Specifying the value `true` results in the database being kept offline. The default (if the property is omitted) is to bring the database online when Sync Gateway starts. For more information, see Taking databases offline and bringing them online.|
|`password`|`string`|Bucket password for authenticating to Couchbase Server. There is no default.|
|`pool`|`string`|	Couchbase pool name. The default is the string `default`.|
|`rev_cache_size`|`integer`|Size of the revision cache, specified as the total number of document revisions to cache in memory for all recently accessed documents. When the revision cache is full, Sync Gateway removes less recent document revisions to make room for new document revisions. Adjust this property to tune memory consumption by Sync Gateway, for example on servers with less memory and in cases when Sync Gateway creates many new documents and/or updates many documents relative to the number of read operations. The default is `5000`.|
|`revs_limit`|`integer`|Maximum depth to which a document's revision tree can grow. **Note:** If you use bucket shadowing, setting revs_limit to a value that is too small relative to the frequency of document revisions can have negative consequences. Bucket shadowing needs the revision history to be maintained until pending revisions are reconciled.|
|`roles`|`Roles to create`|Array of initial roles with their properties. There is no default.|
|`server`|`string`|Couchbase Server (or Walrus) URL. The default is `walrus:`.|
|`sync`|`string`|Sync function, which defines which users can read, update, or delete which documents. The default is a default sync function. For more information, see the section Sync function API.|
|`username`|`string`|Bucket username for authenticating to Couchbase Server. There is no default.|
|`users`|Users to create|Array of initial user accounts with their properties. There is no default.|

## Authentication configuration

Following are configuration properties for authentication:

### Facebook configuration

Following is the property that you can define for the server configuration property `facebook`:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`register`|`Boolean`|Whether the Facebook Login server will register new user accounts (`true` or `false`). The default is `false`.|

For more information about Facebook authentication, see Facebook authentication.

## Mozilla Persona configuration

Following are the properties that you can define for the server configuration property `persona`:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`origin`|`string`|URL of Mozilla Persona Identity Provider (IdP) server for Persona authentication. There is no default.|
|`register`|`Boolean`|Whether the Mozilla Persona IdP server will register new user accounts (true or false). The default is `false`.|

For more information about Mozilla Persona authentication, see Mozilla Persona authentication.

## CORS configuration

Cross Origin Resource Sharing (CORS) is a browser security protocol that allows web pages to interact with resources hosted under domains other than their origin server. Read more about CORS.

Sync Gateway has server level configuration for CORS origin(s), headers, and max-age. It is also possible to use a wildcard * as the origin but wildcard matched domains won't send credentials. Don't use a wildcard if you can list the domains. The `Origin` list can include multiple entries. CORS is not enabled on the Sync Gateway admin port.

The `LoginOrigin` list protects access to the `_session` and `_facebook` endpoints.

A common use case is to sync with HTML5 apps running databases like PouchDB. It is also possible to interact directly with Sync Gateway from HTML5 applications via XHR, when CORS is configured.

Following are configuration properties that you can define for CORS:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`Origin`|`string`|Comma-separated list of allowed origins; use an asterisk (*) to allow access from everywhere. There is no default.|
|`LoginOrigin`|`string`|Comma-separated list of allowed login origins. There is no default.|
|`Headers`|`string`|Comma-separated list of allowed HTTP headers. There is no default.|
|`MaxAge`|`integer`|Value for the `Access-Control-Max-Age` header. This is the the number of seconds that the response to a CORS preflight request can be cached before sending another preflight request. There is no default.|

### Example

The following configuration file starts a server with settings you might use when developing with Sync Gateway and PouchDB on the same laptop. Be sure to match the port number to your localhost webserver port. Guest has full access in this mode so you probably want to change this before you go into production.

```javascript
{
  "log": ["HTTP+"],
  "CORS": {
    "origin":["http://localhost:8000"],
    "loginOrigin":["http://localhost:8000"],
    "headers":["Content-Type"],
    "maxAge": 1728000
  },
  "databases": {
    "db": {
      "server": "walrus:",
      "users": { "GUEST": {"disabled": false, "admin_channels": ["*"] } }
    }
  }
}
```

You can find this example with a different `log` configuration property in the Sync Gateway GitHub examples repository.

## Webhook configuration

Following are configuration properties for event handling and webhooks:

### Event handling

Following are properties that you can define for event handling:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`document_changed`|Array of event configuration properties|The `document_changed` event. There is no default. For more information, see the section Webhook event handler.|
|`max_processes`|`integer`|Maximum concurrent event handling goroutines. The default is `500`.|
|`wait_for_process`|`string`|Maximum wait time in milliseconds when the event queue is full. The default is `5`.|

### Webhook event handler

Following are properties that you can define for a `webhook` event handler:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`filter`|`string`|Filter function to determine which documents to post (for a webhook event handler). There is no default.|
|`handler`|`string`|Handler type. This must be (`webhook`). There is no default.|
|`timeout`|`integer`|Timeout in seconds (for a webhook event handler). The default is `60`.|
|`url`|`string`|URL to which to post documents (for a webhook event handler). There is no default.|

## Cache configuration

Following are configuration properties for cache configuration:

|Property|Type|Description and default|
|:-------|:---|:----------------------|
|`max_wait_pending`|`integer`|Maximum wait time in milliseconds for a pending sequence before skipping sequences. The default is `5000` (five seconds).|
|`max_num_pending`|`integer`|Maximum number of pending sequences before skipping the sequence. The default is `10000`.|
|`max_wait_skipped`|`integer`|	Maximum wait time in milliseconds for a skipped sequence before abandoning the sequence. The default is `3600000` (60 minutes).|
|`enable_star_channel`|`Boolean`|Enable the star (*) channel. The default is `true`.|
|`channel_cache_max_length`|`integer`|Maximum number of entries maintained in cache per channel. The default is 500.|
|`channel_cache_min_length`|`integer`|Minimum number of entries maintained in cache per channel. The default is 50.|
|`channel_cache_expiry`|`integer`|Time (seconds) to keep entries in cache beyond the minimum retained. The default is 60 seconds.|