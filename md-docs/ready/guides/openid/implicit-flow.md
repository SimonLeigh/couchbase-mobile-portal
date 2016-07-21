---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/openid/implicit-flow/index.html
---

## Couchbase Lite

![](./img/images.003.png)

1. The Google SignIn SDK prompts the user to login and if successful it returns an ID token to the application.
2. The ID token is used to create a Sync Gateway session by sending a POST `/{db}/_session` request.
3. Sync Gateway returns a cookie session in the response header.
4. The Sync Gateway cookie session is used on the replicator object.

With the implicit flow, the mechanism to refresh the token and Sync Gateway session must be handled in the application code. On launch, the application should check if the token has expired. If it has then you must request a new token (Google SignIn for iOS has method called `signInSilently` for this purpose). By doing this, the application can then use the token to create a Sync Gateway session.

Sync Gateway sessions also have an expiration date. The replication `lastError` property will return a **401 Unauthorized** when it's the case and then the application must retrieve create a new Sync Gateway session and set the new cookie on the replicator.

You can configure your application for Google SignIn by following [this guide](https://developers.google.com/identity/).

## Sync Gateway configuration

Sync Gateway supports the OpenID Connect [Implicit Flow](http://openid.net/specs/openid-connect-core-1_0.html#ImplicitFlowAuth). This flow has the key feature of allowing clients to obtain their own ID token and use it to authenticate against Sync Gateway.

1. Client obtains a signed ID token directly from an OpenID Connect provider.
2. Client includes the ID token (as a bearer token on the Authorization header) on requests made against the Sync Gateway REST API. 
3. Sync Gateway matches the token to a provider in its config based on the issuer and audience in the tokwn.
4. Sync Gateway validates the token, based on the provider definition.
5. On successful validation, Sync Gateway authenticates the user based on the subject and issuer in the token.

Since ID tokens are typically large, the usual approach is to use the ID token to obtain a Sync Gateway session (using the /db/_session REST endpoint), and then use that token for subsequent authentication requests.

Here is a sample Sync Gateway config file, configured to use the Implicit Flow. 

```javascript
{
  "interface":":4984",
  "log":["*"],
  "databases": {
    "default": {
      "server": "http://localhost:8091",
      "bucket": "default",
      "oidc": {
		"providers": {
  		  "google_implicit": {
      		"issuer":"https://accounts.google.com",
      		"client_id":"yourclientid-uso.apps.googleusercontent.com",
      		"register":true
  		  },
  		},
  	  }
	}
  }
}
```