import 'dart:js';

import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    group('FacebookWebAccessToken', () {
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

      test('Create a instance from fromJsObject', () {
        JsObject jsObject = JsObject.jsify(kWebAccessToken);
        FacebookWebAccessToken accessToken = FacebookWebAccessToken.fromJsObject(jsObject);

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
      });

      test('Create a map from toMap', () {
        JsObject jsObject = JsObject.jsify(kWebAccessToken);
        FacebookWebAccessToken accessToken = FacebookWebAccessToken.fromJsObject(jsObject);
        Map<String, dynamic> accessTokenMap = accessToken.toMap();
        
        expect(accessTokenMap['token'], 'test_token');
        expect(accessTokenMap['userId'], 'test_user_id');
        expect(accessTokenMap['expires'], 1463378400000);
        expect(accessTokenMap['permissions'], [
          'test_permission_1',
          'test_permission_2',
        ]);

        expect(accessTokenMap['declinedPermissions'], [
          'test_declined_permission_1',
          'test_declined_permission_2',
        ]);
      });
    });
}