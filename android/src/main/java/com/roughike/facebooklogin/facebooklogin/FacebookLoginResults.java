package com.roughike.facebooklogin.facebooklogin;

import com.facebook.AccessToken;
import com.facebook.FacebookException;
import com.facebook.login.LoginResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class FacebookLoginResults {
    static final Map<String, String> cancelledByUser = new HashMap<String, String>() {{
        put("status", "cancelledByUser");
    }};

    static Map<String, Object> success(LoginResult loginResult) {
        final AccessToken accessToken = loginResult.getAccessToken();
        final Map<String, Object> accessTokenMap = FacebookLoginResults.accessToken(accessToken);

        return new HashMap<String, Object>() {{
            put("status", "loggedIn");
            put("accessToken", accessTokenMap);
        }};
    }

    static Map<String, String> error(final FacebookException error) {
        return new HashMap<String, String>() {{
            put("status", "error");
            put("errorMessage", error.getMessage());
        }};
    }

    static Map<String, Object> accessToken(final AccessToken accessToken) {
        if (accessToken == null) {
            return null;
        }

        return new HashMap<String, Object>() {{
            put("token", accessToken.getToken());
            put("userId", accessToken.getUserId());
            put("expires", accessToken.getExpires().getTime());
            put("permissions", new ArrayList<>(accessToken.getPermissions()));
            put("declinedPermissions", new ArrayList<>(accessToken.getDeclinedPermissions()));
        }};
    }
}
