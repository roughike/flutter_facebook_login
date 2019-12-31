import 'dart:async';
import 'dart:js';

class BrowserInteractor {
  Future callJSMethodAsync(String jsVariableName, String jsFunctionName, List args) {
    Completer completer = new Completer();
    var callback = (response) => completer.complete(response);
    var jsArgs = [];

    jsArgs.add(callback);
    if (args!= null && args.isNotEmpty) jsArgs.addAll(args);
    
    // JS context from window browser
    context[jsVariableName].callMethod(jsFunctionName, jsArgs);
    return completer.future;
  }

  dynamic callJSMethod(String jsVariableName, String jsFunctionName, List args) {
    var callback = (response) {};
    var jsArgs = [];

    jsArgs.add(callback);
    if (args!= null && args.isNotEmpty) jsArgs.addAll(args);
    
    // JS context from window browser
    return context[jsVariableName].callMethod(jsFunctionName, jsArgs);
  }
}
