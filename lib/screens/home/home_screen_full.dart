import 'package:APHRC_COP/services/community_service.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../groups/group_detail_screen.dart';
import '../groups/groups_screen.dart';
// import '../../models/comments.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/token_preference.dart';
// import 'package:http/http.dart' as http;

// Replace this with your actual authentication logic
// For demonstration purposes, we'll use a simple

bool isLoggedIn = true;

void checkIfLoggedIn() async {
  String? token = await SaveAccessTokenService.getAccessToken();
  isLoggedIn = token != null && token.isNotEmpty;
  print('User logged in: $isLoggedIn'); // Will print true or false
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    NewsFeedScreen(),
    MembersScreen(),
    GroupsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.group,
                      color: Color.fromRGBO(123, 193, 72, 1),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
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
                children:
                    isLoggedIn
                        ? [
                          _buildDrawerItem(Icons.local_activity, 'Activity'),
                          _buildDrawerItem(Icons.settings, 'Settings'),
                          _buildDrawerItem(
                            Icons.notifications,
                            'Notifications',
                          ),
                          _buildDrawerItem(Icons.group, 'Groups'),
                          _buildDrawerItem(Icons.message, 'Messages'),
                          _buildDrawerItem(Icons.person, 'Profile'),
                          _buildDrawerItem(
                            Icons.logout,
                            'Logout',
                            onTap: () {
                              setState(() {
                                isLoggedIn = false;
                              });
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),
                        ]
                        : [
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
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        if (onTap != null) onTap();
      },
    );
  }
}

// -----------------------------------------
// Other Screens
// -----------------------------------------

class NewsFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('News Feed Screen'));
}

class MembersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Members Screen'));
}

class LogOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          isLoggedIn = false;
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: const Text('Log Out'),
      ),
    );
  }
}

// -----------------------------------------
// HomeContent (Landing Page & Dashboard)
// -----------------------------------------

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
    checkIfLoggedIn();
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

  void handleJoin(
    BuildContext context,
    String groupId,
    Map<String, dynamic> groupData,
  ) async {
    final joined = await communityService.joinCommunity(groupId);
    if (joined) {
      String? imageUrl;
      if (groupData['image'] is String) {
        imageUrl = groupData['image'];
      } else if (groupData['image'] is Map<String, dynamic>) {
        imageUrl = groupData['image']['url'];
      }
      final updatedGroupData = Map<String, dynamic>.from(groupData);
      updatedGroupData['image'] = imageUrl;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(group: updatedGroupData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to join the group.")),
      );
    }
  }

  Widget buildCommunityCard(Map<String, dynamic> community) {
    final name = community['name'] ?? 'Community';
    final description = community['description']['rendered'] ?? '';
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
                  onPressed:
                      () => handleJoin(
                        context,
                        community['id'].toString(),
                        community,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 3 : (width > 600 ? 2 : 1);

    return SafeArea(
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
          isLoading
              ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
              : Expanded(
                child: GridView.builder(
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
        ],
      ),
    );
  }
}
