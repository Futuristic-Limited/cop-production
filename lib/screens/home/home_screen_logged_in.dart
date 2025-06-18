import 'package:flutter/material.dart';
import '../../cells/custom_app_bar.dart';
import '../../drawer/AnimatedDrawerWrapper.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../services/community_service.dart';
import '../../services/shared_prefs_service.dart';
import '../auth/login_screen.dart';

import 'my_dashboard.dart';

class HomeScreenLoggedIn extends StatefulWidget {
  final dynamic stype;

  const HomeScreenLoggedIn({super.key, required this.stype});

  @override
  State<HomeScreenLoggedIn> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenLoggedIn> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  final CommunityService communityService = CommunityService();
  List<dynamic> communities = [];
  List<dynamic> filteredCommunities = [];
  bool isLoading = true;
  bool _showSuggestions = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> bannerImages = [
    'assets/community_banner.jpg',
    'assets/community_banner2.jpg',
    'assets/community_banner3.jpg',
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const Center(child: Text('News Feed')),
    const Center(child: Text('Members')),
    const Center(child: Text('Groups')),
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final loggedIn = await SharedPrefsService.isLoggedIn();
    final data = await communityService.fetchCommunities();

    setState(() {
      isLoggedIn = loggedIn;
      communities = data;
      filteredCommunities = data;
      isLoading = false;
    });
  }

  void _handleLogout() async {
    await SharedPrefsService.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _showSuggestions = query.isNotEmpty;
      filteredCommunities =
          communities
              .where(
                (community) => community['name'].toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
              .toList();
    });
  }

  void _scrollToCommunity(String name) {
    final index = communities.indexWhere((c) => c['name'] == name);
    if (index != -1) {
      _scrollController.animateTo(
        (index ~/ _getCrossAxisCount()) * 300.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      FocusScope.of(context).unfocus();
    }
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    return width > 800 ? 3 : (width > 600 ? 2 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount();

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: AnimatedDrawerWrapper(
        isLoggedIn: true,
        onLogout: () async {
          await SharedPrefsService.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body:
      _selectedIndex == 0
          ? Column(
        children: [

          Expanded(
            child: MyDashboardScreen(stype:widget.stype),
          ),

        ],
      )
          : _screens[_selectedIndex],

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
              //Navigator.pushNamed(context, '/feed');
                const Center(child: Text('to do : News Feed'));
                break;
              case 2:
              //Navigator.pushNamed(context, '/notifications');
                const Center(child: Text('to do : Members holder'));
                break;
              case 3:
                Navigator.pushNamed(context, '/groups');
                break;
            }
          });
        },
      ),

    );
  }
}




