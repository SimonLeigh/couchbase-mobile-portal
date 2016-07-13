---
id: openid-connect
title: OpenID Connect
permalink: sg-guides/developer-preview/openid/auth-code-flow/index.html
---

#### Authorization Code Flow

Sync Gateway supports the OpenID Connect [Authorization Code Flow](http://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth). This flow has the key feature of allowing clients to obtain both an ID token (used for authentication against Sync Gateway) as well as a refresh token (which allows clients to obtain a new ID token without re-prompting for user credentials).

Sync Gateway acts as an intermediary between the client application and the OpenID Connect Provider (OP) when using the auth code flow.  Authentication consists of the following steps.  Note that these steps are taken care of by Couchbase Lite's Open ID Connect authenticator - they are just provided here for clarity on Sync Gateway's role in authentication. 

1. Client sends an authentication request to Sync Gateway's _oidc (or _oidc_challenge) endpoint.
2. Sync Gateway returns a redirect to the OP defined in Sync Gateway's config.
3. End-user authenticates against the OP.  
4. On successful authentication, OP redirects the client to Sync Gateway's _oidc_callback endpoint with an authorization code.
5. Sync Gateway uses this code to request an ID token and refresh token from the OP.
6. Sync Gateway creates a session for the authenticated user (based on the identity in the ID token), and returns the ID token, refresh token and session to the client.
7. Client uses either the session or ID token for subsequent requests.



Here is a sample Sync Gateway config file, configured to use the Auth Code Flow.  

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
  		  "google_authcode": {
      		"issuer":"https://accounts.google.com",
      		"client_id":"yourclientid-uso.apps.googleusercontent.com",
      		"validation_key":"your_client_secret",
      		"register":true
  		  },
  		},
  	  }
	}
}

    }
  }
}
```