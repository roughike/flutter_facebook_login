import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';

class FacebookWebResponse {
  String status;
  String errorMessage;
  FacebookWebAccessToken accessToken;

  static  FacebookWebResponse fromMap(Map mapObject) {
    FacebookWebResponse webResponse = FacebookWebResponse();
    webResponse.status = _parseStatus(mapObject['status']);
    webResponse.accessToken = FacebookWebAccessToken.fromMap(mapObject['authResponse']);
    
    if (mapObject['errorMessage'] != null) {
      webResponse.errorMessage = mapObject['errorMessage'];
    }
    
    return webResponse;
  }

  Map<String, dynamic> toMap() {
    return {
      "status": this.status,
      "accessToken": this.accessToken.toMap(),
      "errorMessage": this.errorMessage,
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
