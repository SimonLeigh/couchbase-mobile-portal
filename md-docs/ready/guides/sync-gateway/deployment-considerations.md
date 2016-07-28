---
id: deployment-considerations
title: Deployment considerations
permalink: ready/guides/sync-gateway/deployment/index.html
---

In this guide we'll cover deploying Sync Gateway in the two major phases of your application development: during development, and in production.

## During Development

When it comes to initial prototyping with a sync-enabled app, there are a number of choices at your disposal to get ramped up quickly with Sync Gateway. Depending on your resources and needs, here are our recommendations of how to best proceed with prototyping using Sync Gateway.

### Using Walrus

[Walrus](https://github.com/couchbaselabs/walrus), which is built into Sync Gateway, is a simple, limited, in-memory database that you can use in place of Couchbase Server for unit testing during development.

Use the following command to start a Sync Gateway that connects to a single Walrus database called `sync_gateway` and listens on the default ports:

```bash
sync_gateway -url walrus:
```

To use a different database name, use the `-bucket` option. For example:

```bash
sync_gateway -url walrus: -bucket mydb
```

By default, Walrus does not persist data to disk. However, you can make your database persistent by specifying an existing directory to which Sync Gateway can periodically save its state. It saves the data to a file named `/<directory>/sync_gateway.walrus`. For example, the following command instructs Sync Gateway to save the data in a file named `/data/sync_gateway.walrus`.

```bash
mkdir /data
sync_gateway -url walrus:/data
```

You can use a relative path when specifying the directory for persistent data storage.

```bash
mkdir data
sync_gateway -url walrus:data
```

You can also specify the directory for persistent data storage in a configuration file. The **config.json** file would look similar to the following JSON fragment:

```bash
{
  "databases": {
    "couchchat": {
      "server": "walrus:data"         
      ...
    }
    ...
  }
  ...
}
```

Our own engineering team utilizes Walrus in place of a Couchbase Server installation to conveniently and quickly gain feedback during unit testing. Based on our experience, it is best to start with Walrus when developing with the Couchbase Mobile stack for the first time, but there are caveats to this prototyping model. In particular, the number of clients that Walrus can comfortably support generally is no more than one or two clients. For those doing advanced prototyping with larger datasets or more clients, we recommend using a true Couchbase Server database.

### Using Couchbase Server

Couchbase Server is our document-oriented NoSQL backend that serves as the major endpoint for most Couchbase Lite use cases. Using Couchbase Server during prototyping is especially useful when using multi-gig datasets, or to realistically model the relationship between Couchbase Server and a pilot-sized deployment of Couchbase Lite clients. It's free to download, easy to setup and can be easily hosted on the same development machine as your Sync Gateway. You can learn more about Couchbase Server [here](http://www.couchbase.com/nosql-databases/couchbase-server).

#### Where to Develop

We recommend in early development the best and most convenient setup is to host your Sync Gateway and/or Couchbase Server instances on your application developer environment, such as your laptop or desktop. We provide support for Red Hat, Windows, Mac and Ubuntu for both of these server applications. We are also working with a number of cloud partners to be able to provide pre-packaged hosting options on all the most popular development platforms. As a frame of reference, the minimum requirements for either one of these is dual-core/4GB RAM. If you choose to use both during development, you will need at least a quad-core machine.

| Couchbase Server | Sync Gateway |
|:-----------------|:-------------|
|Dual-core/4GB RAM|	Dual-core/4GB RAM|

## In Production

When deploying your application for production use you will need to use Sync Gateway and Couchbase Server. This article covers different aspects of using Sync Gateway and Couchbase Server during production.

### Where to Host

Whether hosting on-premise, or in the cloud, you will want to have your Sync Gateway and Couchbase Server sit closely to each other for optimal performance between these two systems. They can share the same physical machine as long their recommended supported hardware requirements are met:

| Couchbase Server | Sync Gateway |
|:-----------------|:-------------|
|Quad-core/16GB RAM|Quad-core/4GB RAM|

### Sizing and Scaling

Your physical hardware determines how many active, concurrent users you can comfortably support for a single Sync Gateway. A quad-core/4GB RAM backed Sync Gateway can support up to 5k users. Larger boxes, such as a eight-core/8GB RAM backed Sync Gateway, can support 10k users, and so forth.

Alternatively, instead of scaling vertically, you can also scale horizontally by running Sync Gateway nodes as a cluster. (In general, you will want to have at least two Sync Gateway nodes to ensure high-availability in case one should fail.) This means running an identically configured instance of Sync Gateway on each of several machines, and load-balancing them by directing each incoming HTTP request to a random node. Sync Gateway nodes are “shared-nothing,” so they don’t need to coordinate any state or even know about each other. Everything they know is contained in the central Couchbase Server bucket. All Sync Gateway nodes talk to the same Couchbase Server bucket. This can, of course, be hosted by a cluster of Couchbase Server nodes. Sync Gateway uses the standard Couchbase “smart-client” APIs and works with database clusters of any size.

With multiple Sync Gateways, we recommend placing this cluster behind a load-balancer server to coordinate connection requests in clients. A popular load-balancer we've been recommended by our own community is [Nginx](https://www.nginx.com/blog/websocket-nginx/).

### Performance Considerations

Keep in mind the following notes on performance:

- Sync Gateway nodes don’t keep any local state, so they don’t require any disk.
- Sync Gateway nodes do not cache much in RAM. Every request is handled independently. The Sync Gateway is written with the Go programming language, which does use garbage collection, so the memory usage might be somewhat higher than for C code. However, memory usage shouldn’t be excessive, provided the number of simultaneous requests per node is kept limited.
- Go is good at multiprocessing. It uses lightweight threads and asynchronous I/O. Adding more CPU cores to a Sync Gateway node can speed it up.
- As is typical with databases, writes are going to put a greater load on the system than reads. In particular, replication and channels imply that there’s a lot of fan-out, where making a change triggers sending notifications to many other clients, who then perform reads to get the new data.

In addition to adding Sync Gateway nodes, we recommend developers to also optimize how many connections they need to open to the sync tier. Very large-scale deployments might run into challenges managing large numbers of simultaneous open TCP connections. The replication protocol uses a “hanging-GET” technique to enable the server to push change notifications. This means that an active client running a continuous pull replication always has an open TCP connection on the server. This is similar to other applications that use server-push, also known as “Comet” techniques, as well as protocols like XMPP and IMAP. These sockets remain idle most of the time (unless documents are being modified at a very high rate), so the actual data traffic is low—the issue is just managing that many sockets. This is commonly known as the “C10k Problem” and it’s been pretty well analyzed in the last few years. Because Go uses asynchronous I/O, it’s capable of listening on large numbers of sockets provided that you make sure the OS is tuned accordingly and you’ve got enough network interfaces to provide a sufficiently large namespace of TCP port numbers per node.

### Transport Layer Security (HTTPS)

To secure data between clients and Sync Gateway in production, you will probably want to use secure HTTPS connections.

You can run Sync Gateway behind a reverse proxy, such as [Nginx](https://www.nginx.com/blog/websocket-nginx/) (can also be used to load balance a sync\_gateway cluster; see above), which supports HTTPS connections and route internal traffic to sync_gateway over HTTP. The advantage of this approach is that nginx can proxy both HTTP and HTTPS connections to a single Sync Gateway instance.

Alternatively sync\_gateway can be configured to only allow secure HTTPS connections, if you want to support both HTTP and HTTPS connections you will need to run two separate instances of sync_gateway.

To enable HTTPS add the following top-level properties to your config.json file:

```javascript
{
  "SSLCert": "pathto/ssl/cert.pem",
  "SSLKey":  "pathto/ssl/privkey.pem"
}
```

For production you should get a cert from a reputable Certificate Authority, which will be signed by that authority.

For testing you may want to create your own self-signed certificate, it's pretty easy using the openssl command-line tool and these directions, you just need to run these commands:

```bash
openssl genrsa -out privkey.pem 2048
openssl req -new -x509 -key privkey.pem -out cert.pem -days 1095
```

The second command is interactive and will ask you for information like country and city name that goes into the X.509 certificate. You can put whatever you want there; the only important part is the field Common Name (e.g. server FQDN or YOUR name) which needs to be the exact hostname that clients will reach your server at. The client will verify that this name matches the hostname in the URL it's trying to access, and will reject the connection if it doesn't.

You should now have two files: privkey.pem: the private key. This needs to be kept secure -- anyone who has this data can impersonate your server. cert.pem: the public certificate. You'll want to embed a copy of this in an application that connects to your server, so it can verify that it's actually connecting to your server and not some other server that also has a cert with the same hostname. The SSL client API you're using should have a function to either register a trusted 'root certificate', or to check whether two certificates have the same key. Then just add the "SSLCert" and "SSLKey" properties to your Sync Gateway configuration file, as shown up above.

The sync_gateway GitHub repository contains a pre-configured self-cert configuration in [examples/ssl](https://github.com/couchbase/sync_gateway/tree/master/examples/ssl/).

### Log Rotation

In production environments it is common to rotate log files to prevent them from taking too much disk space, and to support log file archival.

By default Sync gateway will write log statements to stderr, normally stderr is redirected to a log file by starting Sync Gateway with a command similar to the following:

```bash
sync_gateway sync_gateway.json 2>> sg_error.log
```

On linux the logrotate tool can be used to monitor log files and rotate them at fixed time intervals or when they reach a certain size. Below is an example of a logrotate configuration that will rotate the Sync Gateway log file once a day or if it reaches 10M in size.

```
/home/sync_gateway/logs/* { 
    daily 
    rotate 1 
    size 10M  
    delaycompress 
    compress 
    notifempty 
    missingok
```

The log rotation is achieved by renaming the log file with an appended timestamp. The idea is that Sync Gateway should recreate the default log file and start writing to it again. The problem is Sync Gateway will follow the renamed file and keep writing to it until Sync gateway is restarted. By adding the copy truncate option to the logrotate configuration, the log file will be rotated by making a copy of the log file, and then truncating the original log file to zero bytes.

```
/home/sync_gateway/logs/* { 
    daily 
    rotate 1 
    size 10M
    copytruncate
    delaycompress 
    compress 
    notifempty 
    missingok 
}
```

Using this approach there is a possibility of loosing log entries between the copy and the truncate, on a busy Sync Gateway instance or when verbose logging is configured the number of lost entries could be large.

In Sync Gateway 1.1.0 a new configuration option has been added that gives Sync Gateway control over the log file rather than relying on **stderr**. To use this option call Sync Gateway as follows:

```bash
sync_gateway -logFilePath=sg_error.log sync_gateway.json
```

[//]: # "TODO: Link can break."
The **logFilePath** property can also be set in the configuration file at the [server level](../configuring-sync-gateway/config-properties/index.html#server-configuration).

If the option is not used then Sync Gateway uses the existing stderr logging behaviour. When the option is passed Sync Gateway will attempt to open and write to a log file at the path provided. If a Sync Gateway process is sent the SIGHUP signal it will close the open log file and then reopen it, on linux the SIGHUP signal can be manually sent using the following command:

```bash
pkill -HUP sync_gateway
```

This command can be added to the logrotate configuration using the 'postrotate' option:

```
/home/sync_gateway/logs/* { 
    daily 
    rotate 1 
    size 10M
    delaycompress 
    compress 
    notifempty 
    missingok
    postrotate
        /usr/bin/pkill -HUP sync_gateway > /dev/null
    endscript
}
```

After renaming the log file logrotate will send the SIGHUP signal to the sync_gateway process, Sync Gateway will close the existing log file and open a new file at the original path, no log entries will be lost.

## Troubleshooting

### Troubleshooting and Fine-Tuning

In general, [curl](https://curl.haxx.se/), a command-line HTTP client, is your friend. You might also want to try [httpie](https://github.com/jkbrzt/httpie), a human-friendly command-line HTTP client. By using these tools, you can inspect databases and documents via the Public REST API, and look at user and role access privileges via the Admin REST API.

An additional useful tool is the admin-port URL **/databasename/_dump/channels**, which returns an HTML table that lists all active channels and the documents assigned to them. Similarly,**/databasename/_dump/access** shows which documents are granting access to which users and channels.

We encourage Sync Gateway users to also reach back out to our engineering team and growing developer community for help and guidance. You can get in touch with us on our mailing list at our [Couchbase Mobile forum](https://forums.couchbase.com/c/mobile).

### How to file a bug

If you're pretty sure you've found a bug, please [file a bug report](https://github.com/couchbase/sync_gateway/issues?q=is%3Aopen) at our GitHub repository and we can follow-up accordingly.

## Enterprise Customer Support

### Couchbase Technical Support

Support email: support@couchbase.com

Support phone number: +1-650-417-7500, option #1

Support portal: [http://support.couchbase.com](http://support.couchbase.com)

To speed up the resolution of your issue, we will need some information to troubleshoot what is going on. The more information you can provide in the questions below the faster we will be able to identify your issue and propose a fix:

- Priority and impact of the issue (P1 and production impacting versus a P2 question)
- What versions of the software are you running - Membase/Couchbase Server, moxi, and client drivers?
- Operating system version, architecture (32-bit or 64-bit) and deployment (physical hardware, Amazon EC2, RightScale, etc.)
- Number of nodes in the cluster, how much physical RAM in each node, and per-node RAM allocated to Couchbase Server
- What steps led to the failure or error?
- Information around whether this is something that has worked successfully in the past and if so what has changed in the environment since the last successful operation?
- Provide us with a current snapshot of logs taken from each node of the system and uploaded to our support system via the instructions below

If your issue is urgent, please make a phone call as well as send an e-mail. The phone call will ensure that an on-call engineer is notified.

### Sync Gateway Logs

The Sync Gateway logs will give us further detail around the issue itself and the health of your environment.

Sync Gateway 1.3.x includes a command line utility 'sgcollect\_info' that provides us with detailed statistics for a specific node. Run sgcollect_info on each node individually, not on all simultaneously.

Example usage:

Linux (run as root or use sudo as below)


```bash
sudo /opt/couchbase/bin/sgcollect_info <node_name>.zip
```

Windows (run as an administrator)

```
C:\Program Files\Couchbase\Server\bin\sgcollect_info <node_name>.zip
```

Run sgcollect_info on all nodes in the cluster, and upload all of the resulting files to us.

### Sharing Files with Us

The sg\_collect_info tool can result in large files. Simply run the command below, replacing <FILE NAME> and <YOUR COMPANY NAME>, to upload a file to our cloud storage on Amazon AWS. Make sure you include the last slash ("/") character after the company name.

```bash
curl --upload-file FILE NAME https://s3.amazonaws.com/customers.couchbase.com/<YOUR COMPANY NAME>/
```

> **Note:** we ship curl with couchbase, on linux this is located in /opt/couchbase/bin/

Firewalled Couchbase Nodes

If your Couchbase nodes do not have internet access, the best way to provide the logs to us is to copy the files then run Curl from a machine with internet access. We ship a Windows curl binary as part of Couchbase, so if you have Couchbase Server installed on a laptop or other system which has an Internet connection you can upload from there. Alternatively you can download standalone Curl for Windows:

[http://curl.haxx.se/download.html](http://curl.haxx.se/download.html)

Once uploaded, please send an e-mail to support@couchbase.com letting us know what files have been uploaded.