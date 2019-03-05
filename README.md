# flutter_facebook_login

[![pub package](https://img.shields.io/pub/v/flutter_facebook_login.svg)](https://pub.dartlang.org/packages/flutter_facebook_login)
 [![Build Status](https://travis-ci.org/roughike/flutter_facebook_login.svg?branch=master)](https://travis-ci.org/roughike/flutter_facebook_login) 
 [![Coverage Status](https://coveralls.io/repos/github/roughike/flutter_facebook_login/badge.svg)](https://coveralls.io/github/roughike/flutter_facebook_login)

A Flutter plugin for using the native Facebook Login SDKs on Android and iOS.

## AndroidX support

* if you want to **avoid AndroidX**, use version 1.2.0.
* for [AndroidX Flutter projects](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility), use versions 2.0.0 and up.

## Installation

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherise your app will crash.

### On your Flutter project

See the [installation instructions on pub](https://pub.dartlang.org/packages/flutter_facebook_login#-installing-tab-).

### Android

This assumes that you've done the _"Associate Your Package Name and Default Class with Your App"_ and
 _"Provide the Development and Release Key Hashes for Your App"_ in the [the Facebook Login documentation for Android site](https://developers.facebook.com/docs/facebook-login/android).

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, youll have to do two things.

First, copy-paste the following to your strings resource file. If you don't have one, just create it.

**\<your project root\>/android/app/src/main/res/values/strings.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Your App Name here.</string>

    <!-- Replace "000000000000" with your Facebook App ID here. -->
    <string name="facebook_app_id">000000000000</string>

    <!--
      Replace "000000000000" with your Facebook App ID here.
      **NOTE**: The scheme needs to start with `fb` and then your ID.
    -->
    <string name="fb_login_protocol_scheme">fb000000000000</string>
</resources>
```

Then you'll just have to copy-paste the following to your _Android Manifest_:

**\<your project root\>/android/app/src/main/AndroidManifest.xml**

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id"/>

<activity android:name="com.facebook.FacebookActivity"
    android:configChanges=
            "keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />

<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

A sample of a complete AndroidManifest file can be found [here](https://github.com/roughike/flutter_facebook_login/blob/master/example/android/app/src/main/AndroidManifest.xml#L39-L56).

Done!

### iOS

This assumes that you've done the _"Register and Configure Your App with Facebook"_ step in the
[the Facebook Login documentation for iOS site](https://developers.facebook.com/docs/facebook-login/ios).
(**Note**: you can skip "Step 2: Set up Your Development Environment").

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, then you'll just have to copy-paste the following to your _Info.plist_ file, before the ending `</dict></plist>` tags.

**\<your project root\>/ios/Runner/Info.plist**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!--
              Replace "000000000000" with your Facebook App ID here.
              **NOTE**: The scheme needs to start with `fb` and then your ID.
            -->
            <string>fb000000000000</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>

<!-- Replace "000000000000" with your Facebook App ID here. -->
<string>000000000000</string>
<key>FacebookDisplayName</key>

<!-- Replace "YOUR_APP_NAME" with your Facebook App name. -->
<string>YOUR_APP_NAME</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
```

A sample of a complete Info.plist file can be found [here](https://github.com/roughike/flutter_facebook_login/blob/master/example/ios/Runner/Info.plist#L49-L70).

Done!

## How do I use it?

The library tries to closely match the native Android & iOS login SDK APIs where possible. For complete API documentation, just see the [source code](https://github.com/roughike/flutter_facebook_login/blob/master/lib/flutter_facebook_login.dart). Everything is documented there.

Since sample code is worth more than one page of documentation, here are the usual cases covered:

```dart
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

final facebookLogin = FacebookLogin();
final result = await facebookLogin.logInWithReadPermissions(['email']);

switch (result.status) {
  case FacebookLoginStatus.loggedIn:
    _sendTokenToServer(result.accessToken.token);
    _showLoggedInUI();
    break;
  case FacebookLoginStatus.cancelledByUser:
    _showCancelledMessage();
    break;
  case FacebookLoginStatus.error:
    _showErrorOnUI(result.errorMessage);
    break;
}
```

You can also change the visual appearance of the login dialog. For example:

```dart
// Let's force the users to login using the login dialog based on WebViews. Yay!
facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
```

The complete API documentation lives with the source code, [which can be found here](https://github.com/roughike/flutter_facebook_login/blob/master/lib/flutter_facebook_login.dart).

### Getting the Facebook profile of a signed in user

For now, this feature isn't going to be integrated into this plugin. See the [discussion here](https://github.com/roughike/flutter_facebook_login/issues/11).

However, you can get do this in four lines of Dart code:

```dart
final result = await facebookSignIn.logInWithReadPermissions(['email']);
final token = result.accessToken.token;
final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
final profile = JSON.decode(graphResponse.body);
```

The `profile` variable will now contain the following information:

```json
{
   "name": "Iiro Krankka",
   "first_name": "Iiro",
   "last_name": "Krankka",
   "email": "iiro.krankka\u0040gmail.com",
   "id": "<user id here>"
}
```