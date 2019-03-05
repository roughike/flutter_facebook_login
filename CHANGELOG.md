## 2.0.0

* **Breaking change:** migrate from the deprecated original Android Support Library to AndroidX. This shouldn't result in any functional changes, but it requires any Android apps using this plugin to [also migrate](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility) if they're using the original support library.

## 1.2.0

* Update Android & iOS Facebook Login dependencies
* Fix failing `equals()` in `FacebookAccessToken`
* Fix "could not find class 'android.view.autofill.AutofillManager'" error on Android
* Fix the "{com.facebook.sdk:FBSDKErrorDeveloperMessageKey=Unknown error building URL.}" error on iOS
* Add `FacebookAccessToken#isValid()` for checking if the access token is expired or not

**Breaking change:**

The `FacebookLogin#isLoggedIn` now checks if the `currentAccessToken` is expired or not, while it previously only checked if `currentAccessToken` was non-null.

## 1.1.1

* Fix occasional hangs/freezes by introducing a slight artifical delay after getting the result from Facebook login.

## 1.1.0

* Dart 2 support! There should not be any breaking changes. Please do file issues if you have problems.

## 1.0.3

* Fixed potential crash and documented iOS logout issues when using the webOnly login behavior.

## 1.0.2

* Added new `isLoggedIn` and `currentAccessToken` getters which make it easier to log the user in automatically.

## 1.0.1

* Fixed the podspec definition for the iOS project.

## 1.0.0

* Initial release.
