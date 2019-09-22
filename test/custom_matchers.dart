import 'package:flutter_test/flutter_test.dart';

Matcher isLoginWithBehavior(String behavior) {
  return isMethodCall(
    'logIn',
    arguments: {
      'behavior': behavior,
      'permissions': [],
    },
  );
}
