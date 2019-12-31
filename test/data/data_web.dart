const kWebAccessToken = {
  'accessToken': 'test_token',
  'userID': 'test_user_id',
  'data_access_expiration_time': 1463378400,
  'expiresIn': 1463378400,  
  'permissions': [
    'test_permission_1',
    'test_permission_2',
  ],
  'declinedPermissions': [
    'test_declined_permission_1',
    'test_declined_permission_2',
  ],
};

const KFacebookWebResponse = {
  'status': 'connected',
  'authResponse': kWebAccessToken,
  'errorMessage': 'no_error'
};
