import 'dart:async';
import 'dart:js';
import 'dart:convert';

class BrowserInteractor {
  Future login(List<dynamic> permissions) {
    Completer completer = new Completer();
    var permissionsStr = permissions.join(',');
    var scope = {'scope': permissionsStr};
    var jsScope = JsObject.jsify(scope);
    var callback = (response) {
      return completer.complete(_parseJSObject(response));
    };

    // JS context from window browser
    context['FB'].callMethod('login', [callback, jsScope]);
    return completer.future;
  }

  Future callJSMethodAsync(String jsVariableName, String jsFunctionName, List args) {
    Completer completer = new Completer();
    var callback = (response) {
      return completer.complete(_parseJSObject(response));
    };
    var jsArgs = [];
    jsArgs.add(callback);
    if (args != null && args.isNotEmpty) jsArgs.addAll(args);

    // JS context from window browser
    context[jsVariableName].callMethod(jsFunctionName, jsArgs);
    return completer.future;
  }

  dynamic callJSMethod(String jsVariableName, String jsFunctionName, List args) {
    var callback = (response) {
      return _parseJSObject(response);
    };
    var jsArgs = [];

    jsArgs.add(callback);
    if (args != null && args.isNotEmpty) jsArgs.addAll(args);

    // JS context from window browser
    return context[jsVariableName].callMethod(jsFunctionName, jsArgs);
  }

  _parseJSObject(object) {
    var result = {};
    var jsonStr = context['JSON'].callMethod('stringify', [object]);
    result = json.decode(jsonStr);
    return result;
  }
}
