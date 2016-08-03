---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/authentication/openid/advanced-topics/index.html
---

### Open ID Connect - Advanced Topics

### User Identity

When authenticating via OpenID Connect, the Sync Gateway username is based on the issuer and subject in the ID token, as [issuer]_[subject].  Both the issuer and subject are URL encoded.  The size of the username can be reduced by setting the optional `user_prefix` value in the Sync Gateway config - this will replace the issuer in the username with the specified `user_prefix` value.

When `register` is false in your provider configuration, the user must already have been created in Sync Gateway for successful authentication.  If `register` is true, upon successful authentication Sync Gateway will create a user based on the token issuer and subject, if that user doesn't already exist.

### Using Multiple Providers

Sync Gateway supports defining multiple OpenID Connect providers. Use cases include:

 - Your application wants to support authentication via a variety of OpenID Connect providers 
 - Your application wants to support multiple authentication flows (auth code flow, implicit) for a given provider.  (e.g. Google defines separate OpenID Connect Client IDs for web (auth code), Android, iOS)

Multiple providers can be defined in the config, as in the following example:

```javascript
{
  "databases": {
    "default": {
      "server": "http://localhost:8091",
      "bucket": "default",
      "oidc": {
        "default_provider":"google_authcode",
		"providers": {
  		  "google_authcode": {
      		"issuer":"https://accounts.google.com",
      		"client_id":"your_client_id",
      		"validation_key":"your_client_secret",
      		"register":true
  		  },
  		  "google_implicit": {
            "issuer":"https://accounts.google.com",
  			"client_id":"your_other_client_id",
            "register":true
          },
  		  "non_default_authcode": {
      		"issuer":"https://accounts.google.com",
      		"client_id":"your_second_client_id",
      		"validation_key":"your_client_secret",
            "callback_url":"http://localhost:4984/default/_oidc_callback?provider=second_authcode",
      		"register":true
  		  },
  		}
  	  }
	}
  }
}
```

When authenticating via the implicit flow, Sync Gateway will attempt to match the issuer and audience in the ID token with the issuer and client_id for a provider defined in its config.  

When authenticating via the auth code flow and there are multiple providers defined in its config, Sync Gateway will by default use the provider specified in the `default_provider` property in the config.  To leverage multiple auth code flow providers, requests made against the _oidc and _oidc_callback endpoints need to specify the provider property to indicate which provider to use (see the API documentation for details).  Note that when using a non-default provider, the callback URL will need to be defined to target your provider (as in the non_default_authcode provider in the example above).


### Using Non-standard Providers

By default, Sync Gateway doesn't support providers that don't strictly adhere to the OpenID Connect specification.  However, it's possible to enable support for non-standard providers in one of two ways:

 1. Setting the discovery_url in your provider's config.  By default, Sync Gateway expects your OP's configuration to be available at the standard discovery endpoint : [issuer]/.well-known/openid-configuration.  If your OP uses a different endpoint, you can specify that in the discovery_url property in your config.  When the discovery_url property is set, the OP configuration will be retrieved from that endpoint, and strict configuration validation will be disabled.
 2. Setting disable_cfg_validation=true in your provider config.  If this property is set to true, strict configuration validation will be disabled, even when using the standard discovery endpoint.



### Testing with the Internal Test provider

Sync Gateway includes a sample OpenID Connect Provider that can be used for simple app testing.  It doesn't provide any security or identity validation, and so doesn't serve as a replacement for a real OpenID connect provider - it's just a way for you to validate the auth code flow in your application against a test provider. 

Note: It's important to remove the test provider from your config before going into production - otherwise any user will be able to authenticate against your Sync Gateway.

To enable the test provider, add the following to the Sync Gateway configuration:

```javascript
"unsupported": {
    "oidc_test_provider": {
        "enabled":true
    }
},
```

Define a provider in your config corresponding to the internal test provider:

```javascript
"providers": {
	"test": {
	   "issuer":"http://localhost:4984/<your_db>/_oidc_testing",
	   "client_id":"sync_gateway",
	   "validation_key":"R75hfd9lasdwertwerutecw8",
	   "register":true
	}
}
```

The `issuer` URL must point to the database containing the config suffixed with `/_oidc_testing`. The `client_id` value must `sync_gateway`. The `validation_key` can be set to any value, the OIDC client and the testing OP will use for token requests. The `callback` URL must point to the database containing the config suffixed with `/_oidc_callback`.