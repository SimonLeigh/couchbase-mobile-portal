---
id: basic-authentication
title: Basic Authentication
permalink: ready/guides/authentication/basic-authentication/index.html
---

By default, Sync Gateway does not enable authentication. This is to make it easier to get up and running with synchronization. You can enable authentication with the following properties in the configuration file:

```javascript
{
  "databases": {
    "mydatabase": {
      "users": {
        "GUEST": {"disabled": true},
        "john": {"password": "pass"}
      }
    }
  }
}
```

In this configuration file, you are creating a user where the username is `john` and password is `pass`. Then, the user name and password to authenticate a user can be specified in two ways covered below.

### Authenticator

You can provide a user name and password to the basic authenticator class method of the Authenticator class. Under the hood, the replicator will send the credentials in the first request to retrieve a SyncGatewaySession cookie and use it for all subsequent requests during the replication. This is the recommended way of using Basic authentication.

<div class="tabs"></div>

```objective-c+
NSURL* url = [NSURL URLWithString: @"https://example.com/mydatabase/"];
CBLReplication *push = [database createPushReplication: url];
CBLReplication *pull = [database createPullReplication: url];
push.continuous = pull.continuous = YES;
id<CBLAuthenticator> auth;
auth = [CBLAuthenticator basicAuthenticatorWithName: @"john"
                                           password: @"pass"];
push.authenticator = pull.authenticator = auth;
```

```swift+
let url = NSURL(string: "https://example.com/mydatabase/")
let push = database.createPushReplication(url)
let pull = database.createPullReplication(url)
push.continuous = true
pull.continuous = true
var auth: CBLAuthenticatorProtocol?
auth = CBLAuthenticator.basicAuthenticatorWithName("john", password: "pass")
push.authenticator = auth
pull.authenticator = auth
```

```java+
URL url = new URL("https://example.com/mydatabase/");
Replication push = database.createPushReplication(url);
Replication pull = database.createPullReplication(url);
pull.setContinuous(true);
push.setContinuous(true);
Authenticator auth = new BasicAuthenticator("john", "pass");
push.setAuthenticator(auth);
pull.setAuthenticator(auth);
```

```c+
var url = new Uri("https://example.com/mydatabase/");
var push = database.CreatePushReplication(url);
var pull = database.CreatePullReplication(url);
var auth = AuthenticatorFactory.CreateBasicAuthenticator("john", "pass");
push.Authenticator = auth;
pull.Authenticator = auth;
push.Continuous = true;
pull.Continuous = true;
```

### Replication URL

With this method, you can embed the username and password in the replication URL with the following syntax `https://username:password@example.com/database`. The downside of this approach is that the user credentials are sent in every request (as opposed to a cookie session).

> On iOS and Mac OS you can also take advantage of the URL loading system's credential store and Keychain. Credentials registered this way will automatically be applied to requests made by the replicator. You can easily do this by creating an `NSURLCredential` object and assigning it to the replication's `credential` property. Or if you use the Keychain APIs to persistently store a credential in the application's keychain, it will always be available to the replicator. This is the most secure way to store a credential, since the keychain file is encrypted.