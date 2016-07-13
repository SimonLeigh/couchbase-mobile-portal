---
id: openid-connect
title: OpenID Connect
permalink: sg-guides/developer-preview/openid/index.html
---

### Overview

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

### Couchbase Lite

#### Auth Code Flow for iOS

The Open ID Connect authenticator takes a callback as parameter, the callback will be called when the OpenID Connect login flow requires the user to authenticate with the Originating Party (OP), the site at which they have an account.

The easiest way to provide this callback is to add the classes in `Extras/OpenIDConnectUI` to your app target, and then simply call `OpenIDController.loginCallback` in the authorizer code.

```objective-c
repl.authenticator = [CBLAuthenticator OpenIDConnectAuthenticator:[OpenIDController loginCallback]];
```

If you want to implement your own UI, then this block should open a modal web view starting at the given loginURL, then return. Just make sure you hold onto the CBLOIDCLoginContinuation block, because you must call it later, or the replicator will never finish logging in.

Wait for the web view to redirect to a URL whose host and path are the same as the given redirectURL (the query string after the path will be different, though). Instead of following the redirect, close the web view and call the given continuation block with the redirected URL (and a nil error). Your modal web view UI should provide a way for the user to cancel, probably by adding a Cancel button outside the web view. If the user cancels, call the continuation block with a nil URL and a nil error. If something else goes wrong, like an error loading the login page in the web view, call the continuation block with that error and a nil URL.

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

When using the implicit flow with an OP like Google app, app developers need to define 
          multiple OAuth 2.0 client IDs on the OP - one for iOS, one for Android, etc. These can configured 
          as multiple providers in Sync Gateway.

#### Configuration properties

<div class="table">
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>providers</td>
        <td>A map of the OIDC provider</td>
      </tr>
      <tr>
        <td>default_provider</td>
        <td>(optional) Provider to use for OIDC requests that don't specify a provider. If only one
                  provider is specified in the <code>providers</code> map, it is used as the default provider.
                  If multiple providers are defined and <code>default_provider</code> is not specified,
                  requests to <code>/db/_oidc</code> must specify the provider parameter.</td>
      </tr>
    </tbody>
  </table>
</div>

The <code>providers</code> map is a named collection of providers, with the following
      properties for each provider

<div class="table">
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>issue</td>
        <td>The OpenID Connect Provider issuer.</td>
      </tr>
      <tr>
        <td>cliend_id</td>
        <td>The client ID defined in the provider for Sync Gateway.</td>
      </tr>
      <tr>
        <td>validation_key</td>
        <td>Key used to validation ID tokens.</td>
      </tr>
      <tr>
        <td>signing_method</td>
        <td>(Optional) Signing method used for validation key (provides additional security)</td>
      </tr>
      <tr>
        <td>callback_url</td>
        <td>The callback URL to be invoked after the end-user obtains a client token. When using the
          default provider, will be of the form https://host:port/db/_oidc_callback. For a named provider,
          should be of the form https://host:port/db/_oidc_callback?provider=PROVIDER_NAME`</td>
      </tr>
      <tr>
        <td>register</td>
        <td>(optional) Whether Sync Gateway should automatically create users for successfully
          authenticated users that don't have an already existing user in Sync Gateway.</td>
      </tr>
      <tr>
        <td>disable_session</td>
        <td>(optional) By default, Sync Gateway will create a new session for the user upon successful OIDC
          authentication, and set that session in the usual way on the _oidc_callback and _oidc_refresh responses.
          If disable_session is set to true, the session is not created (clients must use the ID token for
          subsequent authentications).</td>
      </tr>
      <tr>
        <td>scope</td>
        <td>(optional) By default, Sync Gateway uses the scope "openid email" when calling the OP authorize
          endpoint. If the scope property is defined in the config (as a map of string values), it will be used.</td>
      </tr>
      <tr>
        <td>include_access</td>
        <td>	(optional) When true, the _oidc_callback response will include the access_token, expires_at
          and token_type properties returned by the OP.</td>
      </tr>
      </tbody>
  </table>
</div>