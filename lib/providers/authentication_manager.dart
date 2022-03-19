import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationManager with ChangeNotifier {
  bool _isLoggedIn = false;

  String _email = '', _emailReplaced = '';

  AuthenticationManager(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
  }

  bool get isLoggedIn => _isLoggedIn;

  Future<String> getEmail() async {
    var preference = await SharedPreferences.getInstance();
    String storedEmail = preference.getString('email') ?? '';

    return _email != '' ? _email : storedEmail;
  }

  String get emailReplaced => _emailReplaced;

  set email(String email) {
    emailSharedPref(email);
    _email = email;
    print("here +" + _email);
    notifyListeners();
  }

  //
  // set userName(String userName) {
  //   _userName = userName;
  //   print("here +" + _userName);
  //   notifyListeners();
  // }
  //
  // // Future<String> emailUser() async {
  // //   var preferences = await SharedPreferences.getInstance();
  // //   return _email ?? preferences.getString("email");
  // // }

  emailSharedPref(String email) async {
    var preference = await SharedPreferences.getInstance();
    preference.setString("email", email);
    preference.setString(
        "emailReplaced", email.replaceAll("@", "at").replaceAll(".", "dot"));
  }

  toggleLogin() async {
    _isLoggedIn = !_isLoggedIn;
    var preference = await SharedPreferences.getInstance();
    print("TOGGLE " + _isLoggedIn.toString());
    preference.setBool("isLoggedIn", _isLoggedIn);
  }

  loggedInTrue() async {
    _isLoggedIn = true;
    var preference = await SharedPreferences.getInstance();
    print("TOGGLE " + _isLoggedIn.toString());
    preference.setBool("isLoggedIn", _isLoggedIn);
  }

  loggedInFalse() async {
    _isLoggedIn = false;
    var preference = await SharedPreferences.getInstance();
    print("TOGGLE " + _isLoggedIn.toString());
    preference.setBool("isLoggedIn", _isLoggedIn);
  }
}
