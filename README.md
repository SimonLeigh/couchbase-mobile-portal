Couchbase Mobile Developer Portal
=================================

Clone the git repository
------------------------

Use Git to clone the Couchbase Mobile Portal repository to your local disk: 

```
git clone git@github.com:couchbaselabs/couchbase-mobile-portal.git
cd couchbase-mobile-portal
git submodule init && git submodule update
```

To contribute to Guides, API references or REST APIs, read the following. You don't need to build the site locally. Just find the content that needs editing and submit a pull request.

## Guides

Part of the documentation is currently written in markdown. The documentation that has already been converted to markdown is located in `md-docs/ready`.

The documentation not yet in markdown is written in XML in `docs/src/guides`.

### Code tabs

To add code tabs in your markdown file add the following html tag:

```html
<div class="tabs"></div>
```

Then use code fencing with the `+` character to specify that its part of code tabs.

```
Objective-C  -> ```objective-c+
Swift        -> ```swift+
Java         -> ```java+
C#           -> ```c+
```

GitHub will render 4 code blocks one after the other but don't worry, the tabs will be displayed as expected on the site.

## REST API

REST APIs are documented using Swagger. Read more in the [readme of the swagger folder](https://github.com/couchbaselabs/couchbase-mobile-portal/tree/master/swagger).

## API References

API references are documented in [https://github.com/couchbaselabs/couchbase-lite-api](https://github.com/couchbaselabs/couchbase-lite-api).

## Ingestion hacks

- [Code tabs in markdown](https://github.com/couchbaselabs/couchbase-mobile-portal/issues/398)
- [Table styles](https://github.com/couchbaselabs/couchbase-mobile-portal/issues/400)
- [Pragma marks on REST API doc titles](https://github.com/couchbaselabs/couchbase-mobile-portal/issues/416)
- [Styling blockquotes](https://github.com/couchbaselabs/couchbase-mobile-portal/issues/420)
- [Highlight Objective-C with C](https://github.com/couchbaselabs/couchbase-mobile-portal/commit/76f2625ed54b9440be1344ca2a13580669c5c962)

## Release notes

Release notes are generated using the [GitHubReleaseNotes](https://github.com/couchbaselabs/GitHubReleaseNotes) tool.

1. [Download the latest release](https://github.com/couchbaselabs/GitHubReleaseNotes/releases)
2. Unzip and navigate to the folder: `cd release-notes-tool`
3. Generate the release notes in Couchbase Mobile's custom XML format: `mono bin/Debug/ReleaseNotesCompiler.CLI.exe update --owner couchbase --repository couchbase-lite-ios --targetcommitish master -u USER -p PASS -m 1.3 --exportxml`

Repositories to generate release notes for:

- couchbase-lite-net
- couchbase-lite-ios
- couchbase-lite-java-core
- couchbase-lite-java
- couchbase-lite-android
- sync_gateway

The tool outputs the XML for each repository in the current directory.

- For SG, copy the `article` to `docs/src/guides/sync-gateway/release-notes.xml`.
- For CBL, copy the `topic` to `docs/src/guides/couchbase-lite/release-notes.xml`.

## CMS release tags

- Create a new key-value pair for the new version (on [cms-qa](http://cms-qa.cbauthx.com/cms/?1&path=/content/documents/website/value-lists/couchbasemobileversions) for example).
- Create a new documentation set for the new version (on [cms-qa](http://cms-qa.cbauthx.com/cms/?1&path=/content/documents/couchbase-developer-portal/documentation/mobile/1.3/mobile-1.3) for example)
- Make the latest documentation set the current one and uncheck the previous one if necessary.