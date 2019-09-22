import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'src/clock.dart';

/// FacebookLogin is a plugin for authenticating your users using the native
/// Android & iOS Facebook Login SDKs.
///
/// The login methods return a [FacebookLoginResult] that contains relevant
/// information about whether the user logged in, cancelled the login dialog,
/// or if the login flow resulted in an error.
///
/// For example, this sample code illustrates how to handle the different
/// cases:
///
/// ```dart
/// final facebookLogin = FacebookLogin();
/// final result =
///   await facebookLogin.logInWithPermissions(['email']);
///
/// switch (result.status) {
///   case FacebookLoginStatus.loggedIn:
///     _sendTokenToServer(result.accessToken.token);
///     _showLoggedInUI();
///     break;
///   case FacebookLoginStatus.cancelledByUser:
///     _showConvincingMessageOnUI();
///     break;
///   case FacebookLoginStatus.error:
///     _showErrorOnUI();
///     break;
/// }
///
/// Before using this plugin, some initial setup is required for the Android
/// and iOS clients. See the README for detailed instructions.
/// ```
class FacebookLogin {
  static const channel = MethodChannel('com.roughike/flutter_facebook_login');

  FacebookLoginBehavior _loginBehavior =
      FacebookLoginBehavior.nativeWithFallback;

  /// Controls how the login dialog should be presented.
  ///
  /// For example, setting this to [FacebookLoginBehavior.webViewOnly] will
  /// render the login dialog using a WebView.
  ///
  /// NOTE: Updating the login behavior won't do anything immediately; the value
  /// is taken into account just before the login dialog is about to show.
  ///
  /// Ignored on iOS, as it's not supported by the iOS Facebook Login SDK anymore.
  set loginBehavior(FacebookLoginBehavior behavior) {
    assert(behavior != null, 'The login behavior cannot be null.');
    _loginBehavior = behavior;
  }

  /// Returns whether the user is currently logged in and the access token is
  /// still valid or not.
  ///
  /// Convenience method for checking if the [currentAccessToken] is null and not
  /// expired.
  Future<bool> get isLoggedIn async =>
      (await currentAccessToken)?.isValid() ?? false;

  /// Retrieves the current access token for the application.
  ///
  /// This could be useful for logging in the user automatically in the case
  /// where you don't persist the access token in your Flutter app yourself.
  ///
  /// For example:
  ///
  /// ```dart
  /// final accessToken = await facebookLogin.currentAccessToken;
  ///
  /// if (accessToken != null && accessToken.isValid()) {
  ///   _fetchFacebookNewsFeed(accessToken);
  /// } else {
  ///   _showLoginRequiredUI();
  /// }
  /// ```
  ///
  /// NOTE: This might return an access token that has expired. If you need to be
  /// sure that the token is still valid, call [isValid] on the access token.
  Future<FacebookAccessToken> get currentAccessToken async {
    final Map<dynamic, dynamic> accessToken =
        await channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null) {
      return null;
    }

    return FacebookAccessToken.fromMap(accessToken.cast<String, dynamic>());
  }

  /// Logs the user in with the requested read permissions.
  ///
  /// This will throw an exception from the native side if the [permissions]
  /// list contains any permissions that are not classified as read permissions.
  ///
  /// Returns a [FacebookLoginResult] that contains relevant information about
  /// the current login status. For sample code, see the [FacebookLogin] class-
  /// level documentation.
  Future<FacebookLoginResult> logIn(
    List<String> permissions,
  ) async {
    final Map<dynamic, dynamic> result =
        await channel.invokeMethod('logIn', {
      'behavior': _currentLoginBehaviorAsString(),
      'permissions': permissions,
    });

    return _deliverResult(
        FacebookLoginResult._(result.cast<String, dynamic>()));
  }

  /// Logs the currently logged in user out.
  ///
  /// NOTE: On iOS, this behaves in an unwanted way. As far the Login SDK is
  /// concerned, the access token and session is cleared upon logging out.
  /// However, ViewController managed by Safari remembers the user indefinitely.
  ///
  /// This blocks the user from logging in with any other account than the one
  /// they used the first time.
  ///
  /// For more, see: https://github.com/facebook/facebook-swift-sdk/issues/215
  Future<void> logOut() async => channel.invokeMethod('logOut');

  String _currentLoginBehaviorAsString() {
    assert(_loginBehavior != null, 'The login behavior was unexpectedly null.');

    switch (_loginBehavior) {
      case FacebookLoginBehavior.nativeWithFallback:
        return 'nativeWithFallback';
      case FacebookLoginBehavior.nativeOnly:
        return 'nativeOnly';
      case FacebookLoginBehavior.webOnly:
        return 'webOnly';
      case FacebookLoginBehavior.webViewOnly:
        return 'webViewOnly';
    }

    throw StateError('Invalid login behavior.');
  }

  /// There's a weird bug where calling Navigator.push (or any similar method)
  /// straight after getting a result from the method channel causes the app
  /// to hang.
  ///
  /// As a hack/workaround, we add a new task to the task queue with a slight
  /// delay, using the [Future.delayed] constructor.
  ///
  /// For more context, see this issue:
  /// https://github.com/roughike/flutter_facebook_login/issues/14
  Future<T> _deliverResult<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }
}

