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
        onTap(index); // Call the parent's onTap handler
        switch (index) {
          case 0: // Home
            Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false
            );
            break;
          case 1: // Activity Feed
            Navigator.pushNamed(context, '/activity');
            break;
          case 2: // Notifications
            Navigator.pushNamed(context, '/notifications');
            break;
          case 3: // Communities
            Navigator.pushNamed(context, '/communities');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Activity'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Communities'),
      ],
    );
  }
}

