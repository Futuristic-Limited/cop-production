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
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _createAnimations();
    _controller.forward();
  }

  @override
  void didUpdateWidget(CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoggedIn != widget.isLoggedIn) {
      _createAnimations();
      _controller.forward(from: 0); // Restart animation when login state changes
    }
  }

  void _createAnimations() {
    final itemCount = widget.isLoggedIn ? 5 : 2;
    _slideAnimations = List.generate(
      itemCount,
          (index) => Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).size.height * 0.135;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 6, offset: Offset(2, 2))],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Opacity(
                      opacity: 0.85,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/logo_aphrc_1.png'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Community Hub',
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: widget.isLoggedIn ? _buildLoggedInItems(context) : _buildGuestItems(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoggedInItems(BuildContext context) {
    return [
      _animatedDrawerItem(0, context, Icons.home, 'Home', '/home'),
      _animatedDrawerItem(1, context, Icons.inbox, 'Messages', '/messages'),
      _animatedDrawerItem(2, context, Icons.account_box, 'Account', '/home/account'),
      _animatedDrawerItem(3, context, Icons.settings, 'Tools', '/home/tools'),
      const SizedBox(height: 8),
      _slideAnimations.length > 4
          ? SlideTransition(
        position: _slideAnimations[4],
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
      )
          : Container(), // Fallback if animations aren't ready
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
    if (index >= _slideAnimations.length) {
      return Container(); // Safe fallback
    }

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




