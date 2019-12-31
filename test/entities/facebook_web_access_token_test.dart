import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/data_web.dart';

void main() {
    group('FacebookWebAccessToken.', () {
      test('Create a instance from from object', () {
        FacebookWebAccessToken accessToken = FacebookWebAccessToken.fromMap(kWebAccessToken);
        expect(accessToken.token, 'test_token');
        expect(accessToken.userId, 'test_user_id');
        expect(accessToken.expires, 1463378400);
        expect(accessToken.permissions, [
          'test_permission_1',
          'test_permission_2',
        ]);

        expect(accessToken.declinedPermissions, [
          'test_declined_permission_1',
          'test_declined_permission_2',
        ]);
      });

      test('Create a map from to map', () {
        FacebookWebAccessToken accessToken = FacebookWebAccessToken.fromMap(kWebAccessToken);
        Map<String, dynamic> accessTokenMap = accessToken.toMap();
        
        expect(accessTokenMap['token'], 'test_token');
        expect(accessTokenMap['userId'], 'test_user_id');
        expect(accessTokenMap['expires'], 1463378400);
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