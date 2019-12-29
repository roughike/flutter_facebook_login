import 'dart:js';

import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';
import 'package:flutter_facebook_login/src/web/entities/facebook_web_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    group('FacebookWebResponse', () {
      const kWebAccessToken = {
        'accessToken': 'test_token',
        'userID': 'test_user_id',
        'data_access_expiration_time': 1463378400,
        'permissions': [
          'test_permission_1',
          'test_permission_2',
        ],
        'declinedPermissions': [
          'test_declined_permission_1',
          'test_declined_permission_2',
        ],
      };

      const KFacebookWebResponse = {
        'status': 'connected',
        'authResponse': kWebAccessToken,
        'errorMessage': 'no_error'
      };

      test('Create a instance from fromJsObject', () {
        JsObject jsObject = JsObject.jsify(KFacebookWebResponse);
        FacebookWebResponse webResponse = FacebookWebResponse.fromJsObject(jsObject);
        FacebookWebAccessToken accessToken= webResponse.accessToken;

        expect(accessToken.token, 'test_token');
        expect(accessToken.userId, 'test_user_id');
        expect(accessToken.expires, 1463378400000);
        expect(accessToken.permissions, [
          'test_permission_1',
          'test_permission_2',
        ]);

        expect(accessToken.declinedPermissions, [
          'test_declined_permission_1',
          'test_declined_permission_2',
        ]);

        expect(webResponse.status, 'loggedIn');
        expect(webResponse.errorMessage, 'no_error');
      });

      test('Create a map from toMap', () {
        JsObject jsObject = JsObject.jsify(KFacebookWebResponse);
        FacebookWebResponse webResponse = FacebookWebResponse.fromJsObject(jsObject);
        Map<String, dynamic> webResponseMap = webResponse.toMap();
        Map<String, dynamic> accessToken = webResponse.accessToken.toMap();
        expect(webResponseMap['status'], 'loggedIn');
        expect(webResponseMap['errorMessage'], 'no_error');
        
        expect(accessToken['token'], 'test_token');
        expect(accessToken['userId'], 'test_user_id');
        expect(accessToken['expires'], 1463378400000);
        expect(accessToken['permissions'], [
          'test_permission_1',
          'test_permission_2',
        ]);

        expect(accessToken['declinedPermissions'], [
          'test_declined_permission_1',
          'test_declined_permission_2',
        ]);
      });
    });
}