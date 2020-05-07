import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final FacebookLogin facebookSignIn = FacebookLogin();

  String _message = 'Log in/out by pressing the buttons below.';
  String _fbToken = '';
  bool _isLogged = false;

  Future<Null> _login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('Logged in!');
        _showToken(accessToken);
        setState(() => _isLogged = true);
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLogged = false);
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLogged = false);
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
    setState(() {
      _isLogged = false;
      _fbToken = '';
    });
    _showMessage('Logged out.');
  }

  Future<Null> _getToken() async {
    setState(() => _fbToken = 'Loading...');
    FacebookAccessToken facebookAccessToken = await facebookSignIn.currentAccessToken;
    _showToken(facebookAccessToken);
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void _showToken(FacebookAccessToken accessToken) {
    if (accessToken == null) {
      setState(() => _fbToken = 'Invalid token.');
      return;
    }
    setState(() {
      _fbToken = '''
         Token: ${accessToken?.token?.substring(0, 40)} ...
         User id: ${accessToken?.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_message),
              Text(_fbToken),
              RaisedButton(
                onPressed: _login,
                child: Text('Log in'),
              ),
              RaisedButton(
                onPressed: _logOut,
                child: Text('Logout'),
              ),
              _isLogged
                  ? RaisedButton(
                      onPressed: _getToken,
                      child: Text('Get token'),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
