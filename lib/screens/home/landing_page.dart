import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/community_service.dart';
import '../../cells/custom_app_bar.dart';
import '../../cells/banner_carousel.dart';
import '../../cells/community_card.dart';
import '../../cells/app_drawer.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<dynamic> communities = [];
  bool isLoading = true;
  final CommunityService communityService = CommunityService();
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredCommunities = [];

  @override
  void initState() {
    super.initState();
    loadCommunities();
  }

  void filterCommunities(String query) {
    final results =
        communities.where((community) {
          final name = community['name']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();

    setState(() {
      filteredCommunities = results;
    });
  }

  Future<void> loadCommunities() async {
    try {
      final data = await communityService.fetchCommunities();
      setState(() {
        communities = data;
        filteredCommunities = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading communities: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterCommunities,
                  decoration: InputDecoration(
                    hintText: 'Search communities...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              const BannerCarousel(),
              _buildHeroSection(context),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: const [
                    Text(
                      "Our Communities",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: communities.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          itemBuilder: (context, index) {
                            return CommunityCard(
                              community: communities[index],
                              communityService: communityService,
                            );
                          },
                        ),
              ),
              const SizedBox(height: 40),
              _buildTestimonialsSection(),
              const SizedBox(height: 40),
              _buildCTASection(context),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      color: const Color(0xFFEDF6ED),
      child: Column(
        children: const [
          Text(
            "Welcome to APHRC Community of Practice",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "A vibrant platform for researchers to collaborate, share knowledge, and drive impact across Africa.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          StatCard(
            label: 'Communities',
            value: '35+',
            icon: FontAwesomeIcons.peopleGroup,
            color: Colors.green,
          ),
          StatCard(
            label: 'Researchers',
            value: '1,200+',
            icon: FontAwesomeIcons.userGraduate,
            color: Colors.blue,
          ),
          StatCard(
            label: 'Countries',
            value: '15+',
            icon: FontAwesomeIcons.globeAfrica,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      children: const [
        Text(
          "What Our Members Say",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TestimonialCard(
          name: "Dr. Jane Doe",
          role: "Public Health Expert",
          quote:
              "This platform transformed how I collaborate with fellow researchers across Africa.",
        ),
        SizedBox(height: 12),
        TestimonialCard(
          name: "Dr. Peter N.",
          role: "Nutrition Researcher",
          quote:
              "The community interaction and resources here are simply unmatched.",
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Ready to Join?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.group_add),
          label: const Text('Join Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text("Already a member? Log in"),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color.fromARGB(255, 240, 240, 240),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '© 2025 APHRC Community of Practice',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: const Text("Privacy Policy")),
              const Text("|", style: TextStyle(color: Colors.black45)),
              TextButton(onPressed: () {}, child: const Text("Terms of Use")),
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String quote;

  const TestimonialCard({
    required this.name,
    required this.role,
    required this.quote,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(height: 10),
            Text(
              '"$quote"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(
              "- $name",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(role, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
