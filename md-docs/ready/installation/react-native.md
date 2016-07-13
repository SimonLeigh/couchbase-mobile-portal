---
id: rn
title: React Native
---

Install Couchbase Lite in your React Native project. The following guide shows you how to include Couchbase Lite using [rnpm](https://github.com/rnpm/rnpm).

## rnpm

Use the react native module to create a new project.
```
react-native init UntitledApp
cd UntitledApp
npm install --save react-native-couchbase-lite
rnpm link react-native-couchbase-lite
```
You will need to do a few additional steps on each platform.

### iOS

Download the Couchbase Lite iOS SDK from [here](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile) and drag **CouchbaseLite.framework**, **CouchbaseLiteListener.framework**, **CBLRegisterViewCompiler.h**, **libCBLJSViewCompiler.a** in the Xcode project:
![](img/rn-frameworks.png)

### Android

Add the following in **android/app/build.gradle** under the `android` section:
```
packagingOptions {
    exclude 'META-INF/ASL2.0'
    exclude 'META-INF/LICENSE'
    exclude 'META-INF/NOTICE'
}
```

### Getting Started

Open **
```js
class UntitledApp extends Component {
  constructor() {
    super();
    this.state = {
      url: ''
    };
  }
  componentWillMount() {
    ReactCBLite.init(5984, 'admin', 'password', url => {
      console.log(url);
      this.setState({url: url})
    });
    var database = new manager('http://admin:password@localhost:5984/', 'myapp');
    database.createDatabase()
      .then((res) => {
        console.log(res);
      });
  }
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          Couchbase Lite
        </Text>
        <Text style={styles.instructions}>
          {this.state.url}
        </Text>
      </View>
    );
  }
}
```
Reload.
![](img/rn-ios-android.png)
The `database` object provides methods for all CRUD operations and starting replications with Sync Gateway.