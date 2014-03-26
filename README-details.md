Couchbase Mobile Developer Portal
=================================

Landing
-------

- Summary
- Simple Introductions

Introduction
------------

- JSON Anywhere
- Couchbase Lite
- Sync-Gateway
- Couchbase Server

Develop
-------

### Training

- Getting Started
  - Building Your First App
  - Adding Synchronization
- Building Apps
  - Querying & Sorting
  - Attachments
  - Synchronization
  - User Authentication
  - Relational Data
  - Service Integration
- Best Practices
  - Testing
  - Performance  
  - Data Modeling
  - Security & Privacy
- Operations
  - Sizing 

### Guides

- Guides `<set>`
- `<introduction>`
- Couchbase Lite `<set>`
  - `<introduction>`
  - Native API `<guide>`
    - `<introduction>`
    - NOTE:  Make sure to include information about what the Native API is and what it is used for.
    - Manager `<article>`
      - `<introduction>`
        - NOTE:  Make sure to include information about what the Manager is and what it is used for.
      - Creating a Manager `<topic>`
      - Manager Options `<topic>`
    - Database `<article>`
      - `<introduction>`
        - NOTE:  Make sure to include information about what the Database is and what it is used for.
      - Managing a Database `<topic>`
        - Creating `<section>`
        - Deleting `<section>`
        - Replacing `<section>`
        - Querying `<section>`
      - Database Validation `<topic>`
        - NOTE:  Make sure to include enough information about Validation Context that its clear what it is.
      - Local Documents `<topic>`
      - Compaction `<topic>`
        - NOTE:  Make sure to include information about what compaction is, how to use it, when to use it, and a code sample.
      - Monitoring Database Change Events `<topic>`
        - NOTE:  Make sure to include information about how to monitor change events and when to use change events.
    - Document `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what the Document is and what it is used for.
      - CRUD a Document `<topic>`
      - Relationship to Attachments `<topic>`
      - Revisions `<topic>`
      - Conflict Resolution `<topic>`
      - Purging `<topic>`
      - Monitoring Document Change Events `<topic>`
    - Revision `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what the Revision is and what it is used for.
      - Revision History `<topic>`
        - Revision tree `<section>`
        - Tombstoning `<section>`
      - What is the difference between Saved Revision and Unsaved Revision? `<topic>`
    - Attachment `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what an Attachment is and what it is used for.
      - CRUD an Attachment `<topic>`
    - View `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what a View is and what it is used for.
      - Indexing `<topic>`
        - Creating an Index `<section>`
          - NOTE: Make sure to provide some high-level points on what is MapReduce
        - Updating an Index `<section>`
        - Deleting an Index `<section>`
        - View Compiler `<topic>`
    - Query `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what a Query is and what it is used for.
      - LiveQuery `<topic>`
      - Remove indices from a Query `<topic>`
      - Run a Query `<topic>`
      - Advanced Querying Topics `<topic>`
        - How to do Sorting `<section>`
        - How to do Pagination `<section>`
        - How to do Grouping `<section>`
        - Aggregation `<section>`
    - Replication `<article>`
      - `<introduction>`
        - NOTE: Make sure to include information about what a Replication is and what it is used for.
      - Create a Replication `<topic>`
      - Updating a Replication `<topic>`
      - Deleting a Replication `<topic>`
      - Staring, Stopping, Restarting a Replication `<topic>`
      - Monitoring Replication Change Events `<topic>`
      - Progress and Activity `<topic>`
        - Status `<section>`
      - Filtering `<topic>`
        - NOTE: Make sure to mention both channels and filtered replication
      - Replication modes `<topic>`
        - Streaming `<section>`
        - Polling `<section>`
        - One-shot `<section>`
          - NOTE: Make sure to mention how this can be used for Push Notification
  - REST API `<guide>`
    - `<introduction>`
    - Link to REST API
  - Authentication
    - `<introduction>`
    - Facebook `<topic>`
    - Persona `<topic>`
    - Custom `<topic>`
      - LDAP `<section>`
      - Active-Directory `<section>`
  - P2P `<guide>`
    - `<introduction>`
    - How does P2P work in Couchbase Lite `<topic>`
  - Troubleshooting `<guide>`
  - Integrations `<guide>`
    - Core Data `<article>`
- Sync Gateway `<set>`
  - `<introduction>`
  - Channels `<guide>`
    - `<introduction>`
    - Conflict Resolution `<topic>`
  - Sync Function API `<guide>`
    - `<introduction>`
    - NOTE: Make sure to include channel(), access(), role(), throw(), requireUser(), requireRole(), requireAccess()
  - Administration `<guide>`
    - `<introduction>`
    -  Walrus `<topic>`
    - Command Line Tools `<topic>`
    - Admin REST APIs `<topic>`
      - NOTE: Can link to REST API
    - Starting Sync Gateway `<topic>`
    - Stopping Sync Gateway `<topic>`
    - Hosting & Scaling Sync Gateway `<topic>`
  - Working with Couchbase Server `<guide>`
    - Bucket shadowing `<topic>`
    - Document worker pattern `<topic>`
  - REST API `<guide>`
    - `<introduction>`
    - NOTE: Mention how we use REST for both sync communication between Lite and Gateway, Gateway to Couchbase Server, and administration of the Gateway itself.
    - Link to REST API
  - Troubleshooting

### API Reference

- Couchbase Lite
  - Native API
    - Manager
    - Database
    - Document
    - Revision
    - Attachment
    - View
    - Query
    - Replication
  - REST API
- Sync Gateway
  - Sync Function API
    - channel()
    - access()
    - role()
    - Validation
      - throw()
      - requireUser()
      - requireRole()
      - requireAccess()
  - REST API

### Mobile Platforms

- Xamarin
  - Getting Started
  - Hello World
- Titanium
  - Getting Started
  - Hello World
- PhoneGap
  - Getting Started
  - Hello World

### Couchbase Services

- Couchbase Cloud
  - Introduction
  - Signing Up
  - Creating a New Instance
  - Administering an Instance

### Samples

- Hello World
- Todo Lite
- CRM

Download
--------

- Couchbase Lite
  - iOS
  - Android
  - Java
  - C#
- Sync-Gateway
- Couchbase Server
