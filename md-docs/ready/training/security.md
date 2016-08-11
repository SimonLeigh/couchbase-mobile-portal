---
id: security
title: Security
permalink: ready/training/security/index.html
---

In deciding the data model for the application you must also consider the access rules for each document type. More specifically, given a user with certain privileges, what operations can this user perform on each document type?

The sync function is the core API you interact with on Sync Gateway to implement those rules. It's responsible for validating the document properties, granting users access to specific documents and also granting users with privileges when there are multiple user roles in the application.

Here are the top level access rules that you will implement in the sync function for each document type:

### task-list documents

- Grant the task list owner read access to the task list, the tasks within the list and its users
- Allow moderators to access the task list

### task documents

- Once a task has been associated with a list it cannot be associated with another list
- Allow moderators to access the tasks in any list

### task-list:user documents

- Only the owner of the list and moderators can write `task-list:user` documents
- The `task-list:user` is never displayed on the user interface. It's sole purpose is to grant another user access to a list

### moderator documents

- Only a user with the role of `admin` can assign the `moderator` role to other users