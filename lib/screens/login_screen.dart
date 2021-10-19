import 'package:book_bank/screens/home_page.dart';
import 'package:book_bank/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//constants
import '../constants.dart';
//providers
import '../providers/authentication_manager.dart';
//widgets
import '../widgets/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  bool _isError = false;
  String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
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
                    child: Image.asset('assets/icon.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
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
              RoundedButton(
                title: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  // setState(() {
                  //   showSpinner = true;
                  // });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      Provider.of<AuthenticationManager>(context, listen: false)
                          .loggedInTrue();

                      Provider.of<AuthenticationManager>(context, listen: false)
                          .email = email;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, HomePage.routeName);
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      _isError = true;
                      _errorMessage = e.toString();
                    });
                  }
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, RegistrationScreen.routeName);
                },
                child: Text(
                  "Not Registered? Sign Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              if (_isError)
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    // "The email is already registered",
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
