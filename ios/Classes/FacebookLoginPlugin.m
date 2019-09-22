#import "FacebookLoginPlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation FacebookLoginPlugin {
  FBSDKLoginManager *loginManager;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"com.roughike/flutter_facebook_login"
            binaryMessenger:[registrar messenger]];
  FacebookLoginPlugin *instance = [[FacebookLoginPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  loginManager = [[FBSDKLoginManager alloc] init];
  return self;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [[FBSDKApplicationDelegate sharedInstance] application:application
                           didFinishLaunchingWithOptions:launchOptions];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  BOOL handled = [[FBSDKApplicationDelegate sharedInstance]
            application:application
                openURL:url
      sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
             annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
  return handled;
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
  BOOL handled =
      [[FBSDKApplicationDelegate sharedInstance] application:application
                                                     openURL:url
                                           sourceApplication:sourceApplication
                                                  annotation:annotation];
  return handled;
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  if ([@"logIn" isEqualToString:call.method]) {
    NSArray *permissions = call.arguments[@"permissions"];

    [self loginWithPermissions:permissions result:result];
  } else if ([@"logOut" isEqualToString:call.method]) {
    [self logOut:result];
  } else if ([@"getCurrentAccessToken" isEqualToString:call.method]) {
    [self getCurrentAccessToken:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)loginWithPermissions:(NSArray *)permissions
                          result:(FlutterResult)result {
  [loginManager
      logInWithPermissions:permissions
            fromViewController:nil
                       handler:^(FBSDKLoginManagerLoginResult *loginResult,
                                 NSError *error) {
                         [self handleLoginResult:loginResult
                                          result:result
                                           error:error];
                       }];
}

- (void)logOut:(FlutterResult)result {
  [loginManager logOut];
  result(nil);
}

- (void)getCurrentAccessToken:(FlutterResult)result {
  FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
  NSDictionary *mappedToken = [self accessTokenToMap:currentToken];

  result(mappedToken);
}

- (void)handleLoginResult:(FBSDKLoginManagerLoginResult *)loginResult
                   result:(FlutterResult)result
                    error:(NSError *)error {
  if (error == nil) {
    if (!loginResult.isCancelled) {
      NSDictionary *mappedToken = [self accessTokenToMap:loginResult.token];

      result(@{
        @"status" : @"loggedIn",
        @"accessToken" : mappedToken,
      });
    } else {
      result(@{
        @"status" : @"cancelledByUser",
      });
    }
  } else {
    result(@{
      @"status" : @"error",
      @"errorMessage" : [error description],
    });
  }
}

- (id)accessTokenToMap:(FBSDKAccessToken *)accessToken {
  if (accessToken == nil) {
    return [NSNull null];
  }

  NSString *userId = [accessToken userID];
  NSArray *permissions = [accessToken.permissions allObjects];
  NSArray *declinedPermissions = [accessToken.declinedPermissions allObjects];
  NSNumber *expires = [NSNumber
      numberWithLongLong:accessToken.expirationDate.timeIntervalSince1970 * 1000.0];

  return @{
    @"token" : accessToken.tokenString,
    @"userId" : userId,
    @"expires" : expires,
    @"permissions" : permissions,
    @"declinedPermissions" : declinedPermissions,
  };
}
@end
