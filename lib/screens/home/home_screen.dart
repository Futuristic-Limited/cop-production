import 'package:flutter/material.dart';
import '../../cells/custom_app_bar.dart';
import '../../drawer/AnimatedDrawerWrapper.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../services/community_service.dart';
import '../../services/shared_prefs_service.dart';
import '../auth/login_screen.dart';
import 'dashboard.dart';
import '../activity/activity_feed_screen.dart'; // Add this import
import '../notifications/notifications_screen.dart'; // Add this import
import '../groups/groups_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  final CommunityService communityService = CommunityService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final loggedIn = await SharedPrefsService.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_selectedIndex != 0) {
                setState(() => _selectedIndex = 0);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        drawer: AnimatedDrawerWrapper(
          isLoggedIn: isLoggedIn,
          onLogout: () async {
            await SharedPrefsService.logout();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        body: _buildCurrentScreen(),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onBottomNavItemTapped,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const CustomizedDashboard();
      case 1:
        return const ActivityFeedScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const GroupsScreen();
      default:
        return Container();
    }
  }

  void _onBottomNavItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    if (index != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _buildScreenForIndex(index),
        ),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    }
  }

  Widget _buildScreenForIndex(int index) {
    switch (index) {
      case 1:
        return const ActivityFeedScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const GroupsScreen();
      default:
        return Container();
    }
  }
}


