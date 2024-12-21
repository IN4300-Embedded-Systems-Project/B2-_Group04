import 'package:air_quality_iot_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:air_quality_iot_app/features/home_screen/views/home_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    Center(child: Text('Page 1')),
    Center(child: Text('Page 2')),
    HomeView(), // Home Page
    Center(child: Text('Page 3')),
    Center(child: Text('Page 4')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryblue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.home, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primaryblue,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.sunny,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.air,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.water_drop,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.co2, size: 40, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
