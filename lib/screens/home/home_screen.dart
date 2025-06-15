import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../cells/custom_app_bar.dart';
import '../../drawer/AnimatedDrawerWrapper.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../cells/community_card.dart';
import '../../services/community_service.dart';
import '../../services/shared_prefs_service.dart';
import '../auth/login_screen.dart';
import 'dashboard.dart';
import '../activity/activity_feed_screen.dart';
import '../notifications/notifications_screen.dart';
import '../groups/groups_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  final CommunityService communityService = CommunityService();
  List<dynamic> communities = [];
  List<dynamic> filteredCommunities = [];
  bool isLoading = true;
  bool _showSuggestions = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final loggedIn = await SharedPrefsService.isLoggedIn();
    final data = await communityService.fetchCommunities();

    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
        communities = data;
        filteredCommunities = data;
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _showSuggestions = query.isNotEmpty;
      filteredCommunities = communities
          .where((community) => community['name'].toLowerCase().contains(
        query.toLowerCase(),
      ))
          .toList();
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 800 ? 3 : (width > 600 ? 2 : 1);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            // Removed the search bar and related widgets completely
            // Main Dashboard Content
            Expanded(
              child: CustomizedDashboard(),
            ),
          ],
        );
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
        appBar: const CustomAppBar(),
        drawer: AnimatedDrawerWrapper(
          isLoggedIn: isLoggedIn,
          onLogout: () async {
            await SharedPrefsService.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
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
}