/// Different behaviors for controlling how the Facebook Login dialog should
/// be presented.
///
/// Ignored on iOS, as it's not supported by the iOS Facebook Login SDK anymore.
enum FacebookLoginBehavior {
  /// Login dialog should be rendered by the native Android or iOS Facebook app.
  ///
  /// If the user doesn't have a native Facebook app installed, this falls back
  /// to using the web browser based auth dialog.
  ///
  /// This is the default login behavior.
  ///
  /// Might have logout issues on iOS; see the [FacebookLogin.logOut] documentation.
  nativeWithFallback,

  /// Login dialog should be rendered by the native Android or iOS Facebook app
  /// only.
  ///
  /// If the user hasn't installed the Facebook app on their device, the
  /// login will fail when using this behavior.
  ///
  /// On iOS, this behaves like the [nativeWithFallback] option. This is because
  /// the iOS Facebook Login SDK doesn't support the native-only login.
  nativeOnly,

  /// Login dialog should be rendered by using a web browser.
  ///
  /// Might have logout issues on iOS; see the [FacebookLogin.logOut] documentation.
  webOnly,

  /// Login dialog should be rendered by using a WebView.
  webViewOnly,
}

/// The result when the Facebook login flow has completed.
///
/// The login methods always return an instance of this class, whether the
/// user logged in, cancelled or the login resulted in an error. To handle
/// the different possible scenarios, first see what the [status] is.
///
/// To see a comprehensive example on how to handle the different login
/// results, see the [FacebookLogin] class-level documentation.
class FacebookLoginResult {
  /// The status after a Facebook login flow has completed.
  ///
  /// This affects the [accessToken] and [errorMessage] variables and whether
  /// they're available or not. If the user cancelled the login flow, both
  /// [accessToken] and [errorMessage] are null.
  final FacebookLoginStatus status;

  /// The access token for using the Facebook APIs, obtained after the user has
  /// successfully logged in.
  ///
  /// Only available when the [status] equals [FacebookLoginStatus.loggedIn],
  /// otherwise null.
  final FacebookAccessToken accessToken;

  /// The error message when the log in flow completed with an error.
  ///
  /// Only available when the [status] equals [FacebookLoginStatus.error],
  /// otherwise null.
  final String errorMessage;

  FacebookLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        accessToken = map['accessToken'] != null
            ? FacebookAccessToken.fromMap(
                map['accessToken'].cast<String, dynamic>(),
              )
            : null,
        errorMessage = map['errorMessage'];

  static FacebookLoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return FacebookLoginStatus.loggedIn;
      case 'cancelledByUser':
        return FacebookLoginStatus.cancelledByUser;
      case 'error':
        return FacebookLoginStatus.error;
    }

    throw StateError('Invalid status: $status');
  }
}

/// The status after a Facebook login flow has completed.
enum FacebookLoginStatus {
  /// The login was successful and the user is now logged in.
  loggedIn,

  /// The user cancelled the login flow, usually by closing the Facebook
  /// login dialog.
  cancelledByUser,

  /// The Facebook login completed with an error and the user couldn't log
  /// in for some reason.
  error,
}

/// The access token for using Facebook APIs.
///
/// Includes the token itself, along with useful metadata about it, such as the
/// associated user id, expiration date and permissions that the token contains.
class FacebookAccessToken {
  /// The access token returned by the Facebook login, which can be used to
  /// access Facebook APIs.
  final String token;

  /// The id for the user that is associated with this access token.
  final String userId;

  /// The date when this access token expires.
  final DateTime expires;

  /// The list of accepted permissions associated with this access token.
  ///
  /// These are the permissions that were requested with last login, and which
  /// the user approved. If permissions have changed since the last login, this
  /// list might be outdated.
  final List<String> permissions;

  /// The list of declined permissions associated with this access token.
  ///
  /// These are the permissions that were requested, but the user didn't
  /// approve. Similarly to [permissions], this list might be outdated if these
  /// permissions have changed since the last login.
  final List<String> declinedPermissions;

  /// Is this access token expired or not?
  ///
  /// If the access token has not been expired yet, returns true. Otherwise,
  /// returns false.
  bool isValid() => Clock.now().isBefore(expires);

  /// Constructs a access token instance from a [Map].
  ///
  /// This is used mostly internally by this library.
  FacebookAccessToken.fromMap(Map<String, dynamic> map)
      : token = map['token'],
        userId = map['userId'],
        expires = DateTime.fromMillisecondsSinceEpoch(
          map['expires'],
          isUtc: true,
        ),
        permissions = map['permissions'].cast<String>(),
        declinedPermissions = map['declinedPermissions'].cast<String>();

  /// Transforms this access token to a [Map].
  ///
  /// This is used mostly internally by this library.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'userId': userId,
      'expires': expires.millisecondsSinceEpoch,
      'permissions': permissions,
      'declinedPermissions': declinedPermissions,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacebookAccessToken &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          userId == other.userId &&
          expires == other.expires &&
          const IterableEquality().equals(permissions, other.permissions) &&
          const IterableEquality().equals(
            declinedPermissions,
            other.declinedPermissions,
          );

  @override
  int get hashCode =>
      token.hashCode ^
      userId.hashCode ^
      expires.hashCode ^
      permissions.hashCode ^
      declinedPermissions.hashCode;
}
