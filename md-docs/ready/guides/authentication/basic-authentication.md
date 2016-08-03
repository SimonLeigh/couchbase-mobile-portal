---
id: basic-authentication
title: Basic Authentication
permalink: ready/guides/authentication/basic-authentication/index.html
---

The user name and password to authenticate a user can be specified in the following APIs:

- **Authenticator** You can provide a user name and password to the basic authenticator class method of the Authenticator class. Under the hood, the replicator will send the credentials in the first request to retrieve a SyncGatewaySession cookie and use it for all subsequent requests during the replication. This is the recommended way of using Basic authentication.
- **Replication URL** With this method, you can embed the username and password in the replication URL with the following syntax `https://username:password@example.com/database`. The downside of this approach is that the user credentials are sent in every request (as opposed to a cookie session).

On iOS and Mac OS you can also take advantage of the URL loading system's credential store and Keychain. Credentials registered this way will automatically be applied to requests made by the replicator. You can easily do this by creating an `NSURLCredential` object and assigning it to the replication's `credential` property. Or if you use the Keychain APIs to persistently store a credential in the application's keychain, it will always be available to the replicator. This is the most secure way to store a credential, since the keychain file is encrypted.