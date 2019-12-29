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
    accessToken.expires = jsObject['expiresIn'];

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