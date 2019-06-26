package com.roughike.facebooklogin.facebooklogin;

import android.Manifest;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import androidx.core.app.ActivityCompat;


import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.core.content.ContextCompat;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.share.model.ShareContent;
import com.facebook.share.model.ShareMediaContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.widget.ShareDialog;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class FacebookLoginPlugin implements MethodCallHandler  {
    private static final String CHANNEL_NAME = "com.roughike/flutter_facebook_login";

    private static final String ERROR_UNKNOWN_LOGIN_BEHAVIOR = "unknown_login_behavior";

    private static final String METHOD_LOG_IN_WITH_READ_PERMISSIONS = "loginWithReadPermissions";
    private static final String METHOD_LOG_IN_WITH_PUBLISH_PERMISSIONS = "loginWithPublishPermissions";
    private static final String METHOD_LOG_OUT = "logOut";
    private static final String METHOD_GET_CURRENT_ACCESS_TOKEN = "getCurrentAccessToken";
    private static final String METHOD_SHARE_FACEBOOK = "shareImageFacebook";
    private static final String METHOD_SHARE_INSTAGRAM = "shareImageInstagram";

    private static final String LOG_EVENT = "logEvent";
    private static final String LOG_SINGUP = "logSignup";



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
            case METHOD_SHARE_FACEBOOK:
                delegate.shareFile((String) call.arguments);
                break;
            case METHOD_SHARE_INSTAGRAM:
                String share = (String) call.argument("share");
                String provider = (String) call.argument("provider");
                delegate.shareFileIg(share, provider);
                break;
            case LOG_EVENT:

                String eventName = (String) call.argument("name");
                String eventParams = (String) call.argument("params");
                delegate.registerEvent(eventName, eventParams);
                break;
            case LOG_SINGUP:
                delegate.registerSingUp((Double) call.arguments);
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
        private static final int CODE_ASK_PERMISSION = 100;

        public FacebookSignInDelegate(Registrar registrar) {
            this.registrar = registrar;
            this.callbackManager = CallbackManager.Factory.create();
            this.loginManager = LoginManager.getInstance();
            this.resultDelegate = new FacebookLoginResultDelegate(callbackManager);
            loginManager.registerCallback(callbackManager, resultDelegate);

            registrar.addActivityResultListener(resultDelegate);
        }

        public void shareFile(String path) {
            File imageFile = new File(registrar.activity().getApplicationContext().getCacheDir(), path);
            String completePath = imageFile.getPath();
            System.out.println(completePath);
            Bitmap bitmap = BitmapFactory.decodeFile(completePath);
            SharePhoto sharePhoto = new SharePhoto.Builder().setBitmap(bitmap).build();
            ShareContent shareContent = new ShareMediaContent.Builder().addMedium(sharePhoto).build();
            ShareDialog shareDialog = new ShareDialog(registrar.activity());
            shareDialog.show(shareContent, ShareDialog.Mode.AUTOMATIC);
        }

        public void shareFileIg(String path, String provider) {
            String type = "image/jpeg";
            if (shouldRequestPermission(path)){
                if (!checkPermisson()) {
                    requestPermission();
                    return;
                }
            }
            createInstagramIntent(type, path, provider);
        }

        public void registerEvent(String event, String paramsContent){
            Bundle params = new Bundle();
            params.putString(AppEventsConstants.EVENT_PARAM_CONTENT, paramsContent);
            AppEventsLogger logger = AppEventsLogger.newLogger(registrar.context());
            logger.logEvent(event, params);
        }

        public void registerSingUp(Double value){
            AppEventsLogger logger = AppEventsLogger.newLogger(registrar.context());
            logger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION, value);
        }

        public static boolean shouldRequestPermission(String path) {
            return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && isPathInExternalStorage(path);
        }

        private static boolean isPathInExternalStorage(String path) {
            File storagePath = Environment.getExternalStorageDirectory();
            return path.startsWith(storagePath.getAbsolutePath());
        }

        private void createInstagramIntent(String type, String mediaPath, String provider){

            // Create the new Intent using the 'Send' action.
            Intent share = new Intent(Intent.ACTION_SEND);
            // Set the MIME type
            share.setType(type);
            // Create the URI from the media
            File media = new File(mediaPath);
            Uri uri = FileProvider.getUriForFile(registrar.context(), provider, media);
            // Add the URI to the Intent.
            share.putExtra(Intent.EXTRA_STREAM, uri);
            share.setType(type);
            share.setPackage("com.instagram.android");
            // Broadcast the Intent.
            registrar.activity().startActivity(Intent.createChooser(share, "Share to"));
        }

        private boolean checkPermisson() {
            if (ContextCompat.checkSelfPermission(registrar.context(), Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    == PackageManager.PERMISSION_GRANTED) {
                return true;
            }
            return false;
        }

        private void requestPermission() {
            ActivityCompat.requestPermissions(registrar.activity(), new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, CODE_ASK_PERMISSION);
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
