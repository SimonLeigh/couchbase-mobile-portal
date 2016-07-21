---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/openid/implicit-flow/index.html
---

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