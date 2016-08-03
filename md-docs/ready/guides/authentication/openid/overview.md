---
id: openid-connect
title: OpenID Connect
permalink: ready/guides/authentication/openid/index.html
---

With OpenID Connect now integrated in Couchbase Mobile, you can authenticate users with providers that implement OpenID Connect. This means you won't need to setup an App Server to authenticate users with Google+, PayPal, Yahoo, Active Directory, etc. It works out of the box.

Open ID Connect can be configured in two different ways.

- **Authorization Code Flow:** With this method, you simply set an `OpenIDConnectAuthenticator` authorizer on the replication object. This is the preferred flow for mobile applications, as it supports retrieval and secure storage of the refresh token. This allows clients to avoid forcing users to re-enter username/password information every time their current session expires. Authorization Code Flow is supported in the iOS, Android and .NET Couchbase Lite SDKs.
- **Implicit Flow:** With this method, the retrieval of the ID token takes place on the device. You can then create a user session using the POST `/{db}/_session` endpoint on the Public REST API with the ID token.

When developing with the iOS, Android or .NET Couchbase Lite SDKs, you can take advantage of auth code flow which will handle all the complexity of user authentication for you. And the implicit flow should be used for all other platforms to provide the same user authentication capability. For example in web applications that use PouchDB or interact with Sync Gateway's REST API directly.

## Auth Code Flow

### Sync Gateway Configuration

