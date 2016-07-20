---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/openid/configuration-options/index.html
---

#### Configuration properties

| Name | Value |
|:-----|:------|
|`providers`|A map of the OIDC provider|
|`default_provider`|_Optional._ Provider to use for OIDC requests that don't specify a provider. If only one provider is specified in the `providers` map, it is used as the default provider. If multiple providers are defined and `default_provider` is not specified, requests to `/db/_oidc` must specify the provider parameter.|

The `providers` map is a named collection of providers, with the following properties for each provider

| Name | Value |
|:-----|:------|
|`issue`|The OpenID Connect Provider issuer.|
|`cliend_id`|The client ID defined in the provider for Sync Gateway.|
|`validation_key`|Key used to validation ID tokens.|
|`signing_method`|_Optional._ Signing method used for validation key (provides additional security).|
|`callback_url`|The callback URL to be invoked after the end-user obtains a client token. When using the default provider, will be of the form https://host:port/db/_oidc_callback. For a named provider, should be of the form 
https://host:port/db/_oidc_callback?provider=PROVIDER_NAME`|
|`register`|_Optional._ Whether Sync Gateway should automatically create users for successfully authenticated users that don't have an already existing user in Sync Gateway.|
|`disable_session`|_Optional._ By default, Sync Gateway will create a new session for the user upon successful OIDC authentication, and set that session in the usual way on the _oidc_callback and _oidc_refresh responses. If disable_session is set to true, the session is not created (clients must use the ID token for subsequent authentications).|
|`scope`|_Optional._ By default, Sync Gateway uses the scope "openid email" when calling the OP authorize endpoint. If the scope property is defined in the config (as a map of string values), it will be used.|
|`include_access`|_Optional._ When true, the _oidc_callback response will include the access_token, expires_at and 
token_type properties returned by the OP.|