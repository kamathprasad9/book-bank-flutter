import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationManager with ChangeNotifier {
  bool _isLoggedIn;

  AuthenticationManager(bool isLoggedIn) {
    _isLoggedIn = isLoggedIn;
  }

  bool get isLoggedIn => _isLoggedIn;

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
