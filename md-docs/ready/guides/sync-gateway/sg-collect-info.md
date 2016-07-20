---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/sync-gateway/sgcollect-info/index.html
---

With this release comes a new command line utility called `sgcollect_info` that provides us with detailed statistics for a specific node. Run `sgcollect_info` on each node individually, not on all simultaneously.

Outputs:

1. pprof outputs (each have a text, raw and pdf form)
2. profile - Full debug profile created via pprof
3. heap - Full heap dump created via pprof
4. goroutine - Full dump of all running goroutines, created via pprof

## Log files

The tool creates the following log files in the ouput file.

| Log file | Description |
|:------------|:----|
| `sync_gateway_access.log` | The http access log for sync gateway (i.e which GETs and PUTs it has received and from which IPs) |
|`sg_accel_access.log`|The http access log for sg_accel (i.e which GETs and PUTs it has received and from which IPs)|
|`sg_accel_error.log`|The error log (all logging sent to stderr by sg\_accel) for the sg_accel process|
|`sync_gateway_error.log`|The error log (all logging sent to stderr by sync_gateway) for the sync\_gateway process|
|`server_status.log`|The output of http://localhost:4895 for the running sync gateway|
|`db_db_name_status.log`|The output of http://localhost:4895/db\_name for the running sync gateway|
|`sync_gateway.json`|The on-disk configuration file used by sync\_gateway when it was launched|
|`sg_accel.json`|The on-disk configuration file used by sg\_accel when it was launched|
|`running\_server\_config.log`|The configuration used by sync gateway as it is running (may not match the on-disk config as it can be changed on-the-fly)|
|`running_db_db_name_config.log`|The config used by sync gateway for the database specified by db\_name|
|`expvars_json.log`|The expvars (global exposed variables - see [http://www.mikeperham.com/2014/12/17/expvar-metrics-for-golang/](http://www.mikeperham.com/2014/12/17/expvar-metrics-for-golang/) for the running sync gateway instance)|
|`sgcollect_info_options.log`|The command line arguments passed to sgcollect\_info for this particular output|

## CLI command and parameters

| Parameter | Description |
|:------------|:----|
|`-v`|Increase the verbosity level that the sgcollect\_info process logs at (note this does not affect the final output file)|
|`-p`|Gather only product related information (i.e does not collect any system-level information)|
|`-d`|List all utilities that sgcollect\_info requires|
|`--upload-host`|The host to upload the final output final to, usually a remote FTP location|
|`--customer`|In conjunction with '--upload-host', specify the customer name to generate the appropriate URL to upload to|
|`--ticket`|In conjunction with '--upload-host', specify the ticket number to generate the appropriate URL to upload to|
|`--sync-gateway-url`|Sync gateway admin port URL, e.g http://localhost:4985|
|`--sync-gateway-config`|Path to the sync gateway config file, but will by default also discover this via expvars|
|`--sync-gateway-executable`|Path to Sync Gateway executable. By default will try to discover via expvars|