import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/src/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_matchers.dart';

void main() {
  group('$FacebookLogin', () {
    const channel = MethodChannel('com.roughike/flutter_facebook_login');

    final beforeExpiry =
        DateTime.fromMillisecondsSinceEpoch(1463378399999, isUtc: true);

    final afterExpiry =
        DateTime.fromMillisecondsSinceEpoch(1463378400001, isUtc: true);

    const kAccessToken = {
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
    };

    const kLoggedInResponse = {
      'status': 'loggedIn',
      'accessToken': kAccessToken,
    };

    const kCancelledByUserResponse = {'status': 'cancelledByUser'};
    const kErrorResponse = {
      'status': 'error',
      'errorMessage': 'test error message',
    };

    final log = <MethodCall>[];
    FacebookLogin sut;

    void setMethodCallResponse(Map<String, dynamic> response) {
      channel.setMockMethodCallHandler((methodCall) {
        log.add(methodCall);
        return Future.value(response);
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
      sut = FacebookLogin();
      log.clear();
    });

    tearDown(() {
      Clock.dateTimeResolver = defaultDateTimeResolver;
    });

    test('$FacebookAccessToken#fromMap()', () async {
      final accessToken = FacebookAccessToken.fromMap(kAccessToken);

      expectAccessTokenParsedCorrectly(accessToken);
    });

    test('$FacebookAccessToken#toMap()', () async {
      setMethodCallResponse(kLoggedInResponse);

      final result = await sut.logIn([]);
      final map = result.accessToken.toMap();

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
      final first = FacebookAccessToken.fromMap(kAccessToken);
      final second = FacebookAccessToken.fromMap(kAccessToken);

      expect(first, equals(second));
    });

    test('loginBehavior - with null argument', () async {
      setMethodCallResponse(null);

      // Setting a null login behavior is not allowed.
      expect(() => sut.loginBehavior = null, throwsAssertionError);
    });

    test('loginBehavior - nativeWithFallback is the default', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      await sut.logIn(['email']);

      expect(
        log,
        [
          isMethodCall(
            'logIn',
            arguments: {
              'behavior': 'nativeWithFallback',
              'permissions': [
                'email',
              ],
            },
          ),
        ],
      );
    });

    test('loginBehavior - test all options with both login methods', () async {
      setMethodCallResponse(kLoggedInResponse);

      sut.loginBehavior = FacebookLoginBehavior.nativeOnly;
      await sut.logIn([]);

      sut.loginBehavior = FacebookLoginBehavior.webOnly;
      await sut.logIn([]);

      sut.loginBehavior = FacebookLoginBehavior.webViewOnly;
      await sut.logIn([]);

      sut.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
      await sut.logIn([]);

      expect(
        log,
        [
          isLoginWithBehavior('nativeOnly'),
          isLoginWithBehavior('webOnly'),
          isLoginWithBehavior('webViewOnly'),
          isLoginWithBehavior('nativeWithFallback'),
        ],
      );
    });

    test('login - user logged in', () async {
      setMethodCallResponse(kLoggedInResponse);

      final result = await sut.logIn([
        'read_permission_1',
        'read_permission_2',
      ]);

      expect(result.status, FacebookLoginStatus.loggedIn);
      expectAccessTokenParsedCorrectly(result.accessToken);

      expect(
        log,
        [
          isMethodCall(
            'logIn',
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

    test('login - cancelled by user', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final result = await sut.logIn([]);

      expect(result.status, FacebookLoginStatus.cancelledByUser);
      expect(result.accessToken, isNull);
    });

    test('login - error', () async {
      setMethodCallResponse(kErrorResponse);

      final result = await sut.logIn([]);

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

      final isLoggedIn = await sut.isLoggedIn;
      expect(isLoggedIn, isFalse);
    });

    test('get isLoggedIn - false when currentAccessToken is expired', () async {
      setMethodCallResponse(null);

      Clock.dateTimeResolver = () => afterExpiry;

      final isLoggedIn = await sut.isLoggedIn;
      expect(isLoggedIn, isFalse);
    });

    test('get isLoggedIn - true when currentAccessToken is not null and valid',
        () async {
      setMethodCallResponse(kAccessToken);

      Clock.dateTimeResolver = () => beforeExpiry;

      final isLoggedIn = await sut.isLoggedIn;
      expect(isLoggedIn, isTrue);
    });

    test('get currentAccessToken - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final accessToken = await sut.currentAccessToken;
      expect(accessToken, isNull);
    });

    test('get currentAccessToken - when token returned, parses it properly',
        () async {
      setMethodCallResponse(kAccessToken);

      final accessToken = await sut.currentAccessToken;
      expectAccessTokenParsedCorrectly(accessToken);
    });

    test('FacebookAccessToken#isValid() - when not expired, returns true',
        () async {
      setMethodCallResponse(kAccessToken);

      Clock.dateTimeResolver = () => beforeExpiry;

      final accessToken = await sut.currentAccessToken;
      expect(accessToken.isValid(), isTrue);
    });

    test('FacebookAccessToken#isValid() - when expired, returns false',
        () async {
      setMethodCallResponse(kAccessToken);

      Clock.dateTimeResolver = () => afterExpiry;

      final accessToken = await sut.currentAccessToken;
      expect(accessToken.isValid(), isFalse);
    });
  });
}
