import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//providers
import '../providers/authentication_manager.dart';
import '../screens/login_screen.dart';
//screens
import '../screens/welcome_screen.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    // print("drawer");
    bool isLoggedIn = Provider.of<AuthenticationManager>(context).isLoggedIn;
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(child: Text(isLoggedIn ? "Logged In" : "Logged Out")),
            TextButton(
              onPressed: () {
                if (isLoggedIn) {
                  Provider.of<AuthenticationManager>(context, listen: false)
                      .loggedInFalse();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    ModalRoute.withName(WelcomeScreen.routeName),
                  );
                } else {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                }
              },
              child: ListTile(
                leading: Icon(Icons.account_circle_rounded),
                title: Text(isLoggedIn ? 'Logout' : 'Login'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
