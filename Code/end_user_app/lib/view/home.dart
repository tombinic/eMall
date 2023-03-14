import 'package:flutter/material.dart';
import 'package:end_user_app/view/maps.dart';
import 'package:end_user_app/view/user_bookings.dart';
import 'package:end_user_app/view/Charge.dart';
import 'package:end_user_app/view/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    const Charge(),
    const Maps(),
    const MyBooking(),
    const Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _children[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/images/battery.png")),
                label: ''),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage("assets/images/explore.png")),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage("assets/images/calendar.png")),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage("assets/images/user.png")),
              label: '',
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 194, 57, 235),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
