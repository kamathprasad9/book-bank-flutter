import 'package:flutter/material.dart';

//widgets
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  static String routeName = 'home_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(),
      body: Container(
        child: Center(child: Text('Home')),
      ),
    );
  }
}
