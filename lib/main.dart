import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//providers
import './providers/authentication_manager.dart';
import './providers/books_manager.dart';
//screens
import './screens/home_page.dart';
import './screens/login_screen.dart';
import './screens/registration_screen.dart';
import './screens/welcome_screen.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var preference = await SharedPreferences.getInstance();
  var isLoggedIn = preference.getBool("isLoggedIn") ?? false;
  var initSettingAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initSettings = InitializationSettings(
    android: initSettingAndroid,
  );

  await _localNotifications.initialize(initSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationManager>(
          create: (_) => AuthenticationManager(
            isLoggedIn,
          ),
        ),
        ChangeNotifierProvider<BooksManager>(
          create: (_) => BooksManager(),
        ),
      ],
      child: BookBank(
        isLoggedIn: isLoggedIn,
      )));
}

class BookBank extends StatelessWidget {
  final bool isLoggedIn;

  BookBank({this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    print("value " + isLoggedIn.toString());
    return MaterialApp(
      initialRoute: isLoggedIn ? HomePage.routeName : WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegistrationScreen.routeName: (context) => RegistrationScreen(),
        HomePage.routeName: (context) => HomePage(),
      },
    );
  }
}
