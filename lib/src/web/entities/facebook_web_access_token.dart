import 'dart:js';

class FacebookWebAccessToken {
  String token;
  String userId;
  int expires;
  List permissions = [];
  List declinedPermissions = [];

  static FacebookWebAccessToken fromJsObject(JsObject jsObject) {
    FacebookWebAccessToken accessToken = FacebookWebAccessToken();
    accessToken.token = jsObject['accessToken'];
    accessToken.userId = jsObject['userID'];
    accessToken.expires = jsObject['data_access_expiration_time'] * 1000;

    return accessToken;
  }

  Map<String, dynamic> toMap() {
    return {
      "token": this.token,
      "userId": this.userId,
      "expires": this.expires,
      "permissions": this.permissions,
      "declinedPermissions": this.declinedPermissions,
    };
  }
}