---
id: authentication-overview
title: Authentication Overview
permalink: ready/guides/authentication/index.html
---

Most of the time the remote server will not allow guest access (especially for uploads), so the replicator will need to authenticate itself to it. The replication protocol runs over HTTP — it's an extension of the Sync Gateway and CouchDB REST API — so the authentication mechanisms are pretty standard ones. First, you need to configure Sync Gateway for the authentication required in your application. Sync Gateway supports the following authentication methods:

- Basic Authentication: provide a username and password to authenticate users.
- Custom Authentication: use an App Server to handle the authentication yourself and create user sessions on the Sync Gateway Admin REST API.
- OpenID Connect Authentication: use OpenID Connect providers (Google+, Paypal, etc.) to authenticate users.
- Static providers: Sync Gateway currently supports authentication endpoints for Facebook, Google+ and Mozilla Persona.

Once Sync Gateway is up and running, you generally configure authentication by creating an Authenticator object and assigning it to the replication's `authenticator` property.