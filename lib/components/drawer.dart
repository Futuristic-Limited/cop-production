import 'package:flutter/material.dart';
import 'package:APHRC_COP/components/my_list_tiles.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? OnProfile;
  final void Function()? OnSignOut;

  const MyDrawer({
    super.key,
    required this.OnProfile,
    required this.OnSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Custom Styled Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7BC148), Color(0xFFB2E79E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              "Welcome, Learner",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            accountEmail: const Text("learner@aphrc.org"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF7BC148)),
            ),
          ),

          // Main List Tiles
          MyListTiles(
            icon: Icons.home_outlined,
            text: 'Home',
            OnTap: () => Navigator.pop(context),
          ),
          MyListTiles(
            icon: Icons.person_outline,
            text: 'Profile',
            OnTap: OnProfile,
          ),
          MyListTiles(
            icon: Icons.inventory_2_rounded,
            text: 'My Orders',
            OnTap: () {
              // TODO: Add your orders logic
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          // Logout Button Styled Differently
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.red.shade50,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: OnSignOut,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
