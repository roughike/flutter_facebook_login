import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_matchers.dart';

void main() {
  group('$FacebookLogin', () {
    const MethodChannel channel = const MethodChannel(
      'com.roughike/flutter_facebook_login',
    );

    const kAccessToken = const {
      'token': 'test_token',
      'userId': 'test_user_id',
      'expires': 1463378400000,
      'permissions': const [
        'test_permission_1',
        'test_permission_2',
      ],
      'declinedPermissions': const [
        'test_declined_permission_1',
        'test_declined_permission_2',
      ],
    };

    const kLoggedInResponse = const {
      'status': 'loggedIn',
      'accessToken': kAccessToken,
    };

    const kCancelledByUserResponse = const {'status': 'cancelledByUser'};
    const kErrorResponse = const {
      'status': 'error',
      'errorMessage': 'test error message',
    };

    final List<MethodCall> log = [];
    FacebookLogin sut;

    void setMethodCallResponse(Map<String, dynamic> response) {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future.value(response);
      });
    }

    void expectExpiresDateParsedCorrectly(DateTime dateTime) {
      expect(dateTime.year, 2016);
      expect(dateTime.month, 5);
      expect(dateTime.day, 16);
      expect(dateTime.hour, 6);
      expect(dateTime.minute, 0);
      expect(dateTime.second, 0);
      expect(dateTime.millisecond, 0);
    }

    void expectAccessTokenParsedCorrectly(FacebookAccessToken accessToken) {
      expect(accessToken.token, 'test_token');
      expect(accessToken.userId, 'test_user_id');
      expectExpiresDateParsedCorrectly(accessToken.expires);
      expect(accessToken.permissions, [
        'test_permission_1',
        'test_permission_2',
      ]);

      expect(accessToken.declinedPermissions, [
        'test_declined_permission_1',
        'test_declined_permission_2',
      ]);
    }

    setUp(() {
      sut = new FacebookLogin();
      log.clear();
    });

    test('$FacebookAccessToken#fromMap()', () async {
      final FacebookAccessToken accessToken =
          new FacebookAccessToken.fromMap(kAccessToken);

      expectAccessTokenParsedCorrectly(accessToken);
    });

    test('$FacebookAccessToken#toMap()', () async {
      setMethodCallResponse(kLoggedInResponse);

      final FacebookLoginResult result =
          await sut.logInWithReadPermissions([]);
      final Map<String, dynamic> map = result.accessToken.toMap();

      expect(
        map,

        // Just copy-pasting the kAccessToken here. This is just in case;
        // we could accidentally make this test non-deterministic.
        {
          'token': 'test_token',
          'userId': 'test_user_id',
          'expires': 1463378400000,
          'permissions': [
            'test_permission_1',
            'test_permission_2',
          ],
          'declinedPermissions': [
            'test_declined_permission_1',
            'test_declined_permission_2',
          ],
        },
      );
    });

    test('$FacebookAccessToken equality test', () {
      final FacebookAccessToken first =
          new FacebookAccessToken.fromMap(kAccessToken);
      final FacebookAccessToken second =
          new FacebookAccessToken.fromMap(kAccessToken);

      expect(first, equals(second));
    });

    test('loginBehavior - with null argument', () async {
      setMethodCallResponse(null);

      // Setting a null login behavior is not allowed.
      expect(() => sut.loginBehavior = null, throwsAssertionError);
    });

    test('loginBehavior - nativeWithFallback is the default', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      await sut.logInWithReadPermissions(['email']);
      await sut.loginWithPublishPermissions(['publish_actions']);

      expect(
        log,
        [
          isMethodCall(
            'loginWithReadPermissions',
            arguments: {
              'behavior': 'nativeWithFallback',
              'permissions': [
                'email',
              ],
            },
          ),
          isMethodCall(
            'loginWithPublishPermissions',
            arguments: {
              'behavior': 'nativeWithFallback',
              'permissions': [
                'publish_actions',
              ],
            },
          ),
        ],
      );
    });

    test('loginBehavior - test all options with both login methods', () async {
      setMethodCallResponse(kLoggedInResponse);

      sut.loginBehavior = FacebookLoginBehavior.nativeOnly;
      await sut.logInWithReadPermissions([]);
      await sut.loginWithPublishPermissions([]);

      sut.loginBehavior = FacebookLoginBehavior.webOnly;
      await sut.logInWithReadPermissions([]);
      await sut.loginWithPublishPermissions([]);

      sut.loginBehavior = FacebookLoginBehavior.webViewOnly;
      await sut.logInWithReadPermissions([]);
      await sut.loginWithPublishPermissions([]);

      sut.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
      await sut.logInWithReadPermissions([]);
      await sut.loginWithPublishPermissions([]);

      expect(
        log,
        [
          isReadPermissionLoginWithBehavior('nativeOnly'),
          isPublishPermissionLoginWithBehavior('nativeOnly'),

          isReadPermissionLoginWithBehavior('webOnly'),
          isPublishPermissionLoginWithBehavior('webOnly'),

          isReadPermissionLoginWithBehavior('webViewOnly'),
          isPublishPermissionLoginWithBehavior('webViewOnly'),

          isReadPermissionLoginWithBehavior('nativeWithFallback'),
          isPublishPermissionLoginWithBehavior('nativeWithFallback'),
        ],
      );
    });

    test('loginWithReadPermissions - user logged in', () async {
      setMethodCallResponse(kLoggedInResponse);

      final FacebookLoginResult result = await sut.logInWithReadPermissions([
        'read_permission_1',
        'read_permission_2',
      ]);

      expect(result.status, FacebookLoginStatus.loggedIn);
      expectAccessTokenParsedCorrectly(result.accessToken);

      expect(
        log,
        [
          isMethodCall(
            'loginWithReadPermissions',
            arguments: {
              'behavior': 'nativeWithFallback',
              'permissions': [
                'read_permission_1',
                'read_permission_2',
              ],
            },
          ),
        ],
      );
    });

    test('loginWithReadPermissions - cancelled by user', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final FacebookLoginResult result =
          await sut.logInWithReadPermissions([]);

      expect(result.status, FacebookLoginStatus.cancelledByUser);
      expect(result.accessToken, isNull);
    });

    test('loginWithReadPermissions - error', () async {
      setMethodCallResponse(kErrorResponse);

      final FacebookLoginResult result =
          await sut.logInWithReadPermissions([]);

      expect(result.status, FacebookLoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.accessToken, isNull);
    });

    test('loginWithPublishPermissions - user logged in', () async {
      setMethodCallResponse(kLoggedInResponse);

      final FacebookLoginResult result =
          await sut.loginWithPublishPermissions([
        'publish_permission_1',
        'publish_permission_2',
      ]);

      expect(result.status, FacebookLoginStatus.loggedIn);
      expectAccessTokenParsedCorrectly(result.accessToken);

      expect(
        log,
        [
          isMethodCall(
            'loginWithPublishPermissions',
            arguments: {
              'behavior': 'nativeWithFallback',
              'permissions': [
                'publish_permission_1',
                'publish_permission_2',
              ],
            },
          ),
        ],
      );
    });

    test('loginWithPublishPermissions - cancelled by user', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final FacebookLoginResult result =
          await sut.loginWithPublishPermissions([]);

      expect(result.status, FacebookLoginStatus.cancelledByUser);
      expect(result.accessToken, isNull);
    });

    test('loginWithPublishPermissions - error', () async {
      setMethodCallResponse(kErrorResponse);

      final FacebookLoginResult result =
          await sut.loginWithPublishPermissions([]);

      expect(result.status, FacebookLoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.accessToken, isNull);
    });

    test('logOut test', () async {
      setMethodCallResponse(null);

      await sut.logOut();

      expect(
        log,
        [
          isMethodCall(
            'logOut',
            arguments: null,
          ),
        ],
      );
    });

    test('get isLoggedIn - false when currentAccessToken null', () async {
      setMethodCallResponse(null);

      final bool isLoggedIn = await sut.isLoggedIn;
      expect(isLoggedIn, isFalse);
    });

    test('get isLoggedIn - true when currentAccessToken is not null', () async {
      setMethodCallResponse(kAccessToken);

      final bool isLoggedIn = await sut.isLoggedIn;
      expect(isLoggedIn, isTrue);
    });

    test('get currentAccessToken - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final FacebookAccessToken accessToken = await sut.currentAccessToken;
      expect(accessToken, isNull);
    });

    test('get currentAccessToken - when token returned, parses it properly', () async {
      setMethodCallResponse(kAccessToken);

      final FacebookAccessToken accessToken = await sut.currentAccessToken;
      expectAccessTokenParsedCorrectly(accessToken);
    });
  });
}
