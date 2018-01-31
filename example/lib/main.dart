import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String _info = 'Loading...';
  String _accessTokenResult = 'Log in/out by pressing the buttons below.';

  @override
  void initState() {
    super.initState();
    _updateInfo();
  }

  Future _updateInfo() async {
    final bool isLoggedIn = await facebookSignIn.isLoggedIn;
    final FacebookAccessToken accessToken = await facebookSignIn.currentAccessToken;

    String newInfo = 'Logged in: $isLoggedIn';

    if (isLoggedIn) {
      newInfo += '''\n
Token: ${accessToken.token}
User id: ${accessToken.userId}
Expires: ${accessToken.expires}
Permissions: ${accessToken.permissions}
Declined permissions: ${accessToken.declinedPermissions}
      ''';
    }

    setState(() {
      _info = newInfo;
    });
  }

  Future<Null> _login() async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        // TODO (roughike): make a better sample app
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }

    _updateInfo();
  }

  Future<Null> _logOut() async {
    await facebookSignIn.logOut();
    _updateInfo();
  }

  void _showMessage(String message) {
    setState(() {
      _accessTokenResult = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(_info),
              new Text(_accessTokenResult),
              new RaisedButton(
                onPressed: _login,
                child: new Text('Log in'),
              ),
              new RaisedButton(
                onPressed: _logOut,
                child: new Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
