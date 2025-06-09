import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:badges/badges.dart' as badges;

class CustomDrawer extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final itemCount = widget.isLoggedIn ? 8 : 2;
    _slideAnimations = List.generate(
      itemCount,
          (index) => Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.group,
                    color: Color(0xFF8BC53F),
                    size: 30,
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
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: widget.isLoggedIn
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
      _animatedDrawerItem(0, context, Icons.home, 'Home', '/home'),
      _animatedDrawerItem(1, context, Icons.settings, 'Settings', '/settings'),
      FutureBuilder<int>(
        future: _getUnreadNotificationCount(),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return _animatedDrawerItem(
            2,
            context,
            Icons.notifications,
            'Notifications',
            '/notifications',
            badgeCount: count,
          );
        },
      ),
      _animatedDrawerItem(3, context, Icons.group, 'Groups', '/groups'),
      _animatedDrawerItem(4, context, Icons.message, 'Messages', '/messages'),
      _animatedDrawerItem(5, context, Icons.email, 'Email Invite', '/email_invites'),
      _animatedDrawerItem(6, context, Icons.person, 'Profile', '/profile'),
      _animatedDrawerItem(7, context, Icons.insert_drive_file, 'Files', '/files'),
      const SizedBox(height: 8),
      SlideTransition(
        position: _slideAnimations[7],
        child: HoverCard(
          baseColor: Colors.white,
          hoverColor: Colors.red.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(fontSize: 16, color: Colors.black)),
            onTap: () async {
              Navigator.pop(context);
              await SharedPrefsService.logout();
              widget.onLogout();
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildGuestItems(BuildContext context) {
    return [
      _animatedDrawerItem(0, context, Icons.login, 'Login', '/login'),
      _animatedDrawerItem(1, context, Icons.app_registration, 'Sign Up', '/register'),
    ];
  }

  Widget _animatedDrawerItem(
      int index,
      BuildContext context,
      IconData icon,
      String title,
      String routeName, {
        int? badgeCount,
      }) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: HoverCard(
        baseColor: Colors.white,
        hoverColor: Colors.grey.shade100,
        child: ListTile(
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
          title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, routeName);
          },
        ),
      ),
    );
  }

  Future<int> _getUnreadNotificationCount() async {
    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notifications = data['notifications'];
        return notifications.where((n) => n['is_new'] == 1).length;
      }
    } catch (_) {}
    return 0;
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color hoverColor;

  const HoverCard({
    super.key,
    required this.child,
    this.baseColor = Colors.white,
    this.hoverColor = const Color(0xFFF5F5F5),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _hovering ? widget.hoverColor : widget.baseColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.2 : 0.1),
              blurRadius: _hovering ? 10 : 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:APHRC_COP/services/shared_prefs_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:badges/badges.dart' as badges;
//
// class CustomDrawer extends StatelessWidget {
//   final bool isLoggedIn;
//   final VoidCallback onLogout;
//
//   const CustomDrawer({
//     super.key,
//     required this.isLoggedIn,
//     required this.onLogout,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(
//               color: Color.fromRGBO(123, 193, 72, 1),
//             ),
//             child: Row(
//               children: const [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.group,
//                     color: Color.fromRGBO(123, 193, 72, 1),
//                     size: 32,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Community Hub',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: isLoggedIn
//                   ? _buildLoggedInItems(context)
//                   : _buildGuestItems(context),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildLoggedInItems(BuildContext context) {
//     return [
//       _drawerItem(context, Icons.home, 'Home', '/home'),
//       _drawerItem(context, Icons.settings, 'Settings', '/settings'),
//       FutureBuilder<int>(
//         future: _getUnreadNotificationCount(),
//         builder: (context, snapshot) {
//           int count = snapshot.data ?? 0;
//           return _drawerItem(
//             context,
//             Icons.notifications,
//             'Notifications',
//             '/notifications',
//             badgeCount: count,
//           );
//         },
//       ),
//       _drawerItem(context, Icons.group, 'Groups', '/groups'),
//       _drawerItem(context, Icons.message, 'Messages', '/messages'),
//       _drawerItem(context, Icons.email, 'Email Invite', '/email_invites'),
//       _drawerItem(context, Icons.person, 'Profile', '/profile'),
//       ListTile(
//         leading: const Icon(Icons.logout, color: Colors.red),
//         title: const Text(
//           'Logout',
//           style: TextStyle(fontSize: 16),
//         ),
//         onTap: () async {
//           Navigator.pop(context);
//           await SharedPrefsService.logout();
//           onLogout();
//         },
//       ),
//     ];
//   }
//
//   List<Widget> _buildGuestItems(BuildContext context) {
//     return [
//       _drawerItem(context, Icons.login, 'Login', '/login'),
//       _drawerItem(context, Icons.app_registration, 'Sign Up', '/register'),
//     ];
//   }
//
//   Widget _drawerItem(BuildContext context, IconData icon, String title, String routeName,
//       {int? badgeCount}) {
//     return ListTile(
//       leading: badgeCount != null && badgeCount > 0
//           ? badges.Badge(
//         badgeContent: Text(
//           badgeCount.toString(),
//           style: const TextStyle(color: Colors.white, fontSize: 10),
//         ),
//         badgeStyle: const badges.BadgeStyle(
//           badgeColor: Colors.red,
//           padding: EdgeInsets.all(6),
//         ),
//         child: Icon(icon, color: Colors.green),
//       )
//           : Icon(icon, color: Colors.green),
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushNamed(context, routeName);
//       },
//     );
//   }
//
//   Future<int> _getUnreadNotificationCount() async {
//     try {
//       final token = await SharedPrefsService.getAccessToken();
//       final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
//       final url = Uri.parse('$apiUrl/notifications');
//
//       final response = await http.get(url, headers: {
//         'Authorization': 'Bearer $token',
//       });
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> notifications = data['notifications'];
//         final unreadCount =
//             notifications.where((n) => n['is_new'] == 1).length;
//         return unreadCount;
//       } else {
//         debugPrint("Failed to load notifications: ${response.statusCode}");
//         return 0;
//       }
//     } catch (e) {
//       debugPrint("Error fetching notifications: $e");
//       return 0;
//     }
//   }
// }