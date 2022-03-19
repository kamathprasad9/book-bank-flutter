import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//constants
import '../constants.dart';
//widgets
import '../widgets/rounded_button.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String email, password;

  late String name, contact;
  bool _isError = false;
  late String _errorMessage;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Container(
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
                TextFormField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your name'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    contact = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else if (value.length != 10) {
                      return "Should be 10 digit long";
                    }
                    return null;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your contact number'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email'),
                  validator: (value) {
                    // Pattern pattern =
                    //     r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
                    RegExp regex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                    if (value!.isEmpty) {
                      return "Required";
                    } else if (!regex.hasMatch(value)) {
                      return "Enter valid Email";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else if (value.length < 6) {
                      return "Password should be at least 6 characters long";
                    }
                    return null;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Register',
                  colour: Colors.blueAccent,
                  onPressed: () async {
                    if (_submit()) {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          await FirebaseDatabase.instance
                              .reference()
                              .child('usersArray')
                              .child(email
                                  .replaceAll('@', 'at')
                                  .replaceAll('.', 'dot'))
                              .set({
                            'email': email,
                            'name': name,
                            'contact': contact,
                          });

                          Navigator.pop(context);
                          // Navigator.pushNamed(context, LoginScreen.routeName);
                        }

                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        // if (e is PlatformException) if (e.code ==
                        //     'ERROR_EMAIL_ALREADY_IN_USE') {
                        //   setState(() {
                        //     _isError = true;
                        //   });
                        // }
                        setState(() {
                          _isError = true;
                          _errorMessage = e.toString();
                        });
                        print(e.toString());
                      }
                    }
                  },
                ),
                if (_isError)
                  Text(
                    // "The email is already registered",
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _submit() {
    // getLoc();
    print("$name+$contact+$email+$contact");
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return false;
    }
    _formKey.currentState!.save();
    return true;
  }
}
