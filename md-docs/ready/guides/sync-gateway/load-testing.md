---
id: load-testing
title: Load testing
permalink: ready/guides/sync-gateway/configuring-sync-gateway/load-testing/index.html
---

This guide describes a few possible steps for stress testing a Sync Gateway and Couchbase Server cluster. You will learn to do the following:

- Set up the mobile-testkit framework
- Deploying a cluster on AWS using mobile-testkit
- Running mobile-testkit scenarios

## Setup

Clone the mobile-testkit repository:

```
$ git clone https://github.com/couchbaselabs/mobile-testkit.git
$ cd mobile-testkit/
```

## Configuring AWS

1. Get your AWS 

## Creating a cluster

in aws create job: the python script creates the ec2 instances on was but has no software installed

## Provisioning a cluster

in sync-gateway-performance-test: provision_cluster.py scripts installed all the server

then uses the run_perf_test script with 

there is a parameter for switching between gatling and gateload

andy: pump the results back to splunk. splunk is dead.

how does those:

gateload: there’s one scenario that’s hardcoded. it’s not configurable. there’s one scenario but then you can tune it to increase the number of pushers or pullers. it will create a bunch of users, then it assigns threads to pushers and pullers. the pushers will push docs several channels and pullers will pull them as fast as they can. then it will measure the roundtrip latency time. it calculates the roundtrip latency. that’s the main metric we use for determining the performance.

gatling: we support the same params as gatefold. there’s a gatling DSL. pretty simple for simple http scenarios. but there’s one that loads a whole bunch of docs first but then starts a second scenarios that creates different types of users. scala knowledge to create new things. random attachment sizes and users.

very simple tutorial to write a custom hello world scenario.

if you write any scenario please submit a PR to mobile-testkit

## Configuration

## Running Tests