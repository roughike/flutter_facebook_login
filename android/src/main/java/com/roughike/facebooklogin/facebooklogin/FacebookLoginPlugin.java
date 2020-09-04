package com.roughike.facebooklogin.facebooklogin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FacebookLoginPlugin implements FlutterPlugin, ActivityAware {
    private static final String CHANNEL_NAME = "com.roughike/flutter_facebook_login";

    private MethodChannel channel;
    private FacebookLoginMethodCallHandler handler;

    /* -------------- Old API Behaviour -------------- */
    public static void registerWith(Registrar registrar) {
        final FacebookLoginPlugin plugin = new FacebookLoginPlugin();
        plugin.setupChannel(registrar.messenger(), registrar);
    }

    /* ----------- FlutterPlugin Behaviour ----------- */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        setupChannel(binding.getBinaryMessenger(), null);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        teardownChannel();
    }

    private void setupChannel(BinaryMessenger messenger, Registrar registrar) {
        FacebookLoginMethodCallHandler.registrar = registrar;
        handler = new FacebookLoginMethodCallHandler();
        channel = new MethodChannel(messenger, CHANNEL_NAME);
        channel.setMethodCallHandler(handler);
    }

    private void teardownChannel() {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    /* ----------- ActivityAware Behaviour ----------- */
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        FacebookLoginMethodCallHandler.binding = binding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        FacebookLoginMethodCallHandler.binding = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        FacebookLoginMethodCallHandler.binding = binding;
    }

    @Override
    public void onDetachedFromActivity() {
        FacebookLoginMethodCallHandler.binding = null;
    }

}
