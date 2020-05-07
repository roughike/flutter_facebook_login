class FacebookWebAccessToken {
  String token;
  String userId;
  int expires;
  List permissions = [];
  List declinedPermissions = [];

  static FacebookWebAccessToken fromMap(Map mapObject) {
    FacebookWebAccessToken accessToken = FacebookWebAccessToken();
    accessToken.token = mapObject['accessToken'];
    accessToken.userId = mapObject['userID'];
    accessToken.expires = mapObject['expiresIn']; // facebook web token has 2 hours to expire
    accessToken.expires = DateTime.now().millisecondsSinceEpoch + (accessToken.expires * 1000);
    if (mapObject['permissions'] != null) {
      accessToken.permissions = mapObject['permissions'];
    }

    if (mapObject['declinedPermissions'] != null) {
      accessToken.declinedPermissions = mapObject['declinedPermissions'];
    }

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
