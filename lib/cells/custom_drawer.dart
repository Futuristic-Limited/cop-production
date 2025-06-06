import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:APHRC_COP/services/shared_prefs_service.dart';

class CustomDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  Future<Map<String, String?>> _getUserProfile() async {
    final name = await SharedPrefsService.getUserName();
    final photo = await SharedPrefsService.getProfilePhotoUrl();
    return {'name': name, 'photo': photo};
  }

  Future<int> _getUnreadNotificationCount() async {
    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notifications = data['notifications'];
        final unreadCount =
            notifications.where((n) => n['is_new'] == 1).length;
        return unreadCount;
      } else {
        debugPrint("Failed to load notifications: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Map<String, String?>>(
            future: _getUserProfile(),
            builder: (context, snapshot) {
              final fullName = snapshot.data?['name'] ?? 'Welcome';
              final photoUrl = snapshot.data?['photo'];

              return DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6ABF43), Color(0xFF4C9B23)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'APHRC Community',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: isLoggedIn
                  ? _buildLoggedInItems(context)
                  : _buildGuestItems(context),
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
      FutureBuilder<int>(
        future: _getUnreadNotificationCount(),
        builder: (context, snapshot) {
          int count = snapshot.data ?? 0;
          return _drawerItem(
            context,
            Icons.notifications,
            'Notifications',
            '/notifications',
            badgeCount: count,
          );
        },
      ),
      _drawerItem(context, Icons.group, 'Groups', '/groups'),
      _drawerItem(context, Icons.message, 'Messages', '/messages'),
      _drawerItem(context, Icons.email, 'Email Invite', '/email_invites'),
      _drawerItem(context, Icons.person, 'Profile', '/profile'),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(fontSize: 16)),
        onTap: () async {
          Navigator.pop(context);
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

  Widget _drawerItem(BuildContext context, IconData icon, String title, String routeName,
      {int? badgeCount}) {
    return ListTile(
      leading: badgeCount != null && badgeCount > 0
          ? badges.Badge(
        badgeContent: Text(
          badgeCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
          padding: EdgeInsets.all(6),
        ),
        child: Icon(icon, color: Colors.green),
      )
          : Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
