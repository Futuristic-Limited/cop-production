import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == 3) { // Groups is at index 3
          Navigator.pushNamed(context, '/groups');
        } else {
          onTap(index); // Handle other tabs normally
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Feeds'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
      ],
    );
  }
}