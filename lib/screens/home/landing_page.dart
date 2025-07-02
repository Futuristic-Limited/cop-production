import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../cells/landing_app_bar.dart';
import '../../cells/banner_carousel.dart';
import '../../cells/community_card.dart';
import '../../cells/app_drawer.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<dynamic> communities = [];
  bool isLoading = true;
  final CommunityService communityService = CommunityService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const BannerCarousel(),

                    const SizedBox(height: 10),

                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      width: double.infinity,
                      child: Card(
                        color: Colors.black,
                        elevation: 4,
                        shadowColor: const Color(0xFF0BC148).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "APHRC COMMUNITIES",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    isLoading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      itemCount: communities.length,
                      itemBuilder:
                          (context, index) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CommunityCard(
                              community: communities[index],
                              communityService: communityService, joinedGroupIds: [],
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Static footer


            Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '© 2025 aphrc. All rights reserved.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 4), // Optional spacing between lines
                  Text(
                    'Designed & Developed by Futuristic Limited',
                    style: TextStyle(color: Colors.white54), // Faint white
                  ),
                ],
              ),
            ),


            // Container(
            //   color: Colors.black,
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   alignment: Alignment.center,
            //   child: const Text(
            //     '© 2025 aphrc \n Developed by Futuristic Limited',
            //     style: TextStyle(color: Colors.white),
            //   ),
            // ),



          ],
        ),
      ),
    );
  }
}