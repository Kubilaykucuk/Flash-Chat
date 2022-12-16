import 'package:flash_chat_flutter/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/components/button.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ChatScreen();
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: ModalProgressHUD(
                inAsyncCall: showSpinner,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            height: 200.0,
                            child: Image.asset('images/logo.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48.0,
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black),
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter your email'),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextField(
                        obscureText: true,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          password = value;
                        },
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter your password'),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Button(
                        text: 'Log In',
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            print(email);
                            print(password);
                            final user = _auth.signInWithEmailAndPassword(
                                email: email.toString(),
                                password: password.toString());
                            print(user);
                            if (user == null) {
                              Alert(
                                      context: context,
                                      title: 'This user does not exist',
                                      desc:
                                          'You\'ve typed wrong email address or wrong password.Please enter the correct email and password')
                                  .show();
                            }
                            setState(() {
                              showSpinner = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
