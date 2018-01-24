import 'package:flutter_test/flutter_test.dart';

Matcher isReadPermissionLoginWithBehavior(String behavior) {
  return isMethodCall(
    'loginWithReadPermissions',
    arguments: {
      'behavior': behavior,
      'permissions': [],
    },
  );
}

Matcher isPublishPermissionLoginWithBehavior(String behavior) {
  return isMethodCall(
    'loginWithPublishPermissions',
    arguments: {
      'behavior': behavior,
      'permissions': [],
    },
  );
}