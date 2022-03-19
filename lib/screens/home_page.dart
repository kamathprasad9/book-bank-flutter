import 'package:flutter/material.dart';

import '../widgets/add_book.dart';
import '../widgets/app_drawer.dart';
//widgets
import '../widgets/browse_books.dart';

class HomePage extends StatefulWidget {
  static String routeName = 'home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentIndex = 0;
  late PageController _pageController;

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
    BrowseBooks(),
    AddBook(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            // selectedColor: Colors.purple,
          ),

          /// Likes
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add",
            // selectedColor: Colors.pink,
          ),
        ],
      ),
      body: Container(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
    );
  }
}
