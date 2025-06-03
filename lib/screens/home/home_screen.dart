import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../cells/custom_app_bar.dart';
import '../../cells/custom_drawer.dart';
import '../../cells/custom_bottom_nav_bar.dart';
import '../../cells/community_card.dart';
import '../../services/community_service.dart';
import '../../services/shared_prefs_service.dart';
import '../auth/login_screen.dart';

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
  bool isLoading = true;

  final List<String> bannerImages = [
    'assets/community_banner.jpg',
    'assets/community_banner2.jpg',
    'assets/community_banner3.jpg',
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Home Placeholder')),
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
      isLoading = false;
    });
  }

  void _handleLogout() async {
    await SharedPrefsService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 3 : (width > 600 ? 2 : 1);

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: CustomDrawer(
        isLoggedIn: isLoggedIn,
        onLogout: _handleLogout,
      ),
      body: _selectedIndex == 0
          ? Column(
        children: [
          SizedBox(
            height: 200,
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                aspectRatio: 16 / 9,
              ),
              items: bannerImages.map((imagePath) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "OUR COMMUNITIES",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          isLoading
              ? const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
              : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: communities.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) => CommunityCard(
                community: communities[index],
                communityService: communityService,
              ),
            ),
          ),
        ],
      )
          : _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
