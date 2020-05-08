import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';
import 'package:flutter_facebook_login/src/web/entities/facebook_web_response.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_facebook_login/src/web/interactors/browser_interactor.dart';

// Facebook Web SDK
// DOC: https://developers.facebook.com/docs/javascript/reference/v5.0

class FacebookLoginPlugin {
  static MethodChannel channel;
  static FacebookLoginPlugin instance;
  static final String _ARG_PERMISSIONS = "permissions";
  static const String _METHOD_LOG_IN = "logIn";
  static const String _METHOD_LOG_OUT = "logOut";
  static const String _METHOD_GET_CURRENT_ACCESS_TOKEN = "getCurrentAccessToken";
  BrowserInteractor _browserInteractor;

  FacebookLoginPlugin({BrowserInteractor browserInteractor}) {
    this._browserInteractor = browserInteractor ?? BrowserInteractor();
  }

  static void registerWith(Registrar registrar) {
    channel = MethodChannel('com.roughike/flutter_facebook_login', const StandardMethodCodec(), registrar.messenger);

    instance = FacebookLoginPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) {
    switch (call.method) {
      case _METHOD_LOG_IN:
        final List<dynamic> loginPermissions = call.arguments[_ARG_PERMISSIONS] as List;
        return _login(loginPermissions);
      case _METHOD_LOG_OUT:
        return _logout();
      case _METHOD_GET_CURRENT_ACCESS_TOKEN:
        return _getCurrentAccessToken();
      default:
        var message = "The flutter_facebook_login plugin for web doesn't implement the method '${call.method}'";
        throw PlatformException(code: 'Unimplemented', details: message);
    }
  }

  // LOGIN

  Future<dynamic> _login(List<dynamic> permissions) {
    return _browserInteractor.login(permissions).then((response) {
      String responseStatus = response['status'];
      switch (responseStatus) {
        case 'connected':
          FacebookWebResponse webResponse = FacebookWebResponse.fromMap(response);
          return webResponse.toMap();
          break;
        case 'not_authorized':
        case 'unknown':
          return {"status": 'cancelledByUser', 'errorMessage': 'Cancelled by user.'};
        default:
          return {"status": 'error', 'errorMessage': 'Unknown facebook status from web.'};
      }
    });
  }

  // // LOGOUT

  Future _logout() {
    var response = _browserInteractor.callJSMethod('FB', 'logout', null);
    return Future.value(response != null ? true : false);
  }

  // CURRENT ACCESS TOKEN

  Future _getCurrentAccessToken() {
    var response = _browserInteractor.callJSMethod('FB', 'getAuthResponse', null);
    if (response != null) {
      FacebookWebAccessToken accessToken = FacebookWebAccessToken.fromMap(response);
      return Future.value(accessToken.toMap());
    }
    return Future.value(null);
  }
}
