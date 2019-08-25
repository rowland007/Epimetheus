import 'package:flutter/material.dart';

AlertDialog invalidCredentialsDialog(context) {
  return AlertDialog(
    title: Text('Incorrect email address or password.'),
    content: Text('Please try again, or reset your password at pandora.com.'),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/sign-in');
        },
        child: Text('Okay'),
      )
    ],
  );
}
