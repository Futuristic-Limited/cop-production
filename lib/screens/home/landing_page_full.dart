import 'package:flutter/material.dart';
import '../groups/group_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/community_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<dynamic> communities = [];
  bool isLoading = true;
  final CommunityService communityService = CommunityService();

  final List<String> bannerImages = [
    'assets/community_banner.jpg',
    'assets/community_banner2.jpg',
    'assets/community_banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    loadCommunities();
  }

  Future<void> loadCommunities() async {
    try {
      final data = await communityService.fetchCommunities();
      setState(() {
        communities = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading communities: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildCommunityCard(Map<String, dynamic> community) {
    final name = community['name'] ?? 'Community';
    final description = community['description']?['rendered'] ?? '';
    final avatarUrl = community['avatar_urls']?['full'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/default_course.jpg')
                          as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailScreen(group: community),
                      ),
                    );
                  },
                  child: const Text('Read More'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Login screen when user taps Join Group button but not logged in
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 123, 193, 72),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Login to Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 3 : (width > 600 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'APHRC Community of Practice',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
        elevation: 0,
      ),
      drawer: Drawer(
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
                  _buildDrawerItem(
                    Icons.login,
                    'Login',
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  _buildDrawerItem(
                    Icons.app_registration,
                    'Sign Up',
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
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
                items:
                    bannerImages.map((imagePath) {
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
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: communities.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          return buildCommunityCard(communities[index]);
                        },
                      ),
            ),
            Container(
              color: const Color.fromARGB(255, 232, 230, 230),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                '© 2025 APHRC Community of Practice. All rights reserved.',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
