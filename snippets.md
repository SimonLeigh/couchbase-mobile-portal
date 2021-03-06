## CSharp

```csharp
// Get the database (and create it if it doesn’t exist). 
var database = Manager.SharedInstance.GetDatabase("mydb"); 

// Create a new document (i.e. a record) in the database. 
var document = database.CreateDocument(); 
document.PutProperties(new Dictionary<string, object> { 
    { "firstName", "John" } 
}); 

// Update a document. 
document.Update(rev => 
{ 
    var props = rev.UserProperties; 
    props["firstName"] = "Johnny"; 
    rev.SetUserProperties(props); 
    return true; 
}); 

// Delete a document. 
document.Delete(); 

// Create replicators to push & pull changes to & from the cloud. 
var url = new Uri("https://www.my.com/mydb/"); 
var push = database.CreatePushReplication(url); 
var pull = database.CreatePullReplication(url); 
push.Continuous = true; 
pull.Continuous = true; 

// Add authentication. 
var authenticator = AuthenticatorFactory.CreateBasicAuthenticator(name, password); 
push.Authenticator = authenticator; 
pull.Authenticator = authenticator; 

// Listen to database change events (there are also change 
// events for documents, replications, and queries). 
database.Changed += OnChanged; 

// Start replicators 
push.Start(); 
pull.Start();
```

## ObjC

```objective-c
// Get the database (and create it if it doesn’t exist).
CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed: @"mydb"error: &error];

// Create a new document (i.e. a record) in the database.
CBLDocument *document = [database createDocument];
[document putProperties: @{@"firstName": @"John"} error: &error];

// Update a document.
[document update:^BOOL(CBLUnsavedRevision *newRevision) {
    newRevision[@"firstName"] = @"Johnny";
    return YES;
} error: &error];

// Delete a document.
[document deleteDocument:&error];

// Create replicators to push and pull changes to and from the cloud.
NSURL *url = [NSURL URLWithString: @"https://www.my.com/mydb/"];
CBLReplication *push = [database createPushReplication: url];
CBLReplication *pull = [database createPullReplication: url];
push.continuous = YES;
pull.continuous = YES;

// Add authentication.
CBLAuthenticator *authenticator = [CBLAuthenticator basicAuthenticatorWithName:name password:password];
push.authenticator = authenticator;
pull.authenticator = authenticator;

// Listen to database change events (there are also change events for
// documents, replications, and queries).
[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(databaseChanged:)
                                             name: kCBLDatabaseChangeNotification 
                                           object: database]; 

// Start replicating. 
[push start]; 
[pull start];
```

## Swift

```swift
// Get the database (and create it if it doesn’t exist).
let database = CBLManager.sharedInstance().databaseNamed("mydb")

// Create a new document (i.e. a record) in the database.
let document = database.createDocument()
document.putProperties(["firstName": "John"])

// Update a document.
document.update { (newRevision) -> Bool in
    newRevision["firstName"] = "Johnny"
    return true
}

// Delete a document.
document.deleteDocument()

// Create replicators to push and pull changes to and from the cloud.
let url = NSURL(string: "https://www.my.com/mydb/")!
let push = database.createPushReplication(url)
let pull = database.createPullReplication(url)
push.continuous = true
pull.continuous = true

// Add authentication.

let authenticator = CBLAuthenticator.basicAuthenticatorWithName(name, password: password)
push.authenticator = authenticator
pull.authenticator = authenticator

// Listen to database change events (there are also change events for
// documents, replications, and queries).
NSNotificationCenter.defaultCenter().addObserver(self, selector: "databaseChanged:",
name: kCBLDatabaseChangeNotification, object: database) 

// Start replicating. 
push.start() 
pull.start()
```

## Java

```java
// Get the database (and create it if it doesn’t exist).
Manager manager = new Manager(new JavaContext(), Manager.DEFAULT_OPTIONS);
Database database = manager.getDatabase("mydb");

// Create a new document (i.e. a record) in the database.
Document document = database.createDocument();
Map<String, Object> properties = new HashMap<String, Object>();
properties.put("firstName", "John");
document.putProperties(properties);

// Update a document.
document.update(new Document.DocumentUpdater() {
    @Override
    public boolean update(UnsavedRevision newRevision) {
        Map<String, Object> properties = newRevision.getUserProperties();
        properties.put("firstName", "Johnny");
        newRevision.setUserProperties(properties);
        return true;
    }
});

// Delete a document.
document.delete();

// Create replicators to push & pull changes to & from the cloud.
URL url = new URL("https://www.my.com/mydb/");
Replication push = database.createPushReplication(url);
Replication pull = database.createPullReplication(url);
push.setContinuous(true);
pull.setContinuous(true);

// Add authentication.
Authenticator authenticator = AuthenticatorFactory.createBasicAuthenticator(name, password);
push.setAuthenticator(authenticator);
pull.setAuthenticator(authenticator);

// Listen to database change events (there are also change
// events for documents, replications, and queries).
database.addChangeListener(this);

// Start replicators
push.start();
pull.start();
```

## Android

```java
// Get the database (and create it if it doesn’t exist).
Manager manager = new Manager(new AndroidContext(context), Manager.DEFAULT_OPTIONS);
Database database = manager.getDatabase("mydb");

// Create a new document (i.e. a record) in the database.
Document document = database.createDocument();
Map<String, Object> properties = new HashMap<String, Object>();
properties.put("firstName", "John");
document.putProperties(properties);

// Update a document.
document.update(new Document.DocumentUpdater() {
    @Override
    public boolean update(UnsavedRevision newRevision) {
        Map<String, Object> properties = newRevision.getUserProperties();
        properties.put("firstName", "Johnny");
        newRevision.setUserProperties(properties);
        return true;
    }
});

// Delete a document.
document.delete();

// Create replicators to push & pull changes to & from the cloud.
URL url = new URL("https://www.my.com/mydb/");
Replication push = database.createPushReplication(url);
Replication pull = database.createPullReplication(url);
push.setContinuous(true);
pull.setContinuous(true);

// Add authentication.
Authenticator authenticator = AuthenticatorFactory.createBasicAuthenticator(name, password);
push.setAuthenticator(authenticator);
pull.setAuthenticator(authenticator);

// Listen to database change events (there are also change
// events for documents, replications, and queries).
database.addChangeListener(this);

// Start replicators
push.start();
pull.start();
```
