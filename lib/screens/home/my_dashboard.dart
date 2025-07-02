import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'package:APHRC_COP/files/UserUploadsScreen.dart';
import '../notifications/notifications_screen.dart';
import '../messages/messages_screen.dart';
import '../groups/groups_screen.dart';

class MyDashboardScreen extends StatefulWidget {
  final dynamic stype;

  const MyDashboardScreen({super.key, required this.stype});

  @override
  State<MyDashboardScreen> createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_TabItem> _tabs;
  late Widget _activeScreen;

  @override
  void initState() {
    super.initState();
    _tabs = _getTabsByType(widget.stype);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _activeScreen = _buildScreen(0);
  }

  List<_TabItem> _getTabsByType(String type) {
    switch (type) {
      case 'home':
        return [
          _TabItem(icon: Icons.home, label: 'Home'),
          _TabItem(icon: Icons.group, label: 'Groups'),
          _TabItem(icon: Icons.message, label: 'Messages'),
        ];
      case 'account':
        return [
          _TabItem(icon: Icons.person, label: 'Profile'),
          _TabItem(icon: Icons.settings, label: 'Settings'),
          //_TabItem(icon: Icons.logout, label: 'Logout'),
        ];
      case 'tools':
        return [
          _TabItem(icon: Icons.folder, label: 'Files'),
          _TabItem(icon: Icons.notifications, label: 'Notifications'),
        ];
      default:
        return [
          _TabItem(icon: Icons.groups, label: 'My Communities'),
          _TabItem(icon: Icons.timeline, label: 'Activity'),
          _TabItem(icon: Icons.notifications, label: 'Notifications'),
        ];
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeScreen = _buildScreen(_tabController.index);
      });
    }
  }

  Widget _buildScreen(int index) {
    String label = _tabs[index].label;

    switch (label) {
      case 'Groups':
        return GroupsScreen();
      case 'Messages':
        return MessagesScreen();
      case 'Profile':
        return ProfileScreen();
      case 'Settings':
        return SettingsScreen();
      case 'Logout':
        return Center(child: Text('No screen for "$label"'));
      case 'Files':
        return UserUploadsScreen();
      case 'Notifications':
        return NotificationsScreen();
      case 'My Communities':
        return Center(child: Text('No screen for "$label"'));
      case 'Activity':
        return Center(child: Text('No screen for "$label"'));
      default:
        return Center(child: Text('No screen for "$label"'));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          widget.stype == 'home'
              ? _activeScreen // For home screen, just show the content without tabs
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 12,
                      right: 12,
                      bottom: 8,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs:
                          _tabs
                              .map(
                                (tab) =>
                                    Tab(icon: Icon(tab.icon), text: tab.label),
                              )
                              .toList(),
                      labelColor: const Color(0xFF6ABF43),
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: const Color(0xFF6ABF43),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                  Expanded(child: _activeScreen),
                ],
              ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  _TabItem({required this.icon, required this.label});
}
