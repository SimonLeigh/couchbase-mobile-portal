---
id: sg
title: Sync Gateway
permalink: ready/installation/sync-gateway/index.html
---

Install Sync Gateway on premise or on a cloud provider. You can download Sync Gateway from the [Couchbase download page](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile) or download it directly to a Linux system by using the `wget` or `curl` command.

```bash
wget http://latestbuilds.hq.couchbase.com/couchbase-sync-gateway/1.3.0/1.3.0-274/couchbase-sync-gateway-community_1.3.0-274_x86_64.deb
```

All downloads follow the naming convention:

```bash
couchbase-sync-gateway-community_<REL>-<BUILDNUM><ARCH>.deb
```

Where 

- `REL` is the release number.
- `BUILDNUM` is the specific build number of the release.
- `ARCH` is the target architecture of the installer.

## Requirements

|Ubuntu|CentOS/RedHat|Debian|Windows|macOS|
|:-----|:------------|:-----|:------|:----|
|12, 14|5, 6, 7|8|Windows 8, Windows 10, Windows Server 2012|Yosemite, El Capitan|

### Network configuration

Sync Gateway uses specific ports for communication with the outside world, mostly Couchbase Lite databases replicating to and from Sync Gateway. The following table lists the ports used for different types of Sync Gateway network communication:

|Port|Description|
|:---|:----------|
|4984|Public port. External HTTP port used for replication with Couchbase Lite databases and other applications accessing the REST API on the Internet.|
|4985|Admin port. Internal HTTP port for unrestricted access to the database and to run administrative tasks.|

Once you have downloaded Sync Gateway on the distribution of your choice you are ready to install and start it as a service.

## Ubuntu

Install sync_gateway with the dpkg package manager e.g:

```bash
dpkg -i couchbase-sync-gateway-community_1.3.0-274_x86_64.deb
```

When the installation is complete sync_gateway will be running as a service.

```bash
service sync_gateway start
service sync_gateway stop
```

The config file and logs are located in `/home/sync_gateway`.

> **Note:** You can also run the **sync_gateway** binary directly from the command line. The binary is installed at `/opt/couchbase-sync-gateway/bin/sync_gateway`.

## Red Hat/CentOS

Install sync_gateway with the rpm package manager e.g:

```bash
rpm -i couchbase-sync-gateway-community_1.3.0-274_x86_64.rpm
```

When the installation is complete sync_gateway will be running as a service.

On CentOS 5:

```bash
service sync_gateway start
service sync_gateway stop
```

On CentOS 6:

```bash
initctl start sync_gateway
initctl stop sync_gateway
```

On CentOS 7:

```bash
systemctl start sync_gateway
systemctl stop sync_gateway
```

The config file and logs are located in `/home/sync_gateway`.

## Debian

Install sync_gateway with the dpkg package manager e.g:

```bash
dpkg -i couchbase-sync-gateway-community_1.3.0-274_x86_64.deb
```

When the installation is complete sync_gateway will be running as a service.

```bash
systemctl start sync_gateway
systemctl stop sync_gateway
```

The config file and logs are located in `/home/sync_gateway`.

## Windows

Install sync_gateway on Windows by running the .exe file from the desktop.

```bash
couchbase-sync-gateway-community_1.3.0-274_x86_64.exe
```

When the installation is complete sync_gateway will be installed as a service but not running.

Use the **Control Panel --> Admin Tools --> Services** to stop/start the service.

The config file and logs are located in ``.

## macOS

Install sync_gateway by unpacking the tar.gz installer.

```bash
sudo tar --zxvf couchbase-sync-gateway-community_1.3.0-274_x86_64.tar.gz --directory /opt
```

Create the sync_gateway service.

```bash
$ cd /opt/couchbase-sync-gateway/service

$ sudo ./sync_gateway_service_install.sh
```

To restart sync_gateway (it will automatically start again).

```bash
$ sudo launchctl stop sync_gateway
```

To remove the service.

```bash
$ sudo launchctl unload /Library/LaunchDaemons/com.couchbase.mobile.sync_gateway.plist
```

The config file and logs are located in `/Users/sync_gateway`.

## Instance from AWS marketplace

1. Browse to the [Sync Gateway AMI](https://aws.amazon.com/marketplace/pp/B013XDO1B4) in the AWS Marketplace.
2. Click Continue.
3. Change all ports to "MY IP" except for port 4984.
4. Make sure you choose a key that you have locally.

### SSH in and start Sync Gateway

1. Go to the AWS console, find the EC2 instance, and find the instance's public ip address. It should look like `ec2-54-161-201-224.compute-1.amazonaws.com`. The rest of the instructions will refer to this as `public_ip`.
2. From the command line, run `ssh ec2-user@public_ip` (this should let you in without prompting you for a password. If not, you chose a key when you launched that you don’t have locally).
3. Start the Sync Gateway with this command.

    ```bash
    /opt/couchbase-sync-gateway/bin/sync_gateway -interface=0.0.0.0:4984 -url=http://localhost:8091 -bucket=sync_gateway -dbname=sync_gateway
    ```

4. You should see output like this:

    ```
    2015-11-03T19:37:05.384Z ==== Couchbase Sync Gateway/1.1.0(28;86f028c) ====
    2015-11-03T19:37:05.384Z Opening db /sync_gateway as bucket "sync_gateway", pool "default", server <http://localhost:8091>
    2015-11-03T19:37:05.384Z Opening Couchbase database sync_gateway on <http://localhost:8091>
    2015/11/03 19:37:05  Trying with selected node 0
    2015/11/03 19:37:05  Trying with selected node 0
    2015-11-03T19:37:05.536Z Using default sync function 'channel(doc.channels)' for database "sync_gateway"
    2015-11-03T19:37:05.536Z     Reset guest user to config
    2015-11-03T19:37:05.536Z Starting profile server on
    2015-11-03T19:37:05.536Z Starting admin server on 127.0.0.1:4985
    2015-11-03T19:37:05.550Z Starting server on localhost:4984 ...
    ```

### Verify via curl

From your workstation:

```bash
$ curl http://public_ip:4984/sync_gateway/
```
You should get a response like the following:

```bash
{"committed_update_seq":1,"compact_running":false,"db_name":"sync_gateway","disk_format_version":0,"instance_start_time":1446579479331843,"purge_seq":0,"update_seq":1}
```

### Customize configuration

For more advanced Sync Gateway configuration, you will want to create a JSON config file on the EC2 instance itself and pass that to Sync Gateway when you launch it, or host your config JSON on the internet somewhere and pass Sync Gateway the URL to the file.

### View Couchbase Server UI

In order to login to the Couchbase Server UI, go to `http://public_ip:8091` and use the following credentials:

**Username**: Administrator

**Password**: The AWS instance id that can be found on the EC2 Control Panel (eg: i-8a9f8335)