# flutter_facebook_login

A Flutter plugin for using the native Facebook Login SDKs on Android and iOS.

This plugin uses [the new Gradle 4.1 and Android Studio 3.0 project setup](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

I created this library out of necessity, as there was nothing that fit my needs at the time. I
needed something that was well tested, offered as much control as the native Facebook SDKs, and also
had good code quality.

## How do I use it?

The library tries to closely match the native Android & iOS login SDK APIs where possible.

Since sample code is worth more than one page of documentation, here are the usual cases covered:

```dart
FacebookLogin facebookLogin = new FacebookLogin();
FacebookLoginResult result =
  await facebookLogin.logInWithReadPermissions(['email']);

switch (result.status) {
  case FacebookLoginStatus.loggedIn:
    _sendTokenToServer(result.accessToken.token);
    _showLoggedInUI();
    break;
  case FacebookLoginStatus.cancelledByUser:
    _showConvincingMessageOnUI(
      'It\'s okay, you can trust us! ' // no you can't
      'We won\'t do bad things with your Facebook profile. ' // yes we will
      'Scout\'s honor.' // not actually a Boy Scout
    );
    break;
  case FacebookLoginStatus.error:
    _showErrorOnUI(
      'Something went wrong with the login process.\n'
      'Here\'s the error Facebook gave us: ${result.errorMessage}'
    );
    break;
}
```

You can also change the visual appearance of the login dialog. For example:

```dart
// Let's force the users to login using the login dialog based on WebViews. Yay!
facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
```

## API reference

For complete documentation, just see the [source code](/lib/flutter_facebook_login.dart). Everything is documented there.

## Installation

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherise your app will crash.

### On your Flutter project

Add `flutter_facebook_login` as a dependency to your _pubspec.yaml_ file.

```yaml
dependencies:
  flutter_facebook_login: ^1.0.0
```

Download the new dependency to your project by either running `flutter packages get` inside your
project root folder, or by clicking the "Packages get" link that should appear inside your editor.

### Android

This assumes that you've done the _"Associate Your Package Name and Default Class with Your App"_ and
 _"Provide the Development and Release Key Hashes for Your App"_ in the [the Facebook Login documentation for Android site](https://developers.facebook.com/docs/facebook-login/android).

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.

Once you have the Facebook App ID figured out, youll have to do two things.

First, copy-paste the following to your strings resource file. If you don't have one, just create it.

**<your project root>/android/app/src/main/res/values/strings.xml**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Your App Name here.</string>

    <!-- Replace "000000000000" with your Facebook App ID here. -->
    <string name="facebook_app_id">000000000000</string>
    
    <!-- Replace "000000000000" with your Facebook App ID here. -->
    <string name="fb_login_protocol_scheme">fb000000000000</string>
</resources>
```

Then you'll just have to copy-paste the following to your _Android Manifest_:

**<your project root>/android/app/src/main/AndroidManifest.xml**

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

A sample of a complete AndroidManifest file can be found [here](/example/android/app/src/main/AndroidManifest.xml#L39-L56).

Done!

### iOS

This assumes that you've done the _"Register and Configure Your App with Facebook"_ step in the 
[the Facebook Login documentation for iOS site](https://developers.facebook.com/docs/facebook-login/ios).

After you've done that, find out what your _Facebook App ID_ is. You can find your Facebook App ID in your Facebook App's dashboard in the Facebook developer console.
 
Once you have the Facebook App ID figured out, then you'll just have to copy-paste the following to your _Info.plist_ file, before the ending `</dict></plist>` tags.

**<your project root>/ios/Runner/Info.plist**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace "000000000000" with your Facebook App ID here. -->
            <string>fb000000000000</string>
        </array>
    </dict>
</array>

<key>FacebookAppID</key>

<!-- Replace "000000000000" with your Facebook App ID here. -->
<string>000000000000</string>
<key>FacebookDisplayName</key>

<!-- Replace "YOUR_APP_NAME" with your app name. -->
<string>YOUR_APP_NAME</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
```

A sample of a complete Info.plist file can be found [here](/example/ios/Runner/Info.plist#L49-L70).

Done!
