package com.roughike.facebooklogin.facebooklogin;

import android.content.Intent;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginResult;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class FacebookLoginResultDelegate implements FacebookCallback<LoginResult>, PluginRegistry.ActivityResultListener {
    private static final String ERROR_LOGIN_IN_PROGRESS = "login_in_progress";

    private final CallbackManager callbackManager;
    private MethodChannel.Result pendingResult;

    FacebookLoginResultDelegate(CallbackManager callbackManager) {
        this.callbackManager = callbackManager;
    }

    void setPendingResult(String methodName, MethodChannel.Result result) {
        if (pendingResult != null) {
            result.error(
                    ERROR_LOGIN_IN_PROGRESS,
                    methodName + " called while another Facebook " +
                            "login operation was in progress.",
                    null
            );
        }

        pendingResult = result;
    }

    @Override
    public void onSuccess(LoginResult result) {
        finishWithResult(FacebookLoginResults.success(result));
    }

    @Override
    public void onCancel() {
        finishWithResult(FacebookLoginResults.cancelledByUser);
    }

    @Override
    public void onError(FacebookException error) {
        finishWithResult(FacebookLoginResults.error(error));
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    private void finishWithResult(Object result) {
        if (pendingResult != null) {
            pendingResult.success(result);
            pendingResult = null;
        }
    }
}
