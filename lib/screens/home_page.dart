import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../widgets/add_book.dart';
//widgets
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  static String routeName = 'home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: _currentIndex,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      // style: optionStyle,
    ),
    AddBook(),
    Text(
      'Index 2: School',
      // style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.add),
            title: Text("Add"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          // SalomonBottomBarItem(
          //   icon: Icon(Icons.person),
          //   title: Text("Profile"),
          //   selectedColor: Colors.teal,
          // ),
        ],
      ),
      body: Container(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
    );
  }
}
