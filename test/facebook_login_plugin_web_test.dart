@TestOn("browser")
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/src/web/facebook_login_plugin_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'data/data_web.dart';
import 'mocks/web_mocks.dart';


void main() {
  group('FacebookLoginPluginWeb test', () {
    BrowserInteractorMock browserInteractor;
    FacebookLoginPlugin webPlugin;

    setUp(() {
      browserInteractor = BrowserInteractorMock();
      webPlugin = FacebookLoginPlugin(browserInteractor: browserInteractor);
    });

    group('Login tests', () {
      List permissions = ['email', 'public_profile'];
      Map scope = { 'scope': permissions.join(',')};
      Map callArgs = {'permissions': permissions};
      MethodCall call = MethodCall('logIn', callArgs);

      test('Login success test', () async {
        when(browserInteractor.callJSMethodAsync('FB', 'login', [scope]))
        .thenAnswer((_) => Future.value(KFacebookWebResponse));
        
        var result = await webPlugin.handleMethodCall(call);
        expect(result['status'], 'loggedIn');
        expect(result['accessToken'], isNotNull);
        expect(result['errorMessage'], 'no_error');
      });

      test('Login rejected test', () async {
        when(browserInteractor.callJSMethodAsync('FB', 'login', [scope]))
        .thenAnswer((_) => Future.value({
          'status': 'not_authorized'
        }));
  
        var result = await webPlugin.handleMethodCall(call);
        expect(result['status'], 'cancelledByUser');
        expect(result['accessToken'], null);
        expect(result['errorMessage'], 'Cancelled by user.');
      });

      test('Login error test', () async {
          when(browserInteractor.callJSMethodAsync('FB', 'login', [scope]))
          .thenAnswer((_) => Future.value({
            'status': '...'
          }));
    
          var result = await webPlugin.handleMethodCall(call);
          expect(result['status'], 'error');
          expect(result['accessToken'], null);
          expect(result['errorMessage'], 'Unknown facebook status from web.');
        });
    }); // End group

    group('Logout tests', () {
      MethodCall call = MethodCall('logOut');

      test('Logout success test', () async {
        when(browserInteractor.callJSMethodAsync('FB', 'logout', any))
        .thenAnswer((_) => Future.value(true));
        
        var result = await webPlugin.handleMethodCall(call);
        expect(result, true);
      });

      test('Logout error test', () async {
        when(browserInteractor.callJSMethodAsync('FB', 'logout', any))
        .thenAnswer((_) => Future.value(null));
        
        var result = await webPlugin.handleMethodCall(call);
        expect(result, false);
      });
    }); // End group

    group('Current access token tests', () {
      MethodCall call = MethodCall('getCurrentAccessToken');

      test('Get access token success test', () async {
        when(browserInteractor.callJSMethod('FB', 'getAuthResponse', any))
        .thenAnswer((_) => kWebAccessToken);
        
        var result = await webPlugin.handleMethodCall(call);
        expect(result['token'], 'test_token');
        expect(result['userId'], 'test_user_id');
        expect(result['expires'], 1463378400);
        expect(result['permissions'], isNotNull);
        expect(result['declinedPermissions'], isNotNull);
      });

      test('Get access token error test', () async {
        when(browserInteractor.callJSMethod('FB', 'getAuthResponse', any))
        .thenAnswer((_) => null);
        
        var result = await webPlugin.handleMethodCall(call);
        expect(result, isNull);
      });
    }); // End group
  });
}
