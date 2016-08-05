---
id: running-sync-gateway
title: Running Sync Gateway
permalink: ready/guides/sync-gateway/running-sync-gateway/index.html
---

A step by step look at installing, connecting, starting and stopping operations for the Sync Gateway.

You can run Sync Gateway on the following operating systems:

- Red Hat Linux
- Ubuntu Linux
- Mac OS X 10.6 or later with a 64-bit CPU
- Windows 8 or later

## Installing Sync Gateway

You can download Sync Gateway for your platform from [our website](http://www.couchbase.com/download#cb-mobile) , or alternatively build it directly from source from our [GitHub repository](http://github.com/couchbase/sync_gateway). The download contains an executable file called **sync_gateway** that you run as a command-line tool. For convenience, you can move it to a directory that is included in your $PATH environment variable.

## Connecting Sync Gateway to Couchbase Server

After you have installed Sync Gateway, you can optionally connect it to a Couchbase Server instance. By default, Sync Gateway uses a built-in, in-memory server called "Walrus" that can withstand most prototyping use cases, extending support to at most one or two users.

To connect Sync Gateway to Couchbase Server:

- Open the Couchbase Server Admin Console and log on using your administrator credentials.
- In the toolbar, click **Data Buckets**.
- On the Data Buckets page, click **Create New Data Bucket** and create a bucket named `sync_gateway` in the default pool.

See the latest Sync Gateway Release Notes for version compatibility information, available on the [Downloads](http://www.couchbase.com/nosql-databases/downloads#Couchbase_Mobile) page.

> **Note:** You can use any name you want for your bucket, but `sync_gateway` is the default name that Sync Gateway uses if you do not specify a bucket name when you start Sync Gateway. If you use a different name for your bucket, you need to specify the name in the configuration file or via the command-line option `-bucket`.

### Accessing and modifying Sync Gateway's bucket

Sync Gateway is similar to an application server in that it considers itself the owner of its bucket, and stores data in the bucket using its own schema. Even though the documents in the bucket are normal JSON documents, Sync Gateway adds and maintains its own metadata to them to track their sync status and revision history.

> **Note:** Do not add, modify or remove data in the bucket using Couchbase APIs or the admin UI, or you will confuse Sync Gateway. To modify documents, we recommend you use the Sync Gateway's REST API. If you need to operate on the bucket using Couchbase Server APIs, use the Bucket Shadowing feature to create a separate bucket you can modify, which the Sync Gateway will "shadow" with its own bucket.

## Starting and stopping Sync Gateway

Learn how to start and stop Sync Gateway.

### Starting Sync Gateway

You start Sync Gateway by running the executable file `sync_gateway`:

```bash
$ ./sync_gateway
```

In the command above, neither a configuration file nor command-line options were specified. In this case, default values are used. The command above starts a Sync Gateway instance and connects to the built-in, in-memory database Walrus. Sync Gateway listens on port 4984 for Public REST API commands, and listens on port 4985 for Admin REST API commands.

You can specify a configuration file, a JSON file that contains Sync Gateway configuration properties. The following command starts Sync Gateway using the config file `config.json`:

```bash
$ ./sync_gateway config.json
```

For information about the configuration file, see the article Configuration using a configuration file.

You can use command-line options to specify a subset of configuration properties. If you only need limited customization, you can start Sync Gateway with command-line options, **instead of** using a configuration file. The following command starts Sync Gateway and specifies the address of a Couchbase Server instance (instead of using the default database server, which is Walrus):

```bash
$ ./sync_gateway -url http://cbserver:8091
```

For information about command-line options, see the article Configuration using command-line options.

If you are running Sync Gateway as a service it can be started with the following command:

```bash
sudo service sync_gateway start
```

### Stopping Sync Gateway

You can stop Sync Gateway by typing Control-C. There is no specific shutdown procedure and it is safe to stop Sync Gateway at any time.

If you are running Sync Gateway as a service it can be stopped with the following command:

```bash
sudo service sync_gateway stop
```