Sync Gateway supports the OpenID Connect [Authorization Code Flow](http://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth). This flow has the key feature of allowing clients to obtain both an ID token (used for authentication against Sync Gateway) as well as a refresh token (which allows clients to obtain a new ID token without re-prompting for user credentials).

Sync Gateway acts as an intermediary between the client application and the OpenID Connect Provider (OP) when using the auth code flow.

Here is a sample Sync Gateway config file, configured to use the Auth Code Flow.  

```javascript
{
  "interface":":4984",
  "log":["*"],
  "databases": {
    "default": {
      "server": "http://localhost:8091",
      "bucket": "default",
      "oidc": {
        "providers": {
          "google_authcode": {
            "issuer":"https://accounts.google.com",
            "client_id":"yourclientid-uso.apps.googleusercontent.com",
            "validation_key":"your_client_secret",
            "register":true
          }
        }
      }
	}
  }
}
```

Authentication consists of the following steps. Note that these steps are taken care of by Couchbase Lite's Open ID Connect authenticator - they are just provided here for clarity on Sync Gateway's role in authentication. 

1. Client sends an authentication request to Sync Gateway's `_oidc` (or `_oidc_challenge`) endpoint.
2. Sync Gateway returns a redirect to the OP defined in Sync Gateway's config.
3. End-user authenticates against the OP.  
4. On successful authentication, OP redirects the client to Sync Gateway's `_oidc_callback` endpoint with an authorization code.
5. Sync Gateway uses this code to request an ID token and refresh token from the OP.
6. Sync Gateway creates a session for the authenticated user (based on the identity in the ID token), and returns the ID token, refresh token and session to the client.
7. Client uses either the session or ID token for subsequent requests.

## Couchbase Lite Authenticator

You can use an OpenID authenticator using the `Authenticator` class. This method takes an `OIDCLoginCallback` that is called by Couchbase Lite when it is ready to present the consent screen to the user. To create and pass the callback you can:

- Use the OpenID login UIs on the supported platforms (iOS only currently)
- Build your own login UI

The authenticator is then set on a `Replication` instance.

### OpenID login UI

#### iOS

The easiest way to provide this callback is to add the classes in `Extras/OpenIDConnectUI` to your app target. You can [download the iOS SDK](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile) to find those classes. Then simply call `OpenIDController.loginCallback` in the authorizer code.

<div class="tabs"></div>

```objective-c+
CBLOIDCLoginCallback callback = [OpenIDController loginCallback];
replication.authenticator = [CBLAuthenticator OpenIDConnectAuthenticator:callback];
```

```swift+
var callback: CBLOIDCLoginCallback = OpenIDController.loginCallback()
replication.authenticator = CBLAuthenticator.OpenIDConnectAuthenticator(callback)
```

```java+
There is no built-in OpenID login UI for Android.
The next section explains how to build your own.
```

```c+
There is no built-in OpenID login UI for .NET.
The next section explains how to build your own.
```

### Build your own login UI

<div class="tabs"></div>

```objective-c+
[CBLAuthenticator OpenIDConnectAuthenticator:^(NSURL * _Nonnull loginURL, NSURL * _Nonnull redirectURL, CBLOIDCLoginContinuation _Nonnull) {
	// Open the webview in a new view controller
}];
```

```swift+
CBLAuthenticator.OpenIDConnectAuthenticator({(loginURL: NSURL, redirectURL: NSURL, Nonnull: CBLOIDCLoginContinuation) -> Void in
    // Open the webview in a new view controller
})
```

```java+
OpenIDConnectAuthenticatorFactory.createOpenIDConnectAuthenticator(new OIDCLoginCallback() {
	@Override
	public void callback(URL loginURL, URL redirectURL, OIDCLoginContinuation loginContinuation) {
		// Open the webview in a new activity
	}
}, context);
```

```c+
AuthenticatorFactory.CreateOpenIDAuthenticator (Manager.SharedInstance, (Uri loginUrl, Uri authBaseUrl, OIDCLoginContinuation continuation) => {
	// Open the webview in a new controller
});
```

So this callback should open a modal web view starting at the given `loginURL`, then return.

Wait for the web view to redirect to a URL whose host and path are the same as the given redirectURL (the query string after the path will be different, though). Instead of following the redirect, close the web view and call the given continuation block with the redirected URL (and a nil error). Your modal web view UI should provide a way for the user to cancel, probably by adding a Cancel button outside the web view. If the user cancels, call the continuation block with a nil URL and a nil error. If something else goes wrong, like an error loading the login page in the web view, call the continuation block with that error and a nil URL. Usually, the callback would execute some code to open a `UIViewController` for iOS and `AppCompatActivity` for Android. be called when the OpenID Connect login flow requires the user to authenticate with the Originating Party (OP), the site at which they have an account.

**Note:** Just make sure you hold onto the CBLOIDCLoginContinuation block, because you must call it later, or the replicator will never finish logging in.

<div class="tabs"></div>

```java+
public class OpenIDActivity extends AppCompatActivity {
    private static final Map<String, OIDCLoginContinuation> continuationMap = new HashMap<>();

    public static final String INTENT_LOGIN_URL = "loginUrl";
    public static final String INTENT_REDIRECT_URL = "redirectUrl";
    public static final String INTENT_CONTINUATION_KEY = "continuationKey";

    private static final boolean MAP_LOCALHOST_TO_DB_SERVER_HOST = true;

    private String loginUrl;
    private String redirectUrl;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_open_id);

        Intent intent = getIntent();
        loginUrl = intent.getStringExtra(INTENT_LOGIN_URL);
        redirectUrl = intent.getStringExtra(INTENT_REDIRECT_URL);

        WebView webView = (WebView) findViewById(R.id.webview);
        webView.setWebViewClient(new OpenIdWebViewClient());
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl(loginUrl);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_open_id, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_open_id_cancel:
                cancel();
                return true;
        }
        return false;
    }

    private void cancel() {
        Intent intent = getIntent();
        String key = intent.getStringExtra(INTENT_CONTINUATION_KEY);
        OpenIDActivity.deregisterLoginContinuation(key);
        finish();
    }

    private void didFinishAuthentication(String url, String error, String description) {
        Intent intent = getIntent();
        String key = intent.getStringExtra(INTENT_CONTINUATION_KEY);
        if (key != null) {
            OIDCLoginContinuation continuation =
                    OpenIDActivity.getLoginContinuation(key);

            URL authUrl = null;
            if (url != null) {
                try {
                    authUrl = new URL(url);

                    // Workaround for localhost development and test with Android emulators
                    // when the providers such as Google don't allow the callback host to be
                    // a non public domain (e.g. IP addresses):
                    if (authUrl.getHost().equals("localhost") && MAP_LOCALHOST_TO_DB_SERVER_HOST) {
                        Application application = (Application) getApplication();
                        String serverHost = application.getServerDbUrl().getHost();
                        authUrl = new URL(authUrl.toExternalForm().replace("localhost", serverHost));
                    }
                } catch (MalformedURLException e) { /* Shouldn't happen */ }
            }

            continuation.callback(authUrl, (error != null ? new Exception(error) : null));
        }
        OpenIDActivity.deregisterLoginContinuation(key);
    }

    private class OpenIdWebViewClient extends WebViewClient {
        @TargetApi(Build.VERSION_CODES.LOLLIPOP)
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            if (shouldOverrideUrlLoading(request.getUrl()))
                return true;
            else
                return super.shouldOverrideUrlLoading(view, request);
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String urlStr) {
            Uri url = Uri.parse(urlStr);
            if (shouldOverrideUrlLoading(url))
                return true;
            else
                return super.shouldOverrideUrlLoading(view, urlStr);
        }

        public boolean shouldOverrideUrlLoading(Uri url) {
            String urlStr = url.toString();
            if (urlStr.startsWith(redirectUrl)) {
                String error = null;
                String description = null;
                Set<String> queryNames = url.getQueryParameterNames();
                if (queryNames != null) {
                    for (String name : queryNames) {
                        if (name.equals("error"))
                            error = url.getQueryParameter(name);
                        else if (name.equals("error_description"))
                            description = url.getQueryParameter(name);
                    }
                }
                didFinishAuthentication(urlStr, error, description);
                return true;
            }
            return false;
        }
    }

    /** Manage OIDCLoginContinuation callback object */

    public static String registerLoginContinuation(OIDCLoginContinuation continuation) {
        String key = UUID.randomUUID().toString();
        continuationMap.put(key, continuation);
        return key;
    }

    public static OIDCLoginContinuation getLoginContinuation(String key) {
        return continuationMap.get(key);
    }

    public static void deregisterLoginContinuation(String key) {
        continuationMap.remove(key);
    }

    /** A factory to create OIDCLoginCallback callback */

    public static OIDCLoginCallback getOIDCLoginCallback(final Context context) {
        OIDCLoginCallback callback = new OIDCLoginCallback() {
            @Override
            public void callback(final URL loginURL,
                                 final URL redirectURL,
                                 final OIDCLoginContinuation cont) {
                // Ensure to run the code on the UI Thread:
                Handler handler = new Handler(context.getMainLooper());
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        String continuationKey = OpenIDActivity.registerLoginContinuation(cont);
                        Intent intent = new Intent(context, OpenIDActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.putExtra(OpenIDActivity.INTENT_LOGIN_URL, loginURL.toExternalForm());
                        intent.putExtra(OpenIDActivity.INTENT_REDIRECT_URL, redirectURL.toExternalForm());
                        intent.putExtra(OpenIDActivity.INTENT_CONTINUATION_KEY, continuationKey);
                        context.startActivity(intent);
                    }
                });
            }
        };
        return callback;
    }
}
```

```c+
public interface IOIDCLoginControllerDelegate
{
	void OpenIDControllerDidCancel (OIDCLoginController controller);

	void OpenIDController (OIDCLoginController controller, string error, string description);

	void OpenIDController (OIDCLoginController controller, Uri url);
}

public sealed class OIDCLoginController : IOIDCLoginControllerDelegate
{
	private readonly string _redirectURL;
	private readonly OIDCLoginContinuation _callback;
	private UIViewController _presentedUI;
	private UIViewController _UIController;

	public static OIDCCallback LoginCallback {
		get {
			return (loginURL, redirectURL, callback) => new OIDCLoginController (loginURL, redirectURL, callback);
		}
	}

	public Uri LoginUrl { get; }

	public IOIDCLoginControllerDelegate Delegate { get; }

	private UIViewController ViewController {
		get {
			if (_UIController == null) {
				_UIController = new OIDCUIViewController (this);
			}

			return _UIController;
		}
	}

	private OIDCLoginController (Uri loginURL, Uri redirectURL, IOIDCLoginControllerDelegate delegateObj)
	{
		LoginUrl = loginURL;
		_redirectURL = redirectURL.AbsoluteUri;
		Delegate = delegateObj;
	}

	private OIDCLoginController (Uri loginURL, Uri redirectURL, OIDCLoginContinuation callback) :
		this(loginURL, redirectURL, (IOIDCLoginControllerDelegate)null)
	{
		Delegate = this;
		_callback = callback;
		PresentUI ();
	}

	internal bool NavigateToUrl (Uri url)
	{
		if (!url.AbsoluteUri.StartsWith (_redirectURL, StringComparison.InvariantCulture)) {
			return true; // Ordinary URL, let the WebView handle it
		}

		// Look at the URL query to see if it's an error or not:
		var error = default (string);
		var description = default (string);
		var comp = new NSUrlComponents (url, true);
		foreach (var item in comp.QueryItems) {
			if (item.Name == "error") {
				error = item.Value;
			} else if (item.Name == "error_description") {
				description = item.Value;
			}
		}

		if (error != null) {
			Delegate?.OpenIDController (this, error, description);
		} else {
			Delegate?.OpenIDController (this, url);
		}

		return false;
	}

	private void PresentUI ()
	{
		var parent = UIApplication.SharedApplication.KeyWindow.RootViewController;
		_presentedUI = PresentViewControllerIn (parent as UINavigationController);
	}

	private void CloseUI ()
	{
		_presentedUI.DismissViewController (true, () => {
			_presentedUI = null;
		});
	}

	private UINavigationController PresentViewControllerIn (UIViewController parent)
	{
		var viewController = ViewController;
		var navController = new UINavigationController (viewController);
		if (UIDevice.CurrentDevice.UserInterfaceIdiom != UIUserInterfaceIdiom.Phone) {
			navController.ModalPresentationStyle = UIModalPresentationStyle.FormSheet;
		}

		parent.PresentViewController (navController, true, null);
		return navController;
	}

	public void OpenIDControllerDidCancel (OIDCLoginController controller)
	{
		_callback (null, null);
		CloseUI ();
	}

	public void OpenIDController (OIDCLoginController controller, string error, string description)
	{
		var info = new NSDictionary (NSError.LocalizedDescriptionKey, error, 
										NSError.LocalizedFailureReasonErrorKey, description ?? "Login Failed");
		var errorObject = new NSError (NSError.NSUrlErrorDomain, (int)NSUrlError.Unknown, info);
		_callback (null, new NSErrorException(errorObject));
		CloseUI ();
	}

	public void OpenIDController (OIDCLoginController controller, Uri url)
	{
		_callback (url, null);
		CloseUI ();
	}
}
```

## Implicit Flow

### Sync Gateway configuration

Sync Gateway supports the OpenID Connect [Implicit Flow](http://openid.net/specs/openid-connect-core-1_0.html#ImplicitFlowAuth). This flow has the key feature of allowing clients to obtain their own ID token and use it to authenticate against Sync Gateway.

1. Client obtains a signed ID token directly from an OpenID Connect provider.
2. Client includes the ID token (as a bearer token on the Authorization header) on requests made against the Sync Gateway REST API. 
3. Sync Gateway matches the token to a provider in its config based on the issuer and audience in the tokwn.
4. Sync Gateway validates the token, based on the provider definition.
5. On successful validation, Sync Gateway authenticates the user based on the subject and issuer in the token.

Since ID tokens are typically large, the usual approach is to use the ID token to obtain a Sync Gateway session (using the /db/_session REST endpoint), and then use that token for subsequent authentication requests.

Here is a sample Sync Gateway config file, configured to use the Implicit Flow. 

```javascript
{
  "interface":":4984",
  "log":["*"],
  "databases": {
    "default": {
      "server": "http://localhost:8091",
      "bucket": "default",
      "oidc": {
		"providers": {
  		  "google_implicit": {
      		"issuer":"https://accounts.google.com",
      		"client_id":"yourclientid-uso.apps.googleusercontent.com",
      		"register":true
  		  },
  		},
  	  }
	}
  }
}
```

### Client Authentication

With the implicit flow, the mechanism to refresh the token and Sync Gateway session must be handled in the application code. On launch, the application should check if the token has expired. If it has then you must request a new token (Google SignIn for iOS has method called `signInSilently` for this purpose). By doing this, the application can then use the token to create a Sync Gateway session.

![](./img/images.003.png)

1. The Google SignIn SDK prompts the user to login and if successful it returns an ID token to the application.
2. The ID token is used to create a Sync Gateway session by sending a POST `/{db}/_session` request.
3. Sync Gateway returns a cookie session in the response header.
4. The Sync Gateway cookie session is used on the replicator object.

Sync Gateway sessions also have an expiration date. The replication `lastError` property will return a **401 Unauthorized** when it's the case and then the application must retrieve create a new Sync Gateway session and set the new cookie on the replicator.

You can configure your application for Google SignIn by following [this guide](https://developers.google.com/identity/).