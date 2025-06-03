import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

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
                  child: Icon(Icons.group, color: Colors.green, size: 30),
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
              children: [
                _buildDrawerItem(Icons.login, 'Login', context, '/login'),
                _buildDrawerItem(
                  Icons.app_registration,
                  'Sign Up',
                  context,
                  '/register',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
