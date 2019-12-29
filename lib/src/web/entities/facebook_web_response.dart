import 'dart:js';

import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';

class FacebookWebResponse {
  String status;
  String errorMessage;
  FacebookWebAccessToken accessToken;

  static  FacebookWebResponse fromJsObject(JsObject jsObject) {
    FacebookWebResponse webResponse = FacebookWebResponse();
    webResponse.status = _parseStatus(jsObject['status']);
    webResponse.accessToken = FacebookWebAccessToken.fromJsObject(jsObject['authResponse']);
    // webResponse.errorMessage = map['errorMessage'];
    return webResponse;
  }

  Map<String, dynamic> toMap() {
    return {
      "status": this.status,
      "accessToken": this.accessToken.toMap(),
      "s": this.errorMessage,
    };
  }

  static String _parseStatus(String status) {
    switch (status) {
      case 'connected':
        return 'loggedIn';
      case 'not_authorized':
        return 'cancelledByUser';
      default:
        return 'error';
    }
  }
}