import 'package:flutter_facebook_login/src/web/entities/facebook_web_access_token.dart';
import 'package:flutter_facebook_login/src/web/entities/facebook_web_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../data/data_web.dart';

void main() {
  group('FacebookWebResponse', () {
    test('Create a instance from fromJsObject', () {
      FacebookWebResponse webResponse = FacebookWebResponse.fromMap(KFacebookWebResponse);
      FacebookWebAccessToken accessToken = webResponse.accessToken;

      expect(accessToken.token, 'test_token');
      expect(accessToken.userId, 'test_user_id');
      expect(accessToken.expires, isNotNull);
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
      FacebookWebResponse webResponse = FacebookWebResponse.fromMap(KFacebookWebResponse);
      Map<String, dynamic> webResponseMap = webResponse.toMap();
      Map<String, dynamic> accessToken = webResponse.accessToken.toMap();
      expect(webResponseMap['status'], 'loggedIn');
      expect(webResponseMap['errorMessage'], 'no_error');

      expect(accessToken['token'], 'test_token');
      expect(accessToken['userId'], 'test_user_id');
      expect(accessToken['expires'], isNotNull);
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
