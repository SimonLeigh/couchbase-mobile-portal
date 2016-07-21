---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/openid/index.html
---

With OpenID Connect now integrated in Couchbase Mobile, you can authenticate users with providers that implement the OAuth 2.0 protocol. This means you won't need to setup an App Server to authenticate users with Google+, PayPal, Yahoo, Active Directory, etc. It works out of the box.

Open ID Connect can be configured in two different ways.

- Authorization Code Flow: With this method, you simply set an `OpenIDConnectAuthenticator` authorizer on the replication object. This is the preferred flow for mobile applications, as it supports retrieval and secure storage of the refresh token. This allows clients to avoid forcing users to re-enter username/password information every time their current session expires. Authorization Code Flow is supported in the iOS, Android and .NET Couchbase Lite SDKs.
- Implicit Flow: With this method, the retrieval of the ID token takes place on the device. You can then create a user session using the POST `/{db}/_session` endpoint on the Public REST API with the ID token.

When developing with the iOS, Android or .NET Couchbase Lite SDKs, you can take advantage of auth code flow which will handle all the complexity of user authentication for you. And the implicit flow should be used for all other platforms to provide the same user authentication capability. For example in web applications that use PouchDB or interact with Sync Gateway's REST API directly.

The [openid branch of Grocery Sync iOS](https://github.com/couchbaselabs/Grocery-Sync-iOS/tree/openid) is a working sample that demonstrates how to use OpenID Connect with the Couchbase Lite iOS SDK and Sync Gateway.

1. Clone the repository: `git clone https://github.com/couchbaselabs/Grocery-Sync-iOS.git`
2. Checkout on the `openid` branch `git checkout origin/openid`
3. Download the latest developer preview of Sync Gateway
4. Start Sync Gateway with the config file in this repository: `~/path/to/sync_gateway sync_gateway_config.json`

You can login with your Google+ using the Auth Code Flow or Implicit Flow.

![](./img/images.001.png)

In this guide, we will use Google SignIn as an example for the OpenID Provider (abbreviated OP) but the same steps apply for any other OP that you intend to use.

#### Implicit Flow
        
![](./img/images.003.png)
        

1. The Google SignIn SDK prompts the user to login and if successful it returns an ID token to the application.
2. The ID token is used to create a Sync Gateway session by sending a POST `/{db}/_session` request.
3. Sync Gateway returns a cookie session in the response header.
4. The Sync Gateway cookie session is used on the replicator object.

With the implicit flow, the mechanism to refresh the token and Sync Gateway session must be handled in the application code. On launch, the application should check if the token has expired. If it has then you must request a new token (Google SignIn for iOS has method called `signInSilently` for this purpose). By doing this, the application can then use the token to create a Sync Gateway session.

Sync Gateway sessions also have an expiration date. The replication `lastError` property will return a **401 Unauthorized** when it's the case and then the application must retrieve create a new Sync Gateway session and set the new cookie on the replicator.

### Sync Gateway

This section will walk you through a few Sync Gateway configuration for both authentication flows. The definition and description of each property can be found at the end of the session.

#### Auth Code Flow

Sample Sync Gateway config for the Auth Code Flow.

```javascript
{
  "interface":":4984",
  "log":["*"],
  "databases": {
    "default": {
      "server": "http://localhost:8091",
      "bucket": "default",
      "oidc": {
        "default_provider":"google",
        "providers": {
          "google": {
              "issuer":"https://accounts.google.com",
              "client_id":"279085463427-b4tluo601dovlf1ks4kk4p8tgkps9uso.apps.googleusercontent.com",
              "validation_key":"FfjeQU2nwUauWA2zhwQuRcw8",
              "callback_url":"http://localhost:4984/default/_oidc_callback",
              "register":true,
              "disable_session":true
          }
        }
      }
    }
  }
}
```

#### Testing OpenID Connect for Auth Code Flow


Sync Gateway provides a minimal OpenID Provider (abbreviated OP) to support out of the box testing. The test OP should not be used for production, it doesn't provide a complete implementation and is an experimental feature. The test OP is enabled per database, add the following to the Sync Gateway configuration on the database object.

```javascript
"unsupported": {
    "oidc_test_provider": {
        "enabled":true
    }
},
```

Set the OIDC properties in your Sync Gateway database config like the following.

```javascript
"GoogleAuthFlow": {
    "issuer":"https://accounts.google.com",
    "client_id":"31919031332-8ea1795ckkphb7hmg6i4ul0blcpq8oq5.apps.googleusercontent.com",
    "validation_key":"OCIbokd6-SE8LMZE_vQsq8F5",
    "callback_url":"http://localhost:4984/grocery-sync/_oidc_callback",
    "register":true
}
```

The <code>issuer</code> URL must point to the database containing the config suffixed
          with <code>/_oidc_testing</code>. The <code>client_id</code> value must be
          <code>sync_gateway</code>. The <code>validation_key</code> can be set to any value, the OIDC
          client and the testing OP will use for token requests. The <code>callback</code> URL must
          point to the database containing the config suffixed with <code>/_oidc_callback</code>.

#### Implicit Flow

The configuration for the implicit flow must contain the <code>issuer</code> and
          <code>client_id</code>.

```javascript
"GoogleSignIn": {
    "issuer":"https://accounts.google.com",
    "client_id":"31919031332-sjiopc9dnh217somhc94b3s1kt7oe2mu.apps.googleusercontent.com",
    "register":true
}
```

When using the implicit flow with an OP like Google app, app developers need to define multiple OAuth 2.0 client IDs on the OP - one for iOS, one for Android, etc. These can configured as multiple providers in Sync Gateway.

#### Example: Google SignIn

To generate your own `client_id`, `validation_key` [follow this guide](https://auth0.com/docs/connections/social/google).

## How-To: Google+

### Creating a Google project

Follow the instructions below to create a new project in the Google API manager:

1. Go to the [API Manager](https://console.developers.google.com/iam-admin/projects).
2. Select the **Create a project...** menu.
	![](img/api-manager-create-project.png)
3. Provide a name for your project.
4. Enable the **OAuth consent screen**.
	![](img/consent-screen.png)
5. Create a new **OAuth client ID** from the **Credentials** menu.
	![](img/oauth-client-id.png)
  - `http://localhost:4984` is the origin of your Sync Gateway instance.
  - `http://localhost:4984/untitledapp/_oidc_callback` is the callback URL endpoint for a given database.
6. On the next page, select **Web application** and provide the following URLs.
	![](img/create-credential.png)
7. Click **Create** and save the credentials. You will need them in the following sections.