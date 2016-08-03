---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/openid/configuration-options/index.html
---

#### Configuration properties

| Name | Value |
|:-----|:------|
|`providers`|A map of OIDC provider definitions.|
|`default_provider`|_Optional._ Provider to use for OIDC requests that don't specify a provider. If only one provider is specified in the `providers` map, it is used as the default provider. If multiple providers are defined and `default_provider` is not specified, requests to `/db/_oidc` must specify the provider parameter.|

The `providers` map is a named collection of providers, with the following properties for each provider.

| Name | Value |
|:-----|:------|
|`issuer`|The OpenID Connect Provider issuer.|
|`client_id`|The client ID defined in the provider for Sync Gateway.|
|`validation_key`|Client secret associated with the client. Required for auth code flow. |
|`signing_method`|_Optional._ Signing method used for validation key (provides additional security).|
|`callback_url`|_Optional._ The callback URL to be invoked after the end-user obtains a client token. When not provided, Sync Gateway will generate based on the incoming request.  |
|`register`|_Optional._ Whether Sync Gateway should automatically create users for successfully authenticated users that don't have an already existing user in Sync Gateway.|
|`disable_session`|_Optional._ By default, Sync Gateway will create a new session for the user upon successful OIDC authentication, and set that session in the usual way on the `_oidc_callback` and `_oidc_refresh` responses. If `disable_session` is set to true, the session is not created (clients must use the ID token for subsequent authentications).|
|`scope`|_Optional._ By default, Sync Gateway uses the scope "openid email" when calling the OP's authorize endpoint. If the scope property is defined in the config (as a map of string values), it will override this scope.|
|`include_access`|_Optional._ When true, the _oidc_callback response will include the `access_token`, `expires_at` and 
`token_type` properties returned by the OP.|
|`user_prefix`|_Optional._ Specifies the prefix for Sync Gateway usernames for the provider.  When not specified, defaults to `issuer`. |
|`discovery_url`|_Optional._ Discovery URL used to obtain the OpenID Connect provider configuration.  If not specified, the default discovery endpoint of `[issuer]/.well-known/openid-configuration` will be used.  |
|`disable_cfg_validation`|_Optional._ Disables strict validation of the OpenID Connect configuration.  |
