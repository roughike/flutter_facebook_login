package com.roughike.facebooklogin.facebooklogin;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FacebookLoginPlugin implements MethodCallHandler {
    private static final String CHANNEL_NAME = "com.roughike/flutter_facebook_login";

    private static final String ERROR_UNKNOWN_LOGIN_BEHAVIOR = "unknown_login_behavior";

    private static final String METHOD_LOG_IN_WITH_READ_PERMISSIONS = "loginWithReadPermissions";
    private static final String METHOD_LOG_IN_WITH_PUBLISH_PERMISSIONS = "loginWithPublishPermissions";
    private static final String METHOD_LOG_OUT = "logOut";
    private static final String METHOD_GET_CURRENT_ACCESS_TOKEN = "getCurrentAccessToken";

    private static final String ARG_LOGIN_BEHAVIOR = "behavior";
    private static final String ARG_PERMISSIONS = "permissions";

    private static final String LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK = "nativeWithFallback";
    private static final String LOGIN_BEHAVIOR_NATIVE_ONLY = "nativeOnly";
    private static final String LOGIN_BEHAVIOR_WEB_ONLY = "webOnly";
    private static final String LOGIN_BEHAVIOR_WEB_VIEW_ONLY = "webViewOnly";

    private final FacebookSignInDelegate delegate;

    private FacebookLoginPlugin(Registrar registrar) {
        delegate = new FacebookSignInDelegate(registrar);
    }

    public static void registerWith(Registrar registrar) {
        final FacebookLoginPlugin plugin = new FacebookLoginPlugin(registrar);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String loginBehaviorStr;
        LoginBehavior loginBehavior;

        switch (call.method) {
            case METHOD_LOG_IN_WITH_READ_PERMISSIONS:
                loginBehaviorStr = call.argument(ARG_LOGIN_BEHAVIOR);
                loginBehavior = loginBehaviorFromString(loginBehaviorStr, result);
                List<String> readPermissions = call.argument(ARG_PERMISSIONS);

                delegate.logInWithReadPermissions(loginBehavior, readPermissions, result);
                break;
            case METHOD_LOG_IN_WITH_PUBLISH_PERMISSIONS:
                loginBehaviorStr = call.argument(ARG_LOGIN_BEHAVIOR);
                loginBehavior = loginBehaviorFromString(loginBehaviorStr, result);
                List<String> publishPermissions = call.argument(ARG_PERMISSIONS);

                delegate.logInWithPublishPermissions(loginBehavior, publishPermissions, result);
                break;
            case METHOD_LOG_OUT:
                delegate.logOut(result);
                break;
            case METHOD_GET_CURRENT_ACCESS_TOKEN:
                delegate.getCurrentAccessToken(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private LoginBehavior loginBehaviorFromString(String loginBehavior, Result result) {
        switch (loginBehavior) {
            case LOGIN_BEHAVIOR_NATIVE_WITH_FALLBACK:
                return LoginBehavior.NATIVE_WITH_FALLBACK;
            case LOGIN_BEHAVIOR_NATIVE_ONLY:
                return LoginBehavior.NATIVE_ONLY;
            case LOGIN_BEHAVIOR_WEB_ONLY:
                return LoginBehavior.WEB_ONLY;
            case LOGIN_BEHAVIOR_WEB_VIEW_ONLY:
                return LoginBehavior.WEB_VIEW_ONLY;
            default:
                result.error(
                        ERROR_UNKNOWN_LOGIN_BEHAVIOR,
                        "setLoginBehavior called with unknown login behavior: "
                                + loginBehavior,
                        null
                );
                return null;
        }
    }

    public static final class FacebookSignInDelegate {
        private final Registrar registrar;
        private final CallbackManager callbackManager;
        private final LoginManager loginManager;
        private final FacebookLoginResultDelegate resultDelegate;

        public FacebookSignInDelegate(Registrar registrar) {
            this.registrar = registrar;
            this.callbackManager = CallbackManager.Factory.create();
            this.loginManager = LoginManager.getInstance();
            this.resultDelegate = new FacebookLoginResultDelegate(callbackManager);

            loginManager.registerCallback(callbackManager, resultDelegate);
            registrar.addActivityResultListener(resultDelegate);
        }

        public void logInWithReadPermissions(
                LoginBehavior loginBehavior, List<String> permissions, Result result) {
            resultDelegate.setPendingResult(METHOD_LOG_IN_WITH_READ_PERMISSIONS, result);

            loginManager.setLoginBehavior(loginBehavior);
            loginManager.logInWithReadPermissions(registrar.activity(), permissions);
        }

        public void logInWithPublishPermissions(
                LoginBehavior loginBehavior, List<String> permissions, Result result) {
            resultDelegate.setPendingResult(METHOD_LOG_IN_WITH_PUBLISH_PERMISSIONS, result);

            loginManager.setLoginBehavior(loginBehavior);
            loginManager.logInWithPublishPermissions(registrar.activity(), permissions);
        }

        public void logOut(Result result) {
            loginManager.logOut();
            result.success(null);
        }

        public void getCurrentAccessToken(Result result) {
            AccessToken accessToken = AccessToken.getCurrentAccessToken();
            Map<String, Object> tokenMap = FacebookLoginResults.accessToken(accessToken);

            result.success(tokenMap);
        }
    }
}
