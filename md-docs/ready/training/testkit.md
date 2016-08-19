## Introduction

This guide provides instructions to get started with mobile testkit to run Sync Gateway performance tests. The scenarios can run on a Vagrant VM or EC2 instances on AWS; this guide covers AWS only. Generally speaking there are 4 different steps to running performance tests:

1. Provisioning EC2 instances on AWS
2. Provisioning the software on separate nodes (sync gateway, couchbase server)
3. Running the tests
4. Writing and running more tests

Mobile-testkit is a set of tools that cover points 2, 3, 4. Before you start using mobile-testkit, you must first provision the EC2 instances.

## Provisioning EC2 instances

### AWS Security Group

You will create a security group to open the appropriate ports for Sync Gateway and Couchbase Server. In the [EC2 Console](https://console.aws.amazon.com/ec2/v2/home) click **Security Groups** on the left navigation pane. Create a new security group called **couchbase** with the following Inbound rules:

- TCP ports: 8092, 21100, 11209, 5984, 4985, 4369, 4984, 11210, 8091, 11211, 9876 with `Anywhere` as the source
- SSH ports: 22 with `Anywhere` as the source 

### EC2 Instances

Log in on your AWS account and in the Amazon EC2 menu click the [Launch Instance](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#LaunchInstanceWizard:) button. For the AMI, choose the **CentOS 7 (x86_64) - with Updates HVM** from the AWS Marketplace. For the instance type, choose **t2.large** which is 2 CPUs and 8 GB. Choose the security group called **couchbase** that was created above.

Make sure you can ssh on those VMs. The user is **centos**:

```
ssh centos@IP-ADDRESS
```

## mobile-testkit

### Setup

[Download mobile-testkit](https://cl.ly/0v2K1W2u383X/mobile-testkit-4de9d2e3e17a18e1995b2a94fc8288c155429333.zip) and unzip the content.

Set the following environment variables:

```bash
export PATH=~/Downloads/mobile-testkit-4de9d2e3e17a18e1995b2a94fc8288c155429333:$PATH
export PYTHONPATH=~/Downloads/mobile-testkit-4de9d2e3e17a18e1995b2a94fc8288c155429333
export ANSIBLE_CONFIG=~/Downloads/mobile-testkit-4de9d2e3e17a18e1995b2a94fc8288c155429333
```

Set virtualenv to install python dependencies:

```bash
$ [sudo] pip install virtualenv
```

Install the dependencies:

```bash
source setup.sh
```

The default user on mobile-testkit is **vagrant** so you need to change it to be **centos**:

```
cp ansible.cfg.example ansible.cfg
```

In ansible.cfg replace the line `remote_user = vagrant` with `remote_user = centos`.

### Generating cluster configs

Next, you'll provide the list of EC2 instance IP addresses in a file called **pools.json**:

```
cp resources/pool.json.example resources/pool.json
```

Replace the IP addresses.

```
{
    "ips": [
        "52.40.78.128",
        "52.40.78.128"
    ]
}
```

Generate the cluster topologies to run the tests.

```
python libraries/utilities/generate_clusters_from_pool.py
```

Different cluster topology configs are generated in **resources/cluster_configs**. Set the `CLUSTER_CONFIG` environment variable to the desired topology, 1 Sync Gateway and 1 Couchbase Server.

```
export CLUSTER_CONFIG=resources/cluster_configs/1sg_1cbs
```

Provision Sync Gateway and Couchbase Server (it will use the cluster topology set on `CLUSTER_CONFIG`).

```
python libraries/provision/provision_cluster.py --server-version=4.1.1 --sync-gateway-version=1.3.0-274
```

If the provisioning was successful you will see the following at the end of the output:

```
PLAY RECAP *********************************************************************

>>> Done provisioning cluster...
```

## Running Locust tests

Performance tests can be written using [locust.io](http://locust.io/). The write throughput scenario (`testsuites/syncgateway/performance/locust/runners/WriteThroughputRunner.py`) is an example of a test scenario written with locust, the usage of locust in mobile-testkit is currently experimental. Refer to this example scenario to write your own. To launch the write throughput scenario run the following where `IP-ADDRESS` in the `--target` flag refers to the IP address of the EC2 instance that Sync Gateway is running on. The cluster topology file contains this information (e.g resources/cluster_configs/1sg_1cbs).

```
python testsuites/syncgateway/performance/locust/runners/WriteThroughputRunner.py --target=http://52.88.39.127 --num-writers=10 --num-channels=10 --num-channels-per-doc=2 --total-docs=1000 --doc-size=1024
```

Results from the test are available in the output.

```
 Name                                                          # reqs      # fails     Avg     Min     Max  |  Median   req/s
--------------------------------------------------------------------------------------------------------------------------------------------
 POST /db/                                                       1000     0(0.00%)     165     154     357  |     160   37.10
 POST /db/_session                                                 10     0(0.00%)     387     340     435  |     380    0.00
 GET /db/_user/user_0                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_1                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_2                                               1     0(0.00%)     168     168     168  |     170    0.00
 GET /db/_user/user_3                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_4                                               1     0(0.00%)     162     162     162  |     160    0.00
 GET /db/_user/user_5                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_6                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_7                                               1     0(0.00%)     160     160     160  |     160    0.00
 GET /db/_user/user_8                                               1     0(0.00%)     166     166     166  |     170    0.00
 GET /db/_user/user_9                                               1     0(0.00%)     159     159     159  |     160    0.00
--------------------------------------------------------------------------------------------------------------------------------------------
 Total                                                           1020     0(0.00%)                                      37.10

Percentage of the requests completed within given times
 Name                                                           # reqs    50%    66%    75%    80%    90%    95%    98%    99%   100%
--------------------------------------------------------------------------------------------------------------------------------------------
 POST /db/                                                        1000    160    160    160    170    180    180    190    320    357
 POST /db/_session                                                  10    390    410    420    420    440    440    440    440    435
 GET /db/_user/user_0                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_1                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_2                                                1    170    170    170    170    170    170    170    170    168
 GET /db/_user/user_3                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_4                                                1    160    160    160    160    160    160    160    160    162
 GET /db/_user/user_5                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_6                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_7                                                1    160    160    160    160    160    160    160    160    160
 GET /db/_user/user_8                                                1    170    170    170    170    170    170    170    170    166
 GET /db/_user/user_9                                                1    160    160    160    160    160    160    160    160    159
--------------------------------------------------------------------------------------------------------------------------------------------
```