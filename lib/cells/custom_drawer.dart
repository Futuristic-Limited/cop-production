import 'package:flutter/material.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';

class CustomDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(123, 193, 72, 1),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.group,
                    color: Color.fromRGBO(123, 193, 72, 1),
                    size: 32,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Community Hub',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children:
              isLoggedIn ? _buildLoggedInItems(context) : _buildGuestItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoggedInItems(BuildContext context) {
    return [
      _drawerItem(context, Icons.home, 'Home', '/home'),
      _drawerItem(context, Icons.settings, 'Settings', '/settings'),
      _drawerItem(context, Icons.notifications, 'Notifications', '/notifications'),
      _drawerItem(context, Icons.group, 'Groups', '/groups'),
      _drawerItem(context, Icons.message, 'Messages', '/messages'),
      _drawerItem(context, Icons.email, 'Email Invite', '/email_invites'),
      _drawerItem(context, Icons.person, 'Profile', '/profile'),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(fontSize: 16),
        ),
        onTap: () async {
          Navigator.pop(context); // Close drawer first
          await SharedPrefsService.logout();
          onLogout();
        },
      ),
    ];
  }

  List<Widget> _buildGuestItems(BuildContext context) {
    return [
      _drawerItem(context, Icons.login, 'Login', '/login'),
      _drawerItem(context, Icons.app_registration, 'Sign Up', '/register'),
    ];
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
