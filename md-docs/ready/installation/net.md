---
id: net
title: .NET
permalink: ready/installation/net/index.html
---

## NuGet

1. In **Solution Explorer**, right-click on your project and click **Select NuGet Packages...**.
    ![](img/wpf-nuget.png)
2. Search for 'Couchbase Lite' and select the latest version of Couchbase Lite.
    ![](img/wpf-nuget-cbl.png)

Once the Couchbase Lite NuGet package is installed you should see that Couchbase.Lite.Storage.SystemSQLite is also installed. That's because SQLite is the default storage type used by Couchbase Lite. You can install additional components as required by the application.

That's it! You can now start using Couchbase Lite in your application.

**Note**: UWP & Windows Phone isn't supported at this time.

## Getting Started

Open `MainWindow.xaml.cs` in Visual Studio and add the following in the `MainWindow` method.

```csharp
Manager manager = Manager.SharedInstance;

Database database = manager.GetDatabase("app");

Dictionary<string, object> properties = new Dictionary<string, object>
{
		{ "title", "Couchbase Mobile"},
		{ "sdk", "C#" }
};

Document document = database.CreateDocument();

document.PutProperties(properties);

Console.WriteLine($"Document ID :: {document.Id}");
Console.WriteLine($"Learning {document.GetProperty("title")} with {document.GetProperty("sdk")}");
```

Click the **Start** button. Notice the document ID and properties are logged to the Application Output.