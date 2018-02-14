import 'dart:async';

import 'package:flutter/services.dart';

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
/// FacebookLogin facebookLogin = new FacebookLogin();
/// FacebookLoginResult result =
///   await facebookLogin.logInWithReadPermissions(['email']);
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
  static const MethodChannel channel =
      const MethodChannel('com.roughike/flutter_facebook_login');

  FacebookLoginBehavior _loginBehavior =
      FacebookLoginBehavior.nativeWithFallback;

  /// Controls how the login dialog should be presented.
  ///
  /// For example, setting this to [FacebookLoginBehavior.webViewOnly] will
  /// render the login dialog using a WebView.
  ///
  /// Updating the login behavior won't do anything immediately; the value is
  /// taken into account just before the login dialog is about to show.
  set loginBehavior(FacebookLoginBehavior behavior) {
    assert(behavior != null, 'The login behavior cannot be null.');
    _loginBehavior = behavior;
  }

  /// Returns whether the user is currently logged in or not.
  ///
  /// Convenience method for checking if the [currentAccessToken] is null.
  Future<bool> get isLoggedIn async => await currentAccessToken != null;

  /// Retrieves the current access token for the application.
  ///
  /// This could be useful for logging in the user automatically in the case
  /// where you don't persist the access token in your Flutter app yourself.
  ///
  /// For example:
  ///
  /// ```dart
  /// final FacebookAccessToken accessToken = await facebookLogin.currentAccessToken;
  ///
  /// if (accessToken != null) {
  ///   _fetchFacebookNewsFeed(accessToken);
  /// } else {
  ///   _showLoginRequiredUI();
  /// }
  /// ```
  ///
  /// If the user is not logged in, this returns null.
  Future<FacebookAccessToken> get currentAccessToken async {
    final Map<String, dynamic> accessToken =
        await channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null) {
      return null;
    }

    return new FacebookAccessToken.fromMap(accessToken);
  }

  /// Logs the user in with the requested read permissions.
  ///
  /// This will throw an exception from the native side if the [permissions]
  /// list contains any permissions that are not classified as read permissions.
  ///
  /// Returns a [FacebookLoginResult] that contains relevant information about
  /// the current login status. For sample code, see the [FacebookLogin] class-
  /// level documentation.
  Future<FacebookLoginResult> logInWithReadPermissions(
    List<String> permissions,
  ) async {
    final Map<String, dynamic> result =
        await channel.invokeMethod('loginWithReadPermissions', {
      'behavior': _currentLoginBehaviorAsString(),
      'permissions': permissions,
    });

    return new FacebookLoginResult._(result);
  }

  /// Logs the user in with the requested publish permissions.
  ///
  /// This will throw an exception from the native side if the [permissions]
  /// list contains any permissions that are not classified as read permissions.
  ///
  /// If called right after receiving a result from [logInWithReadPermissions],
  /// this method may fail. It is recommended to call this method right before
  /// needing a specific publish permission, in a context where it makes sense
  /// to the user. For example, a good place to call this method would be when
  /// the user is about to post something to Facebook by using your app.
  ///
  /// Returns a [FacebookLoginResult] that contains relevant information about
  /// the current login status. For sample code, see the [FacebookLogin] class-
  /// level documentation.
  Future<FacebookLoginResult> loginWithPublishPermissions(
    List<String> permissions,
  ) async {
    final Map<String, dynamic> result =
        await channel.invokeMethod('loginWithPublishPermissions', {
      'behavior': _currentLoginBehaviorAsString(),
      'permissions': permissions,
    });

    return new FacebookLoginResult._(result);
  }

  /// Logs the currently logged in user out.
  ///
  /// NOTE: On iOS, this behaves in an unwanted way. As far the Login SDK is
  /// concerned, the access token and session is cleared upon logging out.
  /// However, when using [FacebookLoginBehavior.webOnly], the WKViewController
  /// managed by Safari remembers the user indefinitely.
  ///
  /// This blocks the user from logging in with any other account than the one
  /// they used the first time. This same issue is also present when using
  /// [FacebookLoginBehavior.nativeWithFallback] in the case where the user
  /// doesn't have a native Facebook app installed.
  ///
  /// Using [FacebookLoginBehavior.webViewOnly] resolves this issue.
  ///
  /// For more, see: https://github.com/roughike/flutter_facebook_login/issues/4
  Future<Null> logOut() async => channel.invokeMethod('logOut');

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

    throw new StateError('Invalid login behavior.');
  }
}

/// Different behaviors for controlling how the Facebook Login dialog should
/// be presented.
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
            ? new FacebookAccessToken.fromMap(map['accessToken'])
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

    throw new StateError('Invalid status: $status');
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

  /// Constructs a new access token instance from a [Map].
  ///
  /// This is used mostly internally by this library, but could be useful if
  /// storing the token locally by using the [toMap] method.
  FacebookAccessToken.fromMap(Map<String, dynamic> map)
      : token = map['token'],
        userId = map['userId'],
        expires = new DateTime.fromMillisecondsSinceEpoch(
          map['expires'],
          isUtc: true,
        ),
        permissions = map['permissions'],
        declinedPermissions = map['declinedPermissions'];

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this access token as JSON and then
  /// storing it locally.
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
          permissions == other.permissions &&
          declinedPermissions == other.declinedPermissions;

  @override
  int get hashCode =>
      token.hashCode ^
      userId.hashCode ^
      expires.hashCode ^
      permissions.hashCode ^
      declinedPermissions.hashCode;
}